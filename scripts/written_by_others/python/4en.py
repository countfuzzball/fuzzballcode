import base64
import numpy as np
from PIL import Image, ImageDraw
import reedsolo

def add_error_correction(data, n, k):
    rs = reedsolo.RSCodec(n - k)
    return rs.encode(data)

def video_to_base64(input_path, encoded_path):
    with open(input_path, 'rb') as input_file:
        video_data = input_file.read()
        encoded_data = base64.b64encode(video_data).decode('utf-8')
    with open(encoded_path, 'w') as encoded_file:
        encoded_file.write(encoded_data)

def base64_to_image_with_error_correction(encoded_path, image_path, n=265, k=255):
    with open(encoded_path, 'r') as encoded_file:
        encoded_data = encoded_file.read()
    decoded_data = base64.b64decode(encoded_data.encode('utf-8'))
    encoded_with_ec = add_error_correction(decoded_data, n, k)
    original_data_length = len(encoded_with_ec)

    # Convert the original data length to bytes
    length_bytes = original_data_length.to_bytes(4, byteorder='big')
    length_array = np.frombuffer(length_bytes, dtype=np.uint8)

    data_array = np.frombuffer(encoded_with_ec, dtype=np.uint8)
    metadata_length = 4 * len(length_array)  # Total bytes needed for metadata in four corners
    total_length = len(data_array) + metadata_length
    image_side = int(np.ceil(np.sqrt(total_length)))

    # Ensure that the total length fits exactly into the image
    padded_length = image_side**2 - metadata_length
    padded_array = np.pad(data_array, (0, padded_length - len(data_array)), 'constant', constant_values=0)

    image_array = np.zeros(image_side**2, dtype=np.uint8)
    image_array[:len(padded_array)] = padded_array

    # Embed metadata in all four corners
    length_reshaped = length_array.reshape((2, 2))
    image_matrix = image_array.reshape((image_side, image_side))
    image_matrix[:2, :2] = length_reshaped
    image_matrix[:2, -2:] = length_reshaped
    image_matrix[-2:, :2] = length_reshaped
    image_matrix[-2:, -2:] = length_reshaped

    image = Image.fromarray(image_matrix, mode='L')
    image.save(image_path, format='PNG')

# Example usage
video_to_base64('input.mp4', 'encoded.txt')
base64_to_image_with_error_correction('encoded.txt', 'output.png')
