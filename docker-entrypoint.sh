#!/bin/bash
set -e

# Run any additional script hooks.
find /usr/local/bin/docker-hook-scripts.d/ -name "*.sh" -type f | while read SCRIPT; do
  echo "Running $SCRIPT"
  $SCRIPT
done

#call original entry point
echo "Start PHP Service"
docker-php-entrypoint --apache-foreground
