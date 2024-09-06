#!/bin/sh

# Make sure all required Laravel dirs exist
mkdir -p /app/storage/framework/cache
mkdir -p /app/storage/framework/sessions
mkdir -p /app/storage/framework/views

# Generate a key if we do not have one
if ! grep -q "^APP_KEY=" ".env" || [ -z "$(grep "^APP_KEY=" ".env" | cut -d '=' -f2)" ]; then
    php artisan key:generate
fi

# Run migrations
php artisan migrate --force

# Start supervisor
/usr/bin/supervisord -c /app/docker/supervisor/supervisor.conf



##!/bin/bash
#
#if [ ! -f "vendor/autoload.php" ]; then
#    composer install --no-progress --no-interaction
#fi
#
#if [ ! -f ".env" ]; then
#    echo "Creating env file for env $APP_ENV"
#    cp .env.example .env
#else
#    echo "env file exists."
#fi
#echo "Migration in progress..."
#php artisan migrate
#echo "Migration in done"
#php artisan key:generate
#php artisan db:seed
#php artisan cache:clear
#php artisan route:clear
#php artisan serve --port="$PORT" --host=0.0.0.0 --env=.env
#exec docker-php-entrypoint "$@"

