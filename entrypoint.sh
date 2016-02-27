#!/bin/bash
set -e

chmod +x /entrypoint.sh
exec service php-fpm start

#command="$@"
#${command}