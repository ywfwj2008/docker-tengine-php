FROM ywfwj2008/tengine:latest

MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV PHP_ETC_DIR=/etc/php5/fpm

# Update base image
# Add sources for latest php5.5
# Install software requirements
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
	echo "deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" >> /etc/apt/sources.list.d/php.list && \
	echo "deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" >> /etc/apt/sources.list.d/php.list && \
	apt-get update && apt-get upgrade -y && \
    apt-get install -y sendmail php5-fpm php5-curl php5-xmlrpc php5-xsl php5-gd php5-imagick php5-mcrypt php5-mysql php5-sqlite php5-memcache php5-memcached

# edit php-fpm.conf
ADD php-fpm.conf $PHP_ETC_DIR/php-fpm.conf
RUN sed -i "s@^pm.max_children.*@pm.max_children = 60@" $PHP_ETC_DIR/php-fpm.conf && \
    sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" $PHP_ETC_DIR/php-fpm.conf && \
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" $PHP_ETC_DIR/php-fpm.conf && \
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" $PHP_ETC_DIR/php-fpm.conf

# ending
RUN echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php
EXPOSE 80 443
#ENTRYPOINT ["/entrypoint.sh"]