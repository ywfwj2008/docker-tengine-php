FROM ywfwj2008/tengine:latest
MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV PHP_INSTALL_DIR=/usr/local/php \
    RUN_USER=www \
    PHP_VERSION=5.4.45 \
    IMAGICK_VERSION=3.4.3RC1 \
    MEMCACHE_PECL_VERSION=3.0.8 \
    LIBMEMCACHED_VERSION=1.0.18 \
    MEMCACHED_PECL_VERSION=2.2.0 \
    REDIS_PECL_VERSION=2.2.8 \
    SWOOLE_VERSION=1.8.7

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates wget gcc g++ make cmake autoconf patch pkg-config sendmail openssl libxslt-dev libicu-dev libssl-dev curl libcurl4-openssl-dev libxml2 libxml2-dev libjpeg-dev libpng12-dev libpng3 libfreetype6 libfreetype6-dev libsasl2-dev  && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# install php
RUN wget -c --no-check-certificate http://www.php.net/distributions/php-$PHP_VERSION.tar.gz && \
    tar xzf php-$PHP_VERSION.tar.gz && \
    wget -c --no-check-certificate http://mirrors.linuxeye.com/oneinstack/src/fpm-race-condition.patch && \
    patch -d php-$PHP_VERSION -p0 < fpm-race-condition.patch && \
    cd php-$PHP_VERSION && \
    ./configure --prefix=$PHP_INSTALL_DIR --with-config-file-path=$PHP_INSTALL_DIR/etc \
    --with-config-file-scan-dir=$PHP_INSTALL_DIR/etc/php.d \
    --with-fpm-user=$RUN_USER --with-fpm-group=$RUN_USER --enable-fpm \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug && \
    make ZEND_EXTRA_LIBS='-liconv' && \
    make install && \
    mkdir -p $PHP_INSTALL_DIR/etc/php.d && \
    /bin/cp php.ini-production $PHP_INSTALL_DIR/etc/php.ini && \
    /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && \
    chmod +x /etc/init.d/php-fpm && \
    update-rc.d php-fpm defaults && \
    ln -s $PHP_INSTALL_DIR/bin/php /usr/local/bin/php && \
    rm -rf /tmp/*

# add php-fpm.conf
ADD php-fpm.conf $PHP_INSTALL_DIR/etc/php-fpm.conf

# install ImageMagick
RUN wget -c --no-check-certificate http://www.imagemagick.org/download/ImageMagick.tar.gz && \
    tar xzf ImageMagick.tar.gz && \
    cd ImageMagick* && \
    ./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static && \
    make && make install && \
    cd .. && \
    wget -c --no-check-certificate http://pecl.php.net/get/imagick-$IMAGICK_VERSION.tgz && \
    tar xzf imagick-$IMAGICK_VERSION.tgz && \
    cd imagick-$IMAGICK_VERSION && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config --with-imagick=/usr/local/imagemagick && \
    make && make install && \
    rm -rf /tmp/*

# install php-memcache
RUN wget -c --no-check-certificate http://pecl.php.net/get/memcache-$MEMCACHE_PECL_VERSION.tgz && \
    tar xzf memcache-$MEMCACHE_PECL_VERSION.tgz && \
    cd memcache-$MEMCACHE_PECL_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install && \
    rm -rf /tmp/*

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
    make && make install && \
    rm -rf /tmp/*

# install php-redis
RUN wget -c --no-check-certificate http://pecl.php.net/get/redis-$REDIS_PECL_VERSION.tgz && \
    tar xzf redis-$REDIS_PECL_VERSION.tgz && \
    cd redis-$REDIS_PECL_VERSION && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config && \
    make && make install && \
    rm -rf /tmp/*

# install swoole
RUN wget -c --no-check-certificate https://github.com/swoole/swoole-src/archive/$SWOOLE_VERSION-stable.tar.gz && \
    tar xzf $SWOOLE_VERSION-stable.tar.gz && \
    cd swoole-src-$SWOOLE_VERSION-stable && \
    $PHP_INSTALL_DIR/bin/phpize && \
    ./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config --enable-async-mysql --enable-jemalloc && \
    make && make install && \
    rm -rf /tmp/*

# run install script
ADD ./install.sh /tmp/install.sh
RUN chmod 777 install.sh && \
    bash install.sh && \
    rm -rf /tmp/*

# install composer
RUN curl -sS https://getcomposer.org/installer | $PHP_INSTALL_DIR/bin/php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer

WORKDIR /home/wwwroot

# expose port
EXPOSE 80 443

# Set the entrypoint script.
ADD ./entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Define the default command.
CMD ["nginx", "-g", "daemon off;"]
