FROM php:8.3-fpm-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (including intl and zip for dependencies)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip opcache
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy dependency descriptors first for build cache reuse
COPY composer.json composer.lock ./

# Install PHP dependencies (scripts are deferred to runtime)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy project
COPY . .

# Set permissions
RUN chown -R www-data:www-data /app && \
    chmod -R 755 /app && \
    chmod -R 777 /app/storage && \
    chmod -R 777 /app/bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
