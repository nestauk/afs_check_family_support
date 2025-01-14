import glob
import os
from pathlib import Path
import sys

# Ensure the target directory exists
Path("/var/snapshots/baseline").mkdir(parents=True, exist_ok=True)

# Remove the existing baseline images
for filename in glob.glob('/var/snapshots/baseline/*.png'):
  os.remove(filename)

# Loop through the snapshots and copy to the baseline
for filename in glob.glob('/var/snapshots/*.png'):
  path = Path(filename)
  filename = path.stem + path.suffix

  os.system("cp '/var/snapshots/{0}' '/var/snapshots/baseline/{0}'".format(filename))
