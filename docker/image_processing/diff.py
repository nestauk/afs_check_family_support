import cv2
import io
import glob
import numpy
import os
from pathlib import Path
import sys

# Ensure the target directory exists
Path("/var/snapshots/diff").mkdir(parents=True, exist_ok=True)

# Remove the existing diff images
print("Removing existing diffs...")
files = glob.glob('/var/snapshots/diff/*.png')
files = files + glob.glob('/var/snapshots/diff/*.txt')
for filename in files:
  os.remove(filename)

file_count = 0
missing_files = 0
different_files = 0

# Loop through the snapshots and generate diffs
print("Processing diffs...")
for filename in glob.glob('/var/snapshots/*.png'):
  file_count += 1
  print(".", end="", flush=True)

  path = Path(filename)
  basename = path.stem + path.suffix

  baseline_path = Path("/var/snapshots/baseline/" + basename)
  if not baseline_path.is_file():
    missing_files += 1
    print("\n- Missing snapshot in baseline: " + basename)
    Path("/var/snapshots/diff/{0}_missing.txt".format(path.stem)).touch()
  else:
    original_file = open(filename, "rb")
    original_raw = original_file.read()
    original = cv2.imdecode(numpy.frombuffer(original_raw, numpy.uint8), cv2.IMREAD_COLOR)

    baseline_file = open("/var/snapshots/baseline/" + basename, "rb")
    baseline_raw = baseline_file.read()
    baseline = cv2.imdecode(numpy.frombuffer(baseline_raw, numpy.uint8), cv2.IMREAD_COLOR)

    maxWidth = max(original.shape[0], baseline.shape[0])
    maxHeight = max(original.shape[1], baseline.shape[1])

    original = numpy.pad(original, ((0, maxWidth - original.shape[0]), (0, maxHeight - original.shape[1]), (0, 0)), mode='constant', constant_values=128)
    baseline = numpy.pad(baseline, ((0, maxWidth - baseline.shape[0]), (0, maxHeight - baseline.shape[1]), (0, 0)), mode='constant', constant_values=0)

    diff = cv2.cvtColor(cv2.absdiff(original, baseline), cv2.COLOR_RGB2GRAY)

    # Add a lower threshold to the diff
    diff = (diff > 10) * diff

    # Only create a diff if there are differences
    if numpy.any(diff):
      different_files += 1
      print("\n- Difference found: " + basename)

      # Emphasise differences in the diff
      diff = cv2.multiply(diff, 3)
      diff_rgb = cv2.cvtColor(diff, cv2.COLOR_GRAY2RGB)

      diff_r = diff_rgb.copy()
      diff_r[..., 0] = 0
      diff_r[..., 1] = 0

      superimposed = original * (diff_rgb < 1) + diff_r

      cv2.imwrite("/var/snapshots/diff/" + basename, superimposed)

print("\n\nDiff complete! %d files compared, %d missing, %d different" % (file_count, missing_files, different_files))
