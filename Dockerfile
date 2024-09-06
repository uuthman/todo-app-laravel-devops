#FROM php:8.2.11-fpm
#
#RUN echo "\e[1;33mInstall COMPOSER\e[0m"
#RUN cd /tmp \
#    && curl -sS https://getcomposer.org/installer | php \
#    && mv composer.phar /usr/local/bin/composer
#
#RUN apt-get update
#
## Install useful tools
#RUN apt-get -y install apt-utils nano wget dialog vim
#
## Install important libraries
#RUN echo "\e[1;33mInstall important libraries\e[0m"
#RUN apt-get -y install --fix-missing \
#    apt-utils \
#    build-essential \
#    git \
#    curl \
#    libcurl4 \
#    libcurl4-openssl-dev \
#    zlib1g-dev \
#    libzip-dev \
#    zip \
#    libbz2-dev \
#    locales \
#    libmcrypt-dev \
#    libicu-dev \
#    libonig-dev \
#    libxml2-dev
#
## RUN echo "\e[1;33mInstall important docker dependencies\e[0m"
## RUN docker-php-ext-install \
##     exif \
##     pcntl \
##     bcmath \
##     ctype \
##     curl \
##     iconv \
##     xml \
##     soap \
##     pcntl \
##     mbstring \
##     tokenizer \
##     bz2 \
##     zip \
##     intl
#
## Install Postgre PDO
#RUN apt-get install -y libpq-dev \
#    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
#    && docker-php-ext-install pdo pdo_pgsql pgsql
#
#WORKDIR /var/www
#COPY . .
#
#ENV PORT=8000
#
#ENTRYPOINT [ "./entrypoint.sh" ]

FROM dunglas/frankenphp:latest-php8.3-alpine

# Dependencies
RUN apk add --no-cache bash git linux-headers libzip-dev libxml2-dev supervisor nodejs npm

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


RUN apk add libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql pcntl bcmath

# Redis
RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
      && pecl install redis \
      && docker-php-ext-enable redis \
      && apk del pcre-dev ${PHPIZE_DEPS} \
      && rm -rf /tmp/pear


COPY . /app
WORKDIR /app

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --prefer-dist --no-interaction

RUN npm install
RUN npm run build

RUN yes | php artisan octane:install --server=frankenphp
ENV OCTANE_SERVER=frankenphp

ENTRYPOINT ["sh", "/app/docker/entrypoint.sh"]
