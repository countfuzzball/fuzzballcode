from fuse import FuseOSError
import errno

class SSHFSTimestamps:
    def __init__(self, sftp):
        self.sftp = sftp

    def get_timestamps(self, path):
        try:
            st = self.sftp.stat(path)
            return {
                'st_atime': st.st_atime,  # Access time
                'st_mtime': st.st_mtime   # Modification time
            }
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)

    def update_timestamps(self, path, atime, mtime):
        try:
            self.sftp.utime(path, (atime, mtime))
        except Exception as e:
            raise FuseOSError(errno.EIO) from e
