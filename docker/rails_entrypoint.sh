#!/bin/bash

if [[ -t 0 ]]
 then
    # interactive
    exec bash
    exit 0
fi


# Clear logs
: > log/development.log
: > log/test.log

# Remove test artefacts
rm -rf tmp/screenshots/*

# Remove server lock file
rm -f /var/source/tmp/pids/*.pid

# Ensure the correct dependencies are installed
if ! bundler check | grep "The Gemfile's dependencies are satisfied"
  then
    bundler install
fi

/var/source/bin/rails server -b 0.0.0.0
