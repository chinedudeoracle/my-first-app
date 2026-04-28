FROM php:8.4-fpm

WORKDIR /app

# ----------------------------
# System dependencies + PHP extensions
# ----------------------------
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip gd intl \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Composer
# ----------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ----------------------------
# Copy only composer files first (for caching)
# ----------------------------
COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

# ----------------------------
# Copy full application
# ----------------------------
COPY . .

# ----------------------------
# IMPORTANT: DO NOT create .env in production
# Render provides env vars directly
# ----------------------------

# ----------------------------
# Fix Laravel bootstrap safely
# ----------------------------
RUN php artisan package:discover --ansi || true

RUN php artisan config:clear || true \
    && php artisan cache:clear || true \
    && php artisan route:clear || true

# ----------------------------
# Permissions
# ----------------------------
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# ----------------------------
# Expose Render port
# ----------------------------
EXPOSE 10000

# ----------------------------
# Start server (Render provides PORT env)
# ----------------------------
CMD php -S 0.0.0.0:${PORT:-10000} -t public