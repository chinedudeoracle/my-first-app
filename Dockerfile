FROM php:8.4-fpm

WORKDIR /app

# =========================
# System dependencies
# =========================
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip gd intl \
    && rm -rf /var/lib/apt/lists/*
	
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# =========================
# Composer
# =========================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# =========================
# Copy only composer files first (cache layer)
# =========================
COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

# =========================
# Copy full app
# =========================
COPY . .

# =========================
# Environment setup (safe for builds)
# =========================
RUN cp .env.example .env || true

# =========================
# IMPORTANT: Clear any cached broken config
# =========================
RUN php artisan optimize:clear || true

# =========================
# Generate app key ONLY if missing (safe fallback)
# =========================
RUN php artisan key:generate --force || true

# =========================
# Frontend build (Vite / Inertia)
# =========================
RUN npm install
RUN npm run build

# =========================
# Permissions (critical for Laravel)
# =========================
RUN chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# =========================
# Expose port (Render uses dynamic PORT)
# =========================
EXPOSE 10000

# =========================
# Start server
# =========================
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-10000}