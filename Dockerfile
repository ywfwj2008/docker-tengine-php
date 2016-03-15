FROM ywfwj2008/tengine:latest
MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV PHP_INSTALL_DIR=/usr/local/php
ENV RUN_USER=www
ENV LIBICONV_VERSION=1.14
ENV LIBMCRYPT_VERSION=2.5.8
ENV MHASH_VERSION=0.9.9.9
ENV MCRYPT_VERSION=2.6.8
ENV PHP_5_VERSION=5.5.33
ENV ZENDOPCACHE_VERSION=7.0.5
ENV IMAGEMAGICK_VERSION=6.9.3-7
ENV IMAGICK_VERSION=3.4.1
ENV MEMCACHE_PECL_VERSION=3.0.8
ENV LIBMEMCACHED_VERSION=1.0.18
ENV MEMCACHED_PECL_VERSION=2.2.0
ENV REDIS_PECL_VERSION=2.2.7

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates wget gcc g++ make cmake autoconf patch pkg-config sendmail openssl libxslt-dev libicu-dev libssl-dev curl libcurl4-openssl-dev libxml2 libxml2-dev libjpeg-dev libpng12-dev libpng3 libfreetype6 libfreetype6-dev libsasl2-dev

WORKDIR /tmp

# install libiconv
ADD ./patch/libiconv-glibc-2.16.patch /tmp/libiconv-glibc-2.16.patch
RUN wget -c --no-check-certificate http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz && \
    tar xzf libiconv-$LIBICONV_VERSION.tar.gz && \
    patch -d libiconv-$LIBICONV_VERSION -p0 < libiconv-glibc-2.16.patch && \
    cd libiconv-$LIBICONV_VERSION && \
    ./configure --prefix=/usr/local && \
    make && make install

# install mhash
RUN wget -c --no-check-certificate http://downloads.sourceforge.net/project/mhash/mhash/$MHASH_VERSION/mhash-$MHASH_VERSION.tar.gz && \
    tar xzf mhash-$MHASH_VERSION.tar.gz && \
    cd mhash-$MHASH_VERSION && \
    ./configure && \
    make && make install

# install libmcrypt
RUN wget -c --no-check-certificate http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/$LIBMCRYPT_VERSION/libmcrypt-$LIBMCRYPT_VERSION.tar.gz && \
    tar xzf libmcrypt-$LIBMCRYPT_VERSION.tar.gz && \
    cd libmcrypt-$LIBMCRYPT_VERSION && \
    ./configure && \
    make && make install && \
    ldconfig && \
    cd libltdl && \
    ./configure --enable-ltdl-install && \
    make && make install

# install mcrypt
RUN wget -c --no-check-certificate http://downloads.sourceforge.net/project/mcrypt/MCrypt/$MCRYPT_VERSION/mcrypt-$MCRYPT_VERSION.tar.gz && \
    tar xzf mcrypt-$MCRYPT_VERSION.tar.gz && \
    cd mcrypt-$MCRYPT_VERSION && \
    ldconfig && \
    ./configure && \
    make && make install

# install php5
ADD ./patch/fpm-race-condition.patch /tmp/fpm-race-condition.patch
RUN wget -c --no-check-certificate http://www.php.net/distributions/php-$PHP_5_VERSION.tar.gz && \
    tar xzf php-$PHP_5_VERSION.tar.gz && \
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
    make install && \
    /bin/cp php.ini-production $PHP_INSTALL_DIR/etc/php.ini && \
    /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && \
    chmod +x /etc/init.d/php-fpm && \
    update-rc.d php-fpm defaults

# add php-fpm.conf
ADD php-fpm.conf $PHP_INSTALL_DIR/etc/php-fpm.conf

# install zendopcache
RUN wget -c --no-check-certificate https://pecl.php.net/get/zendopcache-$ZENDOPCACHE_VERSION.tgz && \
    tar xzf zendopcache-$ZENDOPCACHE_VERSION.tgz && \
    cd zendopcache-$ZENDOPCACHE_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install

# install ImageMagick
RUN wget -c --no-check-certificate http://www.imagemagick.org/download/ImageMagick-$IMAGEMAGICK_VERSION.tar.gz && \
    tar xzf ImageMagick-$IMAGEMAGICK_VERSION.tar.gz && \
    cd ImageMagick-$IMAGEMAGICK_VERSION && \
    ./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static && \
    make && make install && \
    cd .. && \
    wget -c --no-check-certificate http://pecl.php.net/get/imagick-$IMAGICK_VERSION.tgz && \
    tar xzf imagick-$IMAGICK_VERSION.tgz && \
    cd imagick-$IMAGICK_VERSION && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config --with-imagick=/usr/local/imagemagick && \
    make && make install

# install php-memcache
RUN wget -c --no-check-certificate http://pecl.php.net/get/memcache-$MEMCACHE_PECL_VERSION.tgz && \
    tar xzf memcache-$MEMCACHE_PECL_VERSION.tgz && \
    cd memcache-$MEMCACHE_PECL_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install

# install php-memcached
RUN wget -c --no-check-certificate https://launchpad.net/libmemcached/1.0/$LIBMEMCACHED_VERSION/+download/libmemcached-$LIBMEMCACHED_VERSION.tar.gz && \
    tar xzf libmemcached-$LIBMEMCACHED_VERSION.tar.gz && \
    cd libmemcached-$LIBMEMCACHED_VERSION && \
    sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure && \
    ./configure && \
    make && make install && \
    cd .. && \
    wget -c --no-check-certificate http://pecl.php.net/get/memcached-$MEMCACHED_PECL_VERSION.tgz && \
    tar xzf memcached-$MEMCACHED_PECL_VERSION.tgz && \
    cd memcached-$MEMCACHED_PECL_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install

#install php-redis
RUN wget -c --no-check-certificate http://pecl.php.net/get/redis-$REDIS_PECL_VERSION.tgz && \
    tar xzf redis-$REDIS_PECL_VERSION.tgz && \
    cd redis-$REDIS_PECL_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install

# run install script
ADD ./install.sh /tmp/install.sh
RUN chmod 777 install.sh && \
    bash install.sh && \
    echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php && \
    rm -rf /tmp/*

# expose port
EXPOSE 80 443

# Set the entrypoint script.
ADD ./entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh && \
ENTRYPOINT ["/entrypoint.sh"]

# Define the default command.
CMD ["nginx", "-g", "daemon off;"]
