import cv2
import numpy as np
import time
import os
import sys
import select
from PIL import Image
import tempfile
import shutil
import tty
import termios
import subprocess

# Refactor 1.3 - Adding rewind/fast forward controls during playback

# Parameters for controlling the output size
FRAME_DELAY = 0.083  # Delay to mimic frame rate (roughly 30 FPS)
CHAR_ASPECT_RATIO = 2.0  # Characters are roughly twice as tall as they are wide
FRAME_SKIP_FACTOR = 2  # Skip every N frames for more aggressive dropping

# Redirect stderr to null to suppress FFmpeg messages globally
sys.stderr.flush()
devnull = os.open(os.devnull, os.O_WRONLY)
os.dup2(devnull, sys.stderr.fileno())

# Function to get the terminal size
def get_terminal_size():
    try:
        rows, columns = os.popen('stty size', 'r').read().split()
        return int(rows), int(columns)
    except Exception as e:
        print(f"Error getting terminal size: {e}")
        return 24, 80  # Default size

# Function to convert a frame to ASCII with color
def frame_to_colored_ascii(frame, terminal_width, terminal_height, prioritize_width):
    # Resize frame to fit within terminal dimensions
    original_height, original_width = frame.shape[:2]
    adjusted_terminal_height = terminal_height * CHAR_ASPECT_RATIO

    # Calculate new dimensions
    scale_x = terminal_width / original_width
    scale_y = adjusted_terminal_height / original_height
    
    # Determine which dimension to prioritize based on the switch
    if prioritize_width:
        scale = scale_x  # Prioritize fitting the width
    else:
        scale = min(scale_x, scale_y)  # Fit within both dimensions

    # Calculate new dimensions while maintaining aspect ratio
    new_width = min(int(original_width * scale), terminal_width)
    new_height = min(int(original_height * scale / CHAR_ASPECT_RATIO), terminal_height)

    resized_frame = cv2.resize(frame, (new_width, new_height))
    resized_frame = cv2.cvtColor(resized_frame, cv2.COLOR_BGR2RGB)

    # Convert the frame to an ASCII representation with color
    ascii_frame = ""
    for row in resized_frame:
        for pixel in row:
            r, g, b = pixel
            ascii_frame += f"\033[38;2;{r};{g};{b}m█"
        ascii_frame += "\033[0m\n"
    return ascii_frame, new_width, new_height, original_width, original_height

def play_video_ascii(video_path, prioritize_width):
    # Suppress FFmpeg debug output using OpenCV environment variable
    os.environ['OPENCV_FFMPEG_CAPTURE_OPTIONS'] = 'loglevel=quiet'

    # Capture the video from the given path
    cap = cv2.VideoCapture(video_path, cv2.CAP_FFMPEG)

    if not cap.isOpened():
        print("Error: Could not open video.")
        return

    frame_count = 0  # Track the number of frames processed
    frame_position = 0  # Track the current frame position
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))  # Total number of frames

    # Set terminal to raw mode to capture keypresses without Enter
    old_settings = termios.tcgetattr(sys.stdin)
    tty.setcbreak(sys.stdin.fileno())

    try:
        # Hide cursor to make playback smoother
        sys.stdout.write("\033[?25l")
        sys.stdout.flush()
        while True:
            # Handle rewind/fast forward controls
            if sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
                key = sys.stdin.read(1)
                if key == '\x1b':  # Escape sequence (arrow keys)
                    key += sys.stdin.read(2)
                    if key == '\x1b[A':  # Up arrow key for fast forward
                        sys.stdout.write("\033[2K\rFast forward pressed.\n")  # Debugging text
                        frame_position = min(frame_position + 30, total_frames - 1)
                        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_position)
                    elif key == '\x1b[B':  # Down arrow key for rewind
                        sys.stdout.write("\033[2K\rRewind pressed.\n")  # Debugging text
                        frame_position = max(frame_position - 30, 0)
                        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_position)

            ret, frame = cap.read()
            if not ret:
                print("End of video or error reading frame.")
                break

            frame_count += 1

            # Skip frames more aggressively based on FRAME_SKIP_FACTOR
            if frame_count % FRAME_SKIP_FACTOR != 0:
                continue

            # Get the current terminal size
            terminal_height, terminal_width = get_terminal_size()

            # Convert the frame to colored ASCII
            try:
                ascii_frame, frame_width, frame_height, original_width, original_height = frame_to_colored_ascii(frame, terminal_width, terminal_height, prioritize_width)
            except Exception as e:
                print(f"Error converting frame to ASCII: {e}")
                continue

            # Print original and resized dimensions
            print(f"Frame {frame_count}/{total_frames}: Original size = {original_width}x{original_height}, Resized size = {frame_width}x{frame_height}")
            # Calculate padding to center the frame vertically (no horizontal padding)
            padding_top = max((terminal_height - frame_height) // 2, 0)
            padding_left = 0

            # Move cursor to top-left corner and add padding to center the video
            try:
                sys.stdout.write('\033[H')
                sys.stdout.write('\n' * padding_top)
                for line in ascii_frame.splitlines():
                    sys.stdout.write(' ' * padding_left + line + '\n')
                sys.stdout.flush()
            except Exception as e:
                print(f"Error writing ASCII data to stdout: {e}")
                continue

            # Wait to mimic the frame rate
            time.sleep(FRAME_DELAY)
    except KeyboardInterrupt:
        # Graceful exit on Ctrl+C
        print("\nVideo playback interrupted.")
    finally:
        cap.release()
        # Show cursor again
        sys.stdout.write("\033[?25h")
        sys.stdout.flush()
        # Restore terminal settings
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
        print("Video capture released.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python script.py <video_file_path> <prioritize_width: true/false>")
        sys.exit(1)

    video_path = sys.argv[1]
    prioritize_width = sys.argv[2].lower() == 'true'

    print(f"Opening video file: {video_path}")
    print(f"Prioritizing width: {prioritize_width}")
    play_video_ascii(video_path, prioritize_width)
