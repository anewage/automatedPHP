FROM ubuntu:16.04
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
    bash supervisor nginx git curl sudo zip unzip xz-utils python-software-properties \
 && add-apt-repository -y ppa:ondrej/php \
 && apt-get update -y

# Install php
RUN apt-get install -y \
    php7.1-xml php7.1-xsl php7.1-mbstring php7.1-readline php7.1-zip php7.1-mysql \
    php7.1-phpdbg php7.1-interbase php7.1-sybase php7.1 php7.1-sqlite3 php7.1-tidy \
    php7.1-opcache php7.1-pspell php7.1-json php7.1-xmlrpc php7.1-curl php7.1-ldap \
    php7.1-bz2 php7.1-cgi php7.1-imap php7.1-cli php7.1-dba php7.1-dev php7.1-intl \
    php7.1-fpm php7.1-recode php7.1-odbc php7.1-gmp php7.1-common php7.1-pgsql \
    php7.1-bcmath php7.1-snmp php7.1-soap php7.1-mcrypt php7.1-gd php7.1-enchant \
    libapache2-mod-php7.1 libphp7.1-embed \
 && pecl install mongodb \
 && docker-php-ext-enable mongodb

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash \
 && apt-get install -y nodejs

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
