FROM ywfwj2008/tengine:latest

MAINTAINER ywfwj2008 <ywfwj2008@163.com>

# Update base image
# Add sources for latest php5.5
# Install software requirements
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
	echo "deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" >> /etc/apt/sources.list.d/php.list && \
	echo "deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" >> /etc/apt/sources.list.d/php.list && \
	apt-get update && apt-get upgrade \
    apt-get install -y sendmail php5-fpm php5-curl php5-gd php5-imagick php5-mcrypt php5-mysql php5-sqlite php5-memcache php5-memcached

ADD ./php-fpm.conf /etc/php5/fpm/php-fpm.conf

# tweak php-fpm config
RUN sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" /etc/php5/fpm/php.ini && /
    sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /etc/php5/fpm/php.ini && /
    sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /etc/php5/fpm/php.ini && /
    sed -i 's@^short_open_tag = Off@short_open_tag = On@' /etc/php5/fpm/php.ini && /
    sed -i 's@^expose_php = On@expose_php = Off@' /etc/php5/fpm/php.ini && /
    sed -i 's@^request_order.*@request_order = "CGP"@' /etc/php5/fpm/php.ini && /
    sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /etc/php5/fpm/php.ini && /
    sed -i 's@^post_max_size.*@post_max_size = 100M@' /etc/php5/fpm/php.ini && /
    sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /etc/php5/fpm/php.ini && /
    sed -i 's@^max_execution_time.*@max_execution_time = 5@' /etc/php5/fpm/php.ini && /
    sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php5/fpm/php.ini && \
    [ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' /etc/php5/fpm/php.ini

RUN echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php

EXPOSE 80 443

#ENTRYPOINT ["/entrypoint.sh"]