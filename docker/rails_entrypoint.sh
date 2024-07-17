#!/bin/bash

# Ensure the correct dependencies are installed
if ! bundler check | grep "The Gemfile's dependencies are satisfied"
  then
    bundler install
fi

# Remove server lock file
rm /var/source/tmp/pids/server.pid

/var/source/bin/rails server -b 0.0.0.0
