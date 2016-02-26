FROM ywfwj2008/tengine:latest

MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV PHP_ETC_DIR=/etc/php5/fpm
ENV RUN_USER=www
ENV MEMORY_LIMIT=256

# Update base image
# Add sources for latest php5.5
# Install software requirements
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
	echo "deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" >> /etc/apt/sources.list.d/php.list && \
	echo "deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" >> /etc/apt/sources.list.d/php.list && \
	apt-get update && apt-get upgrade -y && \
    apt-get install -y sendmail php5-fpm php5-curl php5-xmlrpc php5-xsl php5-gd php5-imagick php5-mcrypt php5-mysql php5-sqlite php5-memcache php5-memcached

# add php-fpm config file
RUN cat > $PHP_ETC_DIR/php-fpm.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning

emergency_restart_threshold = 30
emergency_restart_interval = 60s
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[$RUN_USER]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = $RUN_USER
listen.group = $RUN_USER
listen.mode = 0666
user = $RUN_USER
group = $RUN_USER

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

pm.status_path = /php-fpm_status
slowlog = log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

# tweak php-fpm config
RUN sed -i "s@^pm.max_children.*@pm.max_children = 60@" $PHP_ETC_DIR/php-fpm.conf && \
    sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" $PHP_ETC_DIR/php-fpm.conf && \
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" $PHP_ETC_DIR/php-fpm.conf && \
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" $PHP_ETC_DIR/php-fpm.conf

RUN echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php
EXPOSE 80 443
#ENTRYPOINT ["/entrypoint.sh"]