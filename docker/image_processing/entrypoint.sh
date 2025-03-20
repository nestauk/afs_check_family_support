#!/usr/bin/env bash

if [ ! -f "/var/source/saved_model.pb" ]
  then
    wget -O /var/source/saved_model.pb 'https://huggingface.co/JackVines/ds_saliency_inference/resolve/main/app/saved_model.pb'
fi

pip install --root-user-action=ignore --disable-pip-version-check tensorflow opencv-python-headless | grep -v "^Requirement already satisfied"

# Run the given command
exec "$@"
