#!/bin/bash

# optimize php.ini
sed -i "s@^memory_limit.*@memory_limit = 192M@" $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 100M@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 5@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,popen@' $PHP_INSTALL_DIR/etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $PHP_INSTALL_DIR/etc/php.ini

# change php.ini about zendopcache
if [ 1 == 1 ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.memory_consumption=192
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
fi

sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$PHP_INSTALL_DIR/bin/php-config --extension-dir`\"@" $PHP_INSTALL_DIR/etc/php.ini

# change php.ini about imagick
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/imagick.so" ];then
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "imagick.so"@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about memcache
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/memcache.so" ];then
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about memcached
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/memcached.so" ];then
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"\nmemcached.use_sasl = 1@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about redis
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/redis.so" ];then
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "redis.so"@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about swoole
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/swoole.so" ];then
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "swoole.so"@' $PHP_INSTALL_DIR/etc/php.ini
fi

# install ZendGuardLoader
wget -c http://mirrors.linuxeye.com/oneinstack/src/zend-loader-php5.6-linux-x86_64.tar.gz -P /tmp
tar xzf /tmp/zend-loader-php5.6-linux-x86_64.tar.gz
cp /tmp/zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so `$PHP_INSTALL_DIR/bin/php-config --extension-dir`
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/ZendGuardLoader.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-zendGuardLoader.ini << EOF
[Zend Guard Loader]
zend_extension=`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
fi

# install ioncube
wget -c http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -P /tmp
tar xzf /tmp/ioncube_loaders_lin_x86-64.tar.gz
cp /tmp/ioncube/ioncube_loader_lin_5.6.so `$PHP_INSTALL_DIR/bin/php-config --extension-dir`
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/ioncube_loader_lin_5.6.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-ioncube.ini << EOF
[ionCube Loader]
zend_extension=`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/ioncube_loader_lin_5.6.so
EOF
fi

# white default index.html
echo "Hello World!" > /home/wwwroot/default/index.html
echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php
