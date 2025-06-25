FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libzip-dev unzip zip \
    && docker-php-ext-install pdo pdo_mysql zip

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . .

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# ✅ Thêm đoạn sửa lỗi Apache config:
RUN printf '<Directory "/var/www/html/public">\n\
    AllowOverride All\n\
</Directory>\n' >> /etc/apache2/apache2.conf
