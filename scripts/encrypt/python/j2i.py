from PIL import Image, ImageDraw, ImageFont
import argparse
import os

# ASCII characters used to represent pixel intensity levels
ASCII_CHARS = " .:-=+*#%@"

def resize_image(image, new_width=100):
    """Resize the image to fit the desired width."""
    width, height = image.size
    aspect_ratio = height / width
    new_height = int(new_width * aspect_ratio * 0.55)  # Adjust for terminal aspect ratio
    return image.resize((new_width, new_height))

def grayify(image):
    """Convert the image to grayscale."""
    return image.convert("L")

def pixels_to_ascii(image):
    """Map each pixel to an ASCII character."""
    pixels = image.getdata()
    ascii_str = "".join(ASCII_CHARS[pixel // 25] for pixel in pixels)
    return ascii_str

def image_to_ascii(image_path, new_width=100, scale_factor=1):
    """Convert an image file to ASCII art."""
    try:
        image = Image.open(image_path)
    except Exception as e:
        print(f"Unable to open image file: {image_path}. Error: {e}")
        return None

    new_width = int(new_width * scale_factor)
    image = resize_image(image, new_width)
    image = grayify(image)

    ascii_str = pixels_to_ascii(image)
    ascii_len = len(ascii_str)
    new_width = image.width
    ascii_art = "\n".join(ascii_str[i:(i + new_width)] for i in range(0, ascii_len, new_width))

    return ascii_art

def ascii_to_image(input_file, output_file, font_path="arial.ttf", font_size=12, image_bg_color="black", text_color="white"):
    """Convert ASCII art to an image."""
    with open(input_file, "r") as f:
        lines = f.readlines()

    max_line_length = max(len(line.rstrip('\n')) for line in lines)
    width = max_line_length * font_size
    height = len(lines) * font_size

    image = Image.new("RGB", (width, height), color=image_bg_color)
    draw = ImageDraw.Draw(image)

    try:
        font = ImageFont.truetype(font_path, font_size)
    except:
        print("Warning: Unable to load font. Falling back to default font.")
        font = ImageFont.load_default()

    y = 0
    for line in lines:
        draw.text((0, y), line.rstrip('\n'), fill=text_color, font=font)
        y += font_size

    image.save(output_file)
    print(f"ASCII art has been converted to an image and saved as {output_file}.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("image", help="Path to the image file")
    parser.add_argument("-w", "--width", type=int, default=100, help="Width of ASCII art (default: 100)")
    parser.add_argument("-s", "--scale", type=float, default=1.0, help="Scale factor for higher resolution (default: 1.0)")
    parser.add_argument("--to-image", action="store_true", help="Convert ASCII art to an image")
    parser.add_argument("--font", type=str, default="arial.ttf", help="Font path for ASCII-to-image conversion")
    parser.add_argument("--font-size", type=int, default=12, help="Font size for ASCII-to-image conversion")
    parser.add_argument("--bg-color", type=str, default="black", help="Background color for ASCII-to-image conversion")
    parser.add_argument("--text-color", type=str, default="white", help="Text color for ASCII-to-image conversion")
    args = parser.parse_args()

    base_name = os.path.splitext(os.path.basename(args.image))[0]
    ascii_art = image_to_ascii(args.image, args.width, args.scale)

    if ascii_art:
        ascii_file = f"txt{base_name}.txt"
        with open(ascii_file, "w") as f:
            f.write(ascii_art)
        print(f"ASCII art saved to {ascii_file}")

        if args.to_image:
            output_image = f"img{base_name}.png"
            ascii_to_image(
                ascii_file,
                output_image,
                font_path=args.font,
                font_size=args.font_size,
                image_bg_color=args.bg_color,
                text_color=args.text_color,
            )
