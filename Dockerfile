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
    # Setup document root
    mkdir -p /usr/share/owa              && \
    mkdir -p /etc/supervisor/conf.d/     && \
    # Remove default server definition
    rm -f /etc/nginx/conf.d/default.conf


RUN ln -s /usr/bin/php7 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/www.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## To send web server logs ...
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# www-data is the group and user that php-fpm uses.  It is a system account
# hence we create www-app user with UID 1000 so that it can run as user but, in
# www-data group to have access to files and services.
# Create www-app user
# RUN adduser -D -u 1000 -G www-data www-app
RUN adduser -D -u 1000 www-app

# Add application
RUN curl -L -o /usr/share/owa/owa.tar -k https://github.com/Open-Web-Analytics/Open-Web-Analytics/releases/download/1.6.8/owa_1.6.8_packaged.tar \
    && tar -xvf /usr/share/owa/owa.tar -C /usr/share/owa/ \
    && rm -f /usr/share/owa/owa.tar

RUN echo '<?php phpinfo();?>' >/usr/share/owa/info.php

#COPY src/ /usr/share/owa/
RUN chown -R www-app:www-app /usr/share/owa


# Switch to use a non-root user from here on
USER root

#RUN apk del coreutils

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
