import tensorflow as tf
from PIL import Image
import cv2
import io
import glob
import numpy
import os
from pathlib import Path
import sys

imported = tf.saved_model.load(".")
imported = imported.signatures["serving_default"]

def predict(input_image):
    tensor = tf.io.decode_image(input_image, channels=3)

    inference_shape = (240, 320)
    original_shape = tensor.shape[:2]

    input_tensor = tf.expand_dims(tensor, axis=0)

    input_tensor = tf.image.resize(input_tensor, inference_shape, preserve_aspect_ratio=True)
    saliency = imported(input_tensor)["output"]

    saliency = tf.image.resize(saliency, original_shape)

    return postprocess_saliency_map(saliency[0], original_shape)

def postprocess_saliency_map(saliency_map, target_size):
    saliency_map *= 255.0

    saliency_map = tf.round(saliency_map)
    saliency_map = tf.cast(saliency_map, tf.uint8)

    return saliency_map.numpy()

# Ensure the target directory exists
Path("/var/snapshots/heatmaps").mkdir(parents=True, exist_ok=True)

# Remove the existing baseline images
for filename in glob.glob('/var/snapshots/heatmaps/*.png'):
  os.remove(filename)

# Loop through the snapshots and generate heatmaps
for filename in glob.glob('/var/snapshots/*.png'):
  path = Path(filename)
  basename = path.stem + path.suffix
  print("Processing " + basename)

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

  superimposed = original * (1-mask) + heatmap * mask

  cv2.imwrite("/var/snapshots/heatmaps/" + basename, superimposed)
