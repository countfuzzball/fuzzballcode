import os
import sys
import argparse
import paramiko
import shutil
from fuse import FUSE
from sshfs_operations import SSHFSOperations
from getpass import getpass

class SSHFSMount:
    def __init__(self, remote_host, remote_path, mountpoint, username, password):
        self.remote_host = remote_host
        self.remote_path = remote_path
        self.mountpoint = mountpoint
        self.username = username
        self.password = password
        self.sftp = None
        self.ssh_client = None

    def connect(self):
        try:
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh_client.connect(self.remote_host, username=self.username, password=self.password)
            self.sftp = self.ssh_client.open_sftp()
        except Exception as e:
            print(f"SSH Connection failed: {e}")
            sys.exit(1)

    def mount(self):
        self.connect()
        try:
            fuse = FUSE(SSHFSOperations(self.sftp, self.remote_path, self.ssh_client), self.mountpoint, nothreads=True, foreground=True)
        finally:
            self.cleanup()

    def cleanup(self):
        pycache_path = os.path.join(os.path.dirname(__file__), "__pycache__")
        if os.path.exists(pycache_path):
            shutil.rmtree(pycache_path, ignore_errors=True)
            print("Cleaned up __pycache__ folder.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Mount a remote filesystem over SSH using FUSE.")
    parser.add_argument("remote_host", help="Remote host to connect to")
    parser.add_argument("remote_path", help="Path on the remote host to mount")
    parser.add_argument("mountpoint", help="Local mount point")
    parser.add_argument("-u", "--username", help="SSH username")
    
    args = parser.parse_args()
    username = args.username if args.username else input("Username: ")
    password = getpass("Password: ")

    sshfs = SSHFSMount(args.remote_host, args.remote_path, args.mountpoint, username, password)
    sshfs.mount()
