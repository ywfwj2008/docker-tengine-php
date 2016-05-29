# docker-tengine-php

## usage

### wish mysql
```
docker run --name mysql \
           -v /my/custom:/etc/mysql/conf.d \
           -v /home/mysql:/var/lib/mysql \
           -e MYSQL_ROOT_PASSWORD=my-secret-pw \
           -d mysql
```

```
docker run --name web \
           --link mysql:localmysql \
           -v /home/nginx_conf:/usr/local/tengine/conf
           -v /home/wwwlogs:/home/wwwlogs \
           -v /home/wwwroot:/home/wwwroot \
           -p 80:80 -p 443:443 \
           -d ywfwj2008/tengine-php
```
### not with mysql
```
docker run --name web \
           -v /home/wwwlogs:/home/wwwlogs \
           -v /home/wwwroot:/home/wwwroot \
           -p 80:80 -p 443:443 \
           -d ywfwj2008/tengine-php
```