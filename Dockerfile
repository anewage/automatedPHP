# vim:set ft=dockerfile:

FROM php:7.1-fpm
MAINTAINER Pooya Parsa <pooya@pi0.ir>
MAINTAINER Amir Haghighati <haghighati.amir@gmail.com>

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
    
    
# Install "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev", "libpng12-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
  && rm -rf /var/lib/apt/lists/*

# Install the PHP mcrypt extention
RUN docker-php-ext-install mcrypt \
  # Install the PHP pdo_mysql extention
  && docker-php-ext-install pdo_mysql \
  # Install the PHP pdo_pgsql extention
  && docker-php-ext-install pdo_pgsql \
  # Install the PHP gd library
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd
    
# Optional packages
RUN apt-get update -yqq && \
    apt-get -y install libxml2-dev php-soap && \
    docker-php-ext-install soap
    
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis 
    
RUN pecl install mongodb && \
    docker-php-ext-enable mongodb
    
RUN docker-php-ext-install zip

RUN docker-php-ext-install bcmath

RUN apt-get update -yqq && \
    apt-get install -y zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

RUN apt-get update -yqq && \
    apt-get install -y libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap
    
RUN apt-get update -y && \
    apt-get install -y libmagickwand-dev imagemagick && \ 
    pecl install imagick && \
    docker-php-ext-enable imagick

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
