#!/bin/bash
set -e

# Copy a default configuration into place if not present
echo "daemon off;" >> "/usr/local/tengine/conf/nginx.conf"

command="$@"

${command}