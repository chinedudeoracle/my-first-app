FROM php:8.4-fpm

WORKDIR /app

# System dependencies + PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl zip libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip gd intl \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy dependency files first
COPY composer.json composer.lock ./

# Install dependencies (no scripts yet)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy application
COPY . .

# Now run Laravel autoload + discovery safely
RUN php artisan package:discover --ansi

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 10000

# Use PORT from Render
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-10000}