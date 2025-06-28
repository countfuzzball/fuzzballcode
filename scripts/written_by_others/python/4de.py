import base64
import numpy as np
from PIL import Image
import reedsolo
from collections import Counter

def remove_error_correction(data, n, k):
    rs = reedsolo.RSCodec(n - k)
    return rs.decode(data)[0]  # Extract the corrected data from the tuple

def read_metadata_from_corners(image_array):
    length_bytes1 = image_array[:2, :2].flatten().tobytes()
    length_bytes2 = image_array[:2, -2:].flatten().tobytes()
    length_bytes3 = image_array[-2:, :2].flatten().tobytes()
    length_bytes4 = image_array[-2:, -2:].flatten().tobytes()
    
    return [length_bytes1, length_bytes2, length_bytes3, length_bytes4]

def most_common_length(lengths):
    length_counts = Counter(lengths)
    most_common_length = length_counts.most_common(1)[0][0]
    return int.from_bytes(most_common_length, byteorder='big')

def image_to_base64_with_error_correction(image_path, decoded_path, n=265, k=255):
    image = Image.open(image_path).convert('L')
    image_array = np.array(image)

    # Read the original data length from the metadata in the corners
    length_bytes_list = read_metadata_from_corners(image_array)
    original_data_length = most_common_length(length_bytes_list)

    # Debug: Log the original data length
    print(f"Original data length: {original_data_length}")

    # Calculate the data start index, considering the metadata length
    metadata_length = 4 * 2 * 2  # The length of the metadata in all four corners
    data_start_index = 0

    # Extract the data part from the image
    data_array = image_array.flatten()[data_start_index:data_start_index + original_data_length]
    
    # Debug: Check data array length
    print(f"Data array length: {len(data_array)}")

    try:
        decoded_data = remove_error_correction(data_array.tobytes(), n, k)
    except reedsolo.ReedSolomonError as e:
        print(f"Error during Reed-Solomon decoding: {e}")
        return

    encoded_data = base64.b64encode(decoded_data).decode('utf-8')
    with open(decoded_path, 'w') as decoded_file:
        decoded_file.write(encoded_data)

def base64_to_video(encoded_path, output_path):
    with open(encoded_path, 'r') as encoded_file:
        encoded_data = encoded_file.read()
    decoded_data = base64.b64decode(encoded_data.encode('utf-8'))
    with open(output_path, 'wb') as output_file:
        output_file.write(decoded_data)

# Example usage
image_to_base64_with_error_correction('output.png', 'decoded.txt')
base64_to_video('decoded.txt', 'output.mp4')
