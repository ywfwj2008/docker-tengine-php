# docker-php-nginx

    Nginx(Tengine) + PHP
    ImageMagick + ZendOpcache
    Memcache + Memcached + Redis
    ZendGuardLoader + ionCube
    Swoole + Workman

## usage

### run wish mysql
```
docker run --name mysql \
           -v /home/conf/mysql:/etc/mysql/conf.d \
           -v /home/mysql:/var/lib/mysql \
           -e MYSQL_ROOT_PASSWORD=my-secret-pw \
           -d mysql
```

```
docker run --name web \
           --link mysql:localmysql \
           -v /home/conf/nginx:/usr/local/nginx/conf \
           -v /home/wwwlogs:/home/wwwlogs \
           -v /home/wwwroot:/home/wwwroot \
           -p 80:80 -p 443:443 \
           -d ywfwj2008/php-nginx
```
### run didn't with mysql
```
docker run --name web \
           -v /home/wwwlogs:/home/wwwlogs \
           -v /home/wwwroot:/home/wwwroot \
           -p 80:80 -p 443:443 \
           -d ywfwj2008/php-nginx
```
### nginx control
start|stop|status|restart|reload|configtest
```
docker exec -d web service nginx restart
```
### php control
start|stop|restart|reload|status
```
docker exec -d web service php-fpm restart
```