FROM composer:2.7.9 AS vendor

WORKDIR /app

COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist

COPY . .

RUN composer dump-autoload

FROM node:16 AS frontend

WORKDIR /app

COPY --from=vendor /app/vendor/ ./vendor/

COPY artisan package.json vite.config.js package-lock.json tailwind.config.js postcss.config.js ./

RUN npm install

COPY resources/js ./resources/js
COPY resources/css ./resources/css

RUN npm run build

FROM dunglas/frankenphp:latest-php8.3-alpine

WORKDIR /app


RUN apk add libpq-dev libzip-dev supervisor \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql pcntl bcmath




COPY --from=frontend /app/public ./public/

COPY --from=vendor /app/vendor/ ./vendor/


COPY . .

RUN yes | php artisan octane:install --server=frankenphp
ENV OCTANE_SERVER=frankenphp

ENTRYPOINT ["sh", "/app/docker/entrypoint.sh"]


