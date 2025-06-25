FROM php:8.2-apache

# Cài extension
RUN apt-get update && apt-get install -y \
    libzip-dev unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Cài composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Làm việc trong thư mục Laravel
WORKDIR /var/www/html

# Copy mã nguồn
COPY . .

# Đổi document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Cấu hình Apache cho đúng document root
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Bật mod_rewrite
RUN a2enmod rewrite

# Thêm cấu hình cấp quyền thư mục public
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# Cài các gói PHP của Laravel
RUN composer install --no-interaction --optimize-autoloader

# Cấp quyền cho Laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache
