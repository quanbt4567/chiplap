FROM php:8.2-apache

# Cài các extension cần thiết
RUN apt-get update && apt-get install -y \
    libzip-dev unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Cài Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Laravel cần chạy trong thư mục /var/www/html
WORKDIR /var/www/html

# Copy toàn bộ dự án Laravel vào container
COPY . .

# Thiết lập document root thành thư mục public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Cấu hình Apache để trỏ đúng vào thư mục public/
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Cho phép htaccess hoạt động (Laravel cần)
RUN a2enmod rewrite

# Cài các gói PHP Laravel cần (nếu bạn chưa push vendor lên GitHub)
RUN composer install --no-interaction --optimize-autoloader

# Phân quyền cho storage & bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache
