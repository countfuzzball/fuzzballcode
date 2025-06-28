import os
import errno
import paramiko
from fuse import FuseOSError, Operations

class SSHFSOperations(Operations):
    def __init__(self, sftp, remote_path, ssh_client):
        self.sftp = sftp
        self.remote_path = remote_path
        self.ssh_client = ssh_client  # Store SSH client for direct command execution
        self.open_files = {}
        self.file_counter = 0

    def _full_path(self, path):
        return os.path.join(self.remote_path, path.lstrip('/'))

    def getattr(self, path, fh=None):
        full_path = self._full_path(path)
        try:
            st = self.sftp.stat(full_path)
            
            # Try to retrieve accurate st_blocks using SSH stat
            stdin, stdout, stderr = self.ssh_client.exec_command(f'stat --format="%s %b" {full_path}')
            output = stdout.read().decode().strip()
            if output:
                st_size, st_blocks = map(int, output.split())
            else:
                st_blocks = max((st.st_size + 511) // 512, 1)  # Fallback calculation

            return {
                'st_mode': st.st_mode,
                'st_nlink': 1,
                'st_size': st.st_size,
                'st_uid': os.getuid(),
                'st_gid': os.getgid(),
                'st_atime': st.st_atime,
                'st_mtime': st.st_mtime,
                'st_blksize': 4096,
                'st_blocks': st_blocks
            }
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)

    def readdir(self, path, fh):
        full_path = self._full_path(path)
        return ['.', '..'] + self.sftp.listdir(full_path)

    def open(self, path, flags):
        if flags & os.O_APPEND:
            mode = 'ab'  # Open in append mode to ensure writes go to the end
        elif flags & os.O_WRONLY:
            mode = 'wb'
        elif flags & os.O_RDWR:
            mode = 'rb+'
        else:
            mode = 'rb'
        file_handle = self.sftp.open(self._full_path(path), mode)
        self.file_counter += 1
        self.open_files[self.file_counter] = {'path': path, 'handle': file_handle, 'mode': mode}
        return self.file_counter

    def read(self, path, size, offset, fh):
        file_handle = self.open_files.get(fh, {}).get('handle')
        if file_handle:
            file_handle.seek(offset)
            return file_handle.read(size)
        raise FuseOSError(errno.EBADF)

    def write(self, path, data, offset, fh):
        file_info = self.open_files.get(fh)
        if file_info:
            file_handle = file_info['handle']
            mode = file_info['mode']
            if mode == 'ab':
                file_handle.write(data)  # Append mode ensures proper appending
            else:
                file_handle.seek(offset)
                file_handle.write(data)
            file_handle.flush()
            return len(data)
        raise FuseOSError(errno.EBADF)

    def create(self, path, mode):
        full_path = self._full_path(path)
        file = self.sftp.file(full_path, 'wb')
        file.set_pipelined(True)
        self.sftp.chmod(full_path, mode)
        self.file_counter += 1
        self.open_files[self.file_counter] = {'path': path, 'handle': file, 'mode': 'wb'}
        return self.file_counter

    def unlink(self, path):
        self.sftp.remove(self._full_path(path))

    def mkdir(self, path, mode):
        self.sftp.mkdir(self._full_path(path))
        self.sftp.chmod(self._full_path(path), mode)

    def rmdir(self, path):
        self.sftp.rmdir(self._full_path(path))
    
    def truncate(self, path, length):
        full_path = self._full_path(path)
        with self.sftp.open(full_path, 'rb+') as file:
            file.truncate(length)
    
    def rename(self, old, new):
        old_path = self._full_path(old)
        new_path = self._full_path(new)
        try:
            self.sftp.stat(old_path)
            try:
                self.sftp.remove(new_path)
            except FileNotFoundError:
                pass
            self.sftp.rename(old_path, new_path)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)
        except PermissionError:
            raise FuseOSError(errno.EACCES)
        except OSError as e:
            raise FuseOSError(errno.EINVAL) from e
    
    def chmod(self, path, mode):
        full_path = self._full_path(path)
        self.sftp.chmod(full_path, mode)
    
    def utimens(self, path, times):
        full_path = self._full_path(path)
        atime, mtime = times
        self.sftp.utime(full_path, (atime, mtime))
    
    def release(self, path, fh):
        file_info = self.open_files.pop(fh, None)
        if file_info:
            file_info['handle'].close()
        return 0
