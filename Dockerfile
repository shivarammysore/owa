FROM nginx:1.18.0-alpine
LABEL MAINTAINER="Shivaram Mysore <shivaram.mysore@gmail.com>" \
      DESCRIPTION="Container with Nginx, PHP7.4 fpm, Composer, Open Web Analytics"

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# make sure you can use HTTPS and
# add the repository, make sure you replace the correct versions if you want.
RUN apk --update add ca-certificates && \
  echo "https://dl.bintray.com/php-alpine/v3.10/php-7.4" >> /etc/apk/repositories

RUN apk add --update  bash \
                      ca-certificates \
                      composer \
                      coreutils \
                      curl \
                      git \
                      libmemcached-libs \
                      libevent \
                      libssl1.0 \
                      musl \
                      nodejs \
                      nodejs-npm \
                      openssl  \
                      openssh-client \
                      php7@php \
                      php7-apcu@php \
                      php7-bcmath@php \
                      php7-bz2@php \
                      php7-ctype@php \
                      php7-curl@php \
                      php7-dom@php \
                      php7-fileinfo \
                      php7-fpm@php \
                      php7-gd@php \
                      php7-iconv@php \
                      php7-intl \
                      php7-json@php \
                      php7-openssl@php \
                      php7-opcache@php \
                      php7-mbstring@php \
                      php7-memcached@php \
                      php7-mcrypt \
                      php7-mysqlnd@php \
                      php7-mysqli@php \
                      php7-pcntl@php \
                      php7-pgsql@php \
                      php7-pdo@php \
                      php7-pdo_mysql@php \
                      php7-pdo_pgsql@php \
                      php7-pdo_sqlite@php \
                      php7-phar@php \
                      php7-posix@php \
                      php7-session@php \
                      php7-simplexml \
                      php7-sqlite3@php \
                      php7-soap@php \
                      php7-sockets@php \
                      php7-tokenizer \
                      php7-xml@php \
                      php7-xmlreader@php \
                      php7-xmlwriter \
                      php7-zip@php \
                      php7-zlib@php \
                      supervisor \
                      tzdata \
                      wget \
                      yaml && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    rm -rf /var/cache/apk/*          && \
    mkdir -p /usr/share/nginx/html/owa
    #rm -f /etc/nginx/nginx.conf      && \
    #rm -f /etc/nginx/conf.d/default.conf

# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN curl -L -o /usr/share/nginx/html/owa/owa.tar -k https://github.com/Open-Web-Analytics/Open-Web-Analytics/releases/download/1.6.8/owa_1.6.8_packaged.tar \
    && tax -xvf /usr/share/nginx/html/owa/owa.tar -C /usr/share/nginx/html/owa/ \
    && rm -f /usr/share/nginx/html/owa/owa.tar

## To send web server logs ...
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN apk del coreutils

#EXPOSE 8084

#CMD [ "nginx" "-g" "daemon on;" ]