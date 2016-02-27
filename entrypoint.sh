#!/bin/bash
set -e

exec service php-fpm start

#command="$@"
#${command}