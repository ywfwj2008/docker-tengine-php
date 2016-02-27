#!/bin/bash
set -e

service php-fpm start

# Copy a default configuration into place if not present
if ! [ -f /usr/local/tengine/conf/nginx.conf ]; then
  echo "daemon off;" >> "/usr/local/tengine/conf/nginx.conf"
fi

command="$@"

${command}