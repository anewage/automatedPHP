# vim:set ft=dockerfile:

FROM ubuntu
MAINTAINER Pooya Parsa <pooya@pi0.ir>

ENV HOME=/var/www
ENV TERM=xterm
ENV SHELL=bash
WORKDIR /
EXPOSE 80

# Install Base Packages
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
    bash supervisor nginx git curl sudo zip unzip xz-utils

# Install php
RUN apt-get install -y \
    php7.0 php-apcu php7.0-bz2 php-cache php7.0-opcache php7.0-cli php7.0-curl php7.0-fpm php7.0-gd php-geoip \
    php-gettext php7.0-gmp php-imagick php7.0-imap php7.0-json php7.0-mcrypt php7.0-mbstring php7.0-zip \
    php-memcached php-mongodb php-mongodb php7.0-mysql php-pear php-redis php7.0-xml php7.0-intl php7.0-soap \
    php7.0-sqlite3 php-dompdf php-fpdf php-guzzlehttp php-guzzlehttp-psr7 php-jwt  php-ssh2 php7.0-bcmath

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash \
 && apt-get install -y nodejs build-essential

# Install Additional Packages
RUN apt-get install -y \
    libxrender1

# gulp-cli
RUN npm install --global gulp-cli 

# Cleanup
RUN rm -rf /var/cache/apt && rm -rf /var/lib/apt

# Install composer
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin --filename=composer

# Permissions
RUN chown www-data:www-data -R /root

# PHP-FPM
RUN mkdir -p /run/php
COPY conf/www.conf /etc/php/7.0/fpm/pool.d/www.conf
COPY conf/php.ini /etc/php/7.0/fpm/php.ini

# Nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx-default /etc/nginx/conf.d/default.conf

# www-data user
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www && \
    ln -s /var/www/ /home/www-data

# Supedvisord
COPY conf/supervisord.conf /etc/supervisord.conf

# Bin
COPY bin /bin

VOLUME /var/www
ENTRYPOINT ["entrypoint"]
