FROM php:8.3-cli

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git unzip curl zip libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./

ENV COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_PROCESS_TIMEOUT=300

RUN php -v && composer -V && php -m

RUN composer install --no-dev --no-interaction --prefer-dist \
    --optimize-autoloader --no-scripts

COPY . .

RUN cp .env.example .env

RUN npm install --no-audit --prefer-offline && npm run build

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]