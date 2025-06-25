FROM php:8.2-apache

# Install PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Copy project files
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Apache config override for Laravel
RUN echo '<Directory "/var/www/html/public">\
    AllowOverride All\
</Directory>' >> /etc/apache2/apache2.conf

# Set document root to public/
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
