from PIL import Image, ImageDraw, ImageFont

# Function to convert ASCII art to an image
def ascii_to_image(input_file, output_file, font_path="arial.ttf", font_size=12, image_bg_color="black", text_color="white"):
    """
    Convert ASCII art to an image.

    :param input_file: Path to the ASCII art file
    :param output_file: Path to save the output image
    :param font_path: Path to a TrueType font file
    :param font_size: Size of the font
    :param image_bg_color: Background color of the image
    :param text_color: Color of the ASCII text
    """
    # Load the ASCII art from the file
    with open(input_file, "r") as f:
        lines = f.readlines()

    # Determine the image size based on the text dimensions
    max_line_length = max(len(line.rstrip('\n')) for line in lines)
    width = max_line_length * font_size
    height = len(lines) * font_size

    # Create an image with a background color
    image = Image.new("RGB", (width, height), color=image_bg_color)
    draw = ImageDraw.Draw(image)

    # Load the font
    try:
        font = ImageFont.truetype(font_path, font_size)
    except:
        print("Warning: Unable to load font. Falling back to default font.")
        font = ImageFont.load_default()

    # Draw the text onto the image
    y = 0
    for line in lines:
        draw.text((0, y), line.rstrip('\n'), fill=text_color, font=font)
        y += font_size

    # Save the image
    image.save(output_file)
    print(f"ASCII art has been converted to an image and saved as {output_file}.")

# Example usage
if __name__ == "__main__":
    input_file = "ascii_art.txt"  # Path to the ASCII art file
    output_file = "ascii_art_image.png"  # Path to save the output image

    # Customize font path if necessary
    font_path = "arial.ttf"  # Change to a valid font file path on your system

    ascii_to_image(input_file, output_file, font_path=font_path)
