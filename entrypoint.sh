#!/bin/bash
set -e

# reset memory
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -le 640 ];then
    MEMORY_LIMIT=64
elif [ $Mem -gt 640 -a $Mem -le 1280 ];then
    MEMORY_LIMIT=128
elif [ $Mem -gt 1280 -a $Mem -le 2500 ];then
    MEMORY_LIMIT=192
elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
    MEMORY_LIMIT=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
    MEMORY_LIMIT=320
elif [ $Mem -gt 4500 -a $Mem -le 8000 ];then
    MEMORY_LIMIT=384
elif [ $Mem -gt 8000 ];then
    MEMORY_LIMIT=448
fi

# optimize php-fpm
if [ $Mem -le 3000 ];then
    sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
    sed -i "s@^pm.max_children.*@pm.max_children = 50@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.start_servers.*@pm.start_servers = 30@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@" $PHP_INSTALL_DIR/etc/php-fpm.conf
elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
    sed -i "s@^pm.max_children.*@pm.max_children = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf
elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
    sed -i "s@^pm.max_children.*@pm.max_children = 70@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@" $PHP_INSTALL_DIR/etc/php-fpm.conf
elif [ $Mem -gt 8500 ];then
    sed -i "s@^pm.max_children.*@pm.max_children = 80@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" $PHP_INSTALL_DIR/etc/php-fpm.conf
    sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" $PHP_INSTALL_DIR/etc/php-fpm.conf
fi

# optimize php.ini
sed -i "s@^memory_limit.*@memory_limit = ${MEMORY_LIMIT}M@" $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 100M@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 5@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' $PHP_INSTALL_DIR/etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $PHP_INSTALL_DIR/etc/php.ini

# change php.ini about zendopcache
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/opcache.so" ];then
    sed -i 's@^\[opcache\]@[opcache]\nzend_extension=opcache.so@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.enable=.*@opcache.enable=1@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i "s@^;opcache.memory_consumption.*@opcache.memory_consumption=$MEMORY_LIMIT@" $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.interned_strings_buffer.*@opcache.interned_strings_buffer=8@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.max_accelerated_files.*@opcache.max_accelerated_files=4000@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.revalidate_freq.*@opcache.revalidate_freq=60@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.save_comments.*@opcache.save_comments=0@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.fast_shutdown.*@opcache.fast_shutdown=1@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.enable_cli.*@opcache.enable_cli=1@' $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^;opcache.optimization_level.*@;opcache.optimization_level=0@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about imagick
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/imagick.so" ];then
    sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$PHP_INSTALL_DIR/bin/php-config --extension-dir`\"@" $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "imagick.so"@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about memcache
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/memcache.so" ];then
    sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$PHP_INSTALL_DIR/bin/php-config --extension-dir`\"@" $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' $PHP_INSTALL_DIR/etc/php.ini
fi

# change php.ini about memcached
if [ -f "`$PHP_INSTALL_DIR/bin/php-config --extension-dir`/memcached.so" ];then
    sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$PHP_INSTALL_DIR/bin/php-config --extension-dir`\"@" $PHP_INSTALL_DIR/etc/php.ini
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"\nmemcached.use_sasl = 1@' $PHP_INSTALL_DIR/etc/php.ini
fi

service php-fpm start

exec "$@"
