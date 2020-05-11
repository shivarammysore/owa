FROM nginx:1.18.0-alpine
LABEL MAINTAINER="Shivaram Mysore <shivaram.mysore@gmail.com>" \
      DESCRIPTION="Container with Nginx, php.4 fpm, Composer, Open Web Analytics"

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
                      libssl1.1 \
                      musl \
                      nodejs \
                      nodejs-npm \
                      openssl  \
                      openssh-client \
                      php \
                      php-apcu \
                      php-bcmath \
                      php-bz2 \
                      php-ctype \
                      php-curl \
                      php-dom \
                      php-fpm \
                      php-gd \
                      php-iconv \
                      php-intl \
                      php-json \
                      php-openssl \
                      php-opcache \
                      php-mbstring \
                      php-memcached \
                      php-mysqlnd \
                      php-mysqli \
                      php-pcntl \
                      php-pgsql \
                      php-pdo \
                      php-pdo_mysql \
                      php-pdo_pgsql \
                      php-pdo_sqlite \
                      php-phar \
                      php-posix \
                      php-session \
                      php-sqlite3 \
                      php-soap \
                      php-sockets \
                      php-xml \
                      php-xmlreader \
                      php-zip \
                      php-zlib \
                      supervisor \
                      tzdata \
                      wget \
                      yaml && \
    rm -rf /var/cache/apk/*              && \
    mkdir -p /usr/share/nginx/html/owa   && \
    mkdir -p /etc/supervisor/conf.d/     && \
    rm -f /etc/nginx/nginx.conf          && \
    rm -f /etc/nginx/conf.d/default.conf


RUN ln -s /usr/bin/php7 /usr/bin/php

COPY config/etc/environment /etc/
COPY config/etc/nginx/ /etc/nginx/
COPY config/etc/php7 /etc/php7/
COPY config/etc/supervisor/ /etc/supervisor/

# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN curl -L -o /usr/share/nginx/html/owa/owa.tar -k https://github.com/Open-Web-Analytics/Open-Web-Analytics/releases/download/1.6.8/owa_1.6.8_packaged.tar \
    && tar -xvf /usr/share/nginx/html/owa/owa.tar -C /usr/share/nginx/html/owa/ \
    && rm -f /usr/share/nginx/html/owa/owa.tar

## Test PHP - Remove later
RUN echo '<?php phpinfo();' >/usr/share/nginx/html/owa/info.php

## To send web server logs ...
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# www-data is the group and user that php-fpm uses.  It is a system account
# hence we create www-app user with UID 1000 so that it can run as user but, in
# www-data group to have access to files and services.
# Create www-app user
# RUN adduser -D -u 1000 -G www-data www-app
## RUN adduser -D -u 1000 www-app

USER root

RUN apk del coreutils

#EXPOSE 8084

#CMD [ "nginx" "-g" "daemon on;" ]
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf