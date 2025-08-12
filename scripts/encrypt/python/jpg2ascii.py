from PIL import Image
import argparse

# ASCII characters used to represent pixel intensity levels
#ASCII_CHARS = "@%#*+=-:. "
ASCII_CHARS = " .:-=+*#%@"

# Resize the image according to a new width
def resize_image(image, new_width=100):
    width, height = image.size
    aspect_ratio = height / width
    new_height = int(new_width * aspect_ratio * 0.55)  # Adjusting height for terminal aspect ratio
    return image.resize((new_width, new_height))

# Convert each pixel to grayscale
def grayify(image):
    return image.convert("L")

# Map each pixel to an ASCII character
def pixels_to_ascii(image):
    pixels = image.getdata()
    ascii_str = "".join(ASCII_CHARS[pixel // 25] for pixel in pixels)
    return ascii_str

# Convert an image file to ASCII art
def image_to_ascii(image_path, new_width=100, scale_factor=1):
    try:
        image = Image.open(image_path)
    except Exception as e:
        print(f"Unable to open image file: {image_path}. Error: {e}")
        return

    new_width = int(new_width * scale_factor)
    image = resize_image(image, new_width)
    image = grayify(image)

    ascii_str = pixels_to_ascii(image)
    ascii_len = len(ascii_str)
    new_width = image.width
    ascii_art = "\n".join(ascii_str[i:(i + new_width)] for i in range(0, ascii_len, new_width))

    return ascii_art

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("image", help="Path to the image file")
    parser.add_argument("-w", "--width", type=int, default=100, help="Width of ASCII art (default: 100)")
    parser.add_argument("-s", "--scale", type=float, default=1.0, help="Scale factor for higher resolution (default: 1.0)")
    args = parser.parse_args()

    ascii_art = image_to_ascii(args.image, args.width, args.scale)

    if ascii_art:
        print(ascii_art)
        
        # Optionally save to a file
        with open("ascii_art.txt", "w") as f:
            f.write(ascii_art)
