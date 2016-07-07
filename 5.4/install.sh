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

sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$PHP_INSTALL_DIR/bin/php-config --extension-dir`\"@" $PHP_INSTALL_DIR/etc/php.ini

# imagick
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/imagick.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-imagick.ini << EOF
extension=imagick.so
EOF
fi

# memcache
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/memcache.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-memcache.ini << EOF
extension=memcache.so
EOF
fi

# memcached
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/memcached.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF
fi

# redis
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/redis.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-redis.ini << EOF
extension=redis.so
EOF
fi

# swoole
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/swoole.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-swoole.ini << EOF
extension=swoole.so
EOF
fi

# install ZendGuardLoader
wget -c http://mirrors.linuxeye.com/oneinstack/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz -P /tmp
tar xzf /tmp/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
cp /tmp/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so `$PHP_INSTALL_DIR/bin/php-config --extension-dir`
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
cp /tmp/ioncube/ioncube_loader_lin_5.4.so `$PHP_INSTALL_DIR/bin/php-config --extension-dir`
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/ioncube_loader_lin_5.4.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-ioncube.ini << EOF
[ionCube Loader]
zend_extension=`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/ioncube_loader_lin_5.4.so
EOF
fi

# white default index.html
echo "Hello World!" > /home/wwwroot/default/index.html
echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php