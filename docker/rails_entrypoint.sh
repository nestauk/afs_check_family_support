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
bundle install
npm install
/var/source/bin/rails db:migrate

/var/source/bin/rails server -b 0.0.0.0
