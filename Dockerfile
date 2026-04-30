FROM php:8.4-cli

WORKDIR /app

# =========================
# System dependencies
# =========================
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libzip-dev libonig-dev libxml2-dev \
    libcurl4-openssl-dev libssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
    libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring bcmath xml zip gd intl \
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
# RUN cp .env.example .env || true

# =========================
# Clear Laravel cached config/views (safe build step)
# =========================
#RUN php artisan view:clear && php artisan config:clear

# =========================
# IMPORTANT: Clear any cached broken config
# =========================
RUN rm -rf bootstrap/cache/*.php

# =========================
# Generate app key ONLY if missing (safe fallback)
# =========================
# RUN php artisan key:generate --force || true

# =========================
# Frontend build (Vite / Inertia)
# =========================
# 1. Copy package files FIRST (for caching)
COPY package*.json ./

RUN npm install

# 2. Copy rest of app
COPY . .

# 3. Build frontend
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
CMD php -S 0.0.0.0:$PORT -t public
