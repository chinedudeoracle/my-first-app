FROM php:8.3-cli

WORKDIR /app

# Install required system packages + PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl zip libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip gd intl

# Copy Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files first for caching
COPY composer.json composer.lock ./

ENV COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_PROCESS_TIMEOUT=300

RUN php -v && composer -V && php -m

# Composer install (this is where it was failing)
RUN composer install --no-dev --no-interaction --prefer-dist \
    --optimize-autoloader --no-scripts

COPY . .

# Laravel setup
RUN cp .env.example .env \
    && php artisan key:generate --no-interaction --force

# Frontend
RUN npm ci --no-audit --prefer-offline && npm run build

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]