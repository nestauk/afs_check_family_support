#!/usr/bin/env bash

if [ ! -f "/var/source/saved_model.pb" ]
  then
    wget -O /var/source/saved_model.pb 'https://huggingface.co/JackVines/ds_saliency_inference/resolve/main/app/saved_model.pb'
fi

# Keep the container running in the background
sleep infinity
