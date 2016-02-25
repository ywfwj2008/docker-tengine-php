FROM ywfwj2008/tengine:latest

MAINTAINER ywfwj2008 <ywfwj2008@163.com>

RUN apt-get update && \
    apt-get install -y software-properties-common --no-install-recommends && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php5 && \
    apt-get update

RUN apt-get install -y php5-fpm php5-curl php5-gd php5-imagick php5-mcrypt php5-mysql php5-sqlite php5-memcache php5-memcached

EXPOSE 80 443

#ENTRYPOINT ["/entrypoint.sh"]