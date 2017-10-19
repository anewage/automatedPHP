FROM ubuntu
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

# Install php
RUN apt-get install -y \
    php7.0-xmlrpc php7.0-bz2 php7.0-cgi php7.0-cli php7.0-dba php7.0-dev php7.0-fpm php7.0-gd \
    php7.0-gmp php7.0-opcache php7.0 php7.0-pspell php7.0-recode php7.0-common php7.0-bcmath \
    php7.0-sqlite3 php7.0-tidy php7.0-json php7.0-mbstring php7.0-readline php7.0-xml php7.0-xsl \
    php7.0-curl php7.0-zip php7.0-ldap php7.0-pgsql php7.0-mcrypt php7.0-imap libphp7.0-embed \
    php7.0-intl php7.0-enchant php7.0-odbc php7.0-snmp php7.0-soap php7.0-sybase php7.0-phpdbg \
    libapache2-mod-php7.0 php7.0-mysql php7.0-interbase
    
#TEST
RUN pecl install mongodb \
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
