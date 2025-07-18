import tensorflow
import cv2
import glob
import numpy
import os
from pathlib import Path

imported = tensorflow.saved_model.load(".")
imported = imported.signatures["serving_default"]

def predict(input_image):
    tensor = tensorflow.io.decode_image(input_image, channels=3)

    inference_shape = (240, 320)
    original_shape = tensor.shape[:2]

    input_tensor = tensorflow.expand_dims(tensor, axis=0)

    input_tensor = tensorflow.image.resize(input_tensor, inference_shape, preserve_aspect_ratio=True)
    saliency = imported(input_tensor)["output"]

    saliency = tensorflow.image.resize(saliency, original_shape)

    return postprocess_saliency_map(saliency[0], original_shape)

def postprocess_saliency_map(saliency_map, target_size):
    saliency_map *= 255.0

    saliency_map = tensorflow.round(saliency_map)
    saliency_map = tensorflow.cast(saliency_map, tensorflow.uint8)

    return saliency_map.numpy()

# Ensure the target directory exists
Path("/var/snapshots/heatmaps").mkdir(parents=True, exist_ok=True)

# Remove the existing heatmaps
print("Removing existing heatmaps...")
for filename in glob.glob('/var/snapshots/heatmaps/*.png'):
  os.remove(filename)

file_count = 0

# Loop through the snapshots and generate heatmaps
print("Generating heatmaps...")
for filename in glob.glob('/var/snapshots/*.png'):
  file_count += 1
  print(".", end="", flush=True)

  path = Path(filename)
  basename = path.stem + path.suffix

  # Crop the image to a reasonable screen size
  original_file = open(filename, "rb")
  original_raw = original_file.read()
  original = cv2.imdecode(numpy.frombuffer(original_raw, numpy.uint8), cv2.IMREAD_COLOR)
  if path.stem.endswith("_desktop"):
    original = original[0:1000, :, :]
  else:
    original = original[0:800, :, :]


  greyscale = predict(cv2.imencode(".png", original)[1].tobytes())
  heatmap = cv2.applyColorMap(greyscale, cv2.COLORMAP_JET)

  mask = cv2.cvtColor(greyscale,cv2.COLOR_GRAY2RGB)/350

  superimposed = (original * (1-mask) + heatmap * mask).astype(numpy.uint8)

  cv2.imwrite("/var/snapshots/heatmaps/" + basename, superimposed)

print("\n\nSimulated eye-tracking complete! %d files processed" % file_count)
