# syntax = docker/dockerfile:1
FROM --platform=linux/amd64 php:8.4-fpm

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev libexif-dev \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip gd intl exif

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Composer install
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy application code
COPY . .

# === Important fixes for Render ===
RUN cp .env.example .env

# Force the APP_KEY from Render environment variable into the .env file
RUN echo "APP_KEY=${APP_KEY}" >> .env

# Generate key (as fallback) + clear config cache
RUN php artisan key:generate --no-interaction --force || true \
    && php artisan config:clear \
    && php artisan package:discover || true

# Build frontend assets
RUN npm ci --no-audit --prefer-offline && npm run build

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]