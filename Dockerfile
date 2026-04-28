FROM php:8.3-cli

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git unzip curl zip libzip-dev \
    libonig-dev libxml2-dev libcurl4-openssl-dev \
    nodejs npm \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

RUN cp .env.example .env

RUN php artisan key:generate

RUN php artisan config:cache

RUN npm install && npm run build

RUN php artisan key:generate

CMD php artisan serve --host=0.0.0.0 --port=10000