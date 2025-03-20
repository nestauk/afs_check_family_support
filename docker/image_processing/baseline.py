import glob
import os
from pathlib import Path
import sys

# Ensure the target directory exists
Path("/var/snapshots/baseline").mkdir(parents=True, exist_ok=True)

# Remove the existing baseline images
print("Removing existing baseline images...")
for filename in glob.glob('/var/snapshots/baseline/*.png'):
  os.remove(filename)

file_count = 0

# Loop through the snapshots and copy to the baseline
print("Copying new baseline...")
for filename in glob.glob('/var/snapshots/*.png'):
  file_count += 1
  print(".", end="", flush=True)

  path = Path(filename)
  filename = path.stem + path.suffix

  os.system("cp '/var/snapshots/{0}' '/var/snapshots/baseline/{0}'".format(filename))

print("\n\nBaseline complete! %d files baselined" % file_count)
