FROM php:8.2-apache

# Cài extension
RUN apt-get update && apt-get install -y \
    libzip-dev unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Cài composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Laravel chạy trong /var/www/html
WORKDIR /var/www/html

# Copy toàn bộ source code
COPY . .

# Thiết lập document root vào thư mục public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Cấu hình Apache
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Bật mod_rewrite cho Laravel
RUN a2enmod rewrite

# Cấp quyền truy cập thư mục public
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# Tạo file SQLite trống để tránh lỗi
RUN mkdir -p database && touch database/database.sqlite

# Cài đặt composer
RUN composer install --no-interaction --optimize-autoloader

# Laravel cần phân quyền
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Tạo bảng sessions
RUN php artisan migrate --force
