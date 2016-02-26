FROM ywfwj2008/tengine:latest
MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV LIBICONV_VERSION=1.14
ENV LIBMCRYPT_VERSION=2.5.8
ENV MHASH_VERSION=0.9.9.9
ENV MCRYPT_VERSION=2.6.8
ENV PHP_5_VERSION=5.5.32
ENV PHP_INSTALL_DIR=/usr/local/php
ENV RUN_USER=www
ENV MEMORY_LIMIT=256

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates wget gcc g++ make cmake autoconf patch pkg-config sendmail openssl libxslt-dev libicu-dev libssl-dev curl libcurl4-openssl-dev libxml2 libxml2-dev libjpeg-dev libpng12-dev libpng3 libfreetype6 libfreetype6-dev

WORKDIR /tmp
RUN wget -c --no-check-certificate http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz && \
    wget -c --no-check-certificate http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/$LIBMCRYPT_VERSION/libmcrypt-$LIBMCRYPT_VERSION.tar.gz && \
    wget -c --no-check-certificate http://downloads.sourceforge.net/project/mhash/mhash/$MHASH_VERSION/mhash-$MHASH_VERSION.tar.gz && \
    wget -c --no-check-certificate http://downloads.sourceforge.net/project/mcrypt/MCrypt/$MCRYPT_VERSION/mcrypt-$MCRYPT_VERSION.tar.gz && \
    wget -c --no-check-certificate http://mirrors.linuxeye.com/oneinstack/src/fpm-race-condition.patch && \
    wget -c --no-check-certificate http://www.php.net/distributions/php-$PHP_5_VERSION.tar.gz

ADD libiconv-glibc-2.16.patch /tmp
ADD fpm-race-condition.patch /tmp

RUN tar xzf libiconv-$LIBICONV_VERSION.tar.gz && \
    patch -d libiconv-$LIBICONV_VERSION -p0 < libiconv-glibc-2.16.patch && \
    cd libiconv-$LIBICONV_VERSION && \
    ./configure --prefix=/usr/local && \
    make && make install

RUN tar xzf libmcrypt-$LIBMCRYPT_VERSION.tar.gz && \
    cd libmcrypt-$LIBMCRYPT_VERSION && \
    ./configure && \
    make && make install && \
    ldconfig && \
    cd libltdl && \
    ./configure --enable-ltdl-install && \
    make && make install

RUN tar xzf mhash-$MHASH_VERSION.tar.gz && \
    cd mhash-$MHASH_VERSION && \
    ./configure && \
    make && make install

RUN tar xzf mcrypt-$MCRYPT_VERSION.tar.gz && \
    cd mcrypt-$MCRYPT_VERSION && \
    ldconfig && \
    ./configure && \
    make && make install

RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && \
    ldconfig

RUN tar xzf php-$PHP_5_VERSION.tar.gz && \
    patch -d php-$PHP_5_VERSION -p0 < fpm-race-condition.patch && \
    cd php-$PHP_5_VERSION && \
    ./configure --prefix=$PHP_INSTALL_DIR --with-config-file-path=$PHP_INSTALL_DIR/etc \
    --with-fpm-user=$RUN_USER --with-fpm-group=$RUN_USER --enable-fpm --enable-opcache --disable-fileinfo \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-inline-optimization \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug && \
    make ZEND_EXTRA_LIBS='-liconv' && \
    make install

RUN cd php-$PHP_5_VERSION && \
    /bin/cp php.ini-production $PHP_INSTALL_DIR/etc/php.ini && \
    /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && \
    chmod +x /etc/init.d/php-fpm && \
    update-rc.d php-fpm defaults

# edit php-fpm.conf
ADD php-fpm.conf $PHP_INSTALL_DIR/etc/php-fpm.conf
RUN sed -i "s@^pm.max_children.*@pm.max_children = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf && \
    sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" $PHP_INSTALL_DIR/etc/php-fpm.conf && \
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" $PHP_INSTALL_DIR/etc/php-fpm.conf && \
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf

# edit php.ini
RUN sed -i "s@^memory_limit.*@memory_limit = ${MEMORY_LIMIT}M@" $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^short_open_tag = Off@short_open_tag = On@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^expose_php = On@expose_php = Off@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^request_order.*@request_order = "CGP"@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^post_max_size.*@post_max_size = 100M@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^max_execution_time.*@max_execution_time = 5@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' $PHP_INSTALL_DIR/etc/php.ini && \
    [ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $PHP_INSTALL_DIR/etc/php.ini

# install zendopcache
ENV ZENDOPCACHE_VERSION=7.0.5
RUN wget -c --no-check-certificate https://pecl.php.net/get/zendopcache-$ZENDOPCACHE_VERSION.tgz && \
    tar xzf zendopcache-$ZENDOPCACHE_VERSION.tgz && \
    cd zendopcache-$ZENDOPCACHE_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install

RUN sed -i 's@^\[opcache\]@[opcache]\nzend_extension=opcache.so@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.enable=.*@opcache.enable=1@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i "s@^;opcache.memory_consumption.*@opcache.memory_consumption=$MEMORY_LIMIT@" $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.interned_strings_buffer.*@opcache.interned_strings_buffer=8@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.max_accelerated_files.*@opcache.max_accelerated_files=4000@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.revalidate_freq.*@opcache.revalidate_freq=60@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.save_comments.*@opcache.save_comments=0@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.fast_shutdown.*@opcache.fast_shutdown=1@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.enable_cli.*@opcache.enable_cli=1@' $PHP_INSTALL_DIR/etc/php.ini && \
    sed -i 's@^;opcache.optimization_level.*@;opcache.optimization_level=0@' $PHP_INSTALL_DIR/etc/php.ini

RUN echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php
EXPOSE 80 443
#ENTRYPOINT ["/entrypoint.sh"]
