FROM php:8.4-fpm

WORKDIR /app

# Install system dependencies + PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl zip libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip gd intl \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files first (for caching)
COPY composer.json composer.lock ./

# Install PHP dependencies WITHOUT running Laravel scripts
RUN composer install --no-dev --no-interaction --prefer-dist \
    --optimize-autoloader --no-scripts

# Copy the rest of the application
COPY . .

# Ensure Laravel can boot (only if needed for build steps)
RUN cp .env.example .env

# Run Laravel package discovery now that app is fully present
RUN php artisan package:discover --ansi || true

# Set correct permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD php artisan serve --host=0.0.0.0 --port=${PORT:-10000}