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
                      php7 \
                      php7-apcu \
                      php7-bcmath \
                      php7-bz2 \
                      php7-ctype \
                      php7-curl \
                      php7-dom \
                      php7-fileinfo \
                      php7-fpm \
                      php7-gd \
                      php7-iconv \
                      php7-intl \
                      php7-json \
                      php7-openssl \
                      php7-opcache \
                      php7-mbstring \
                      php7-memcached \
                      php7-mcrypt \
                      php7-mysqlnd \
                      php7-mysqli \
                      php7-pcntl \
                      php7-pgsql \
                      php7-pdo \
                      php7-pdo_mysql \
                      php7-pdo_pgsql \
                      php7-pdo_sqlite \
                      php7-phar \
                      php7-posix \
                      php7-session \
                      php7-simplexml \
                      php7-sqlite3 \
                      php7-soap \
                      php7-sockets \
                      php7-tokenizer \
                      php7-xml \
                      php7-xmlreader \
                      php7-xmlwriter \
                      php7-zip \
                      php7-zlib \
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