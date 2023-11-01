FROM php:7.2-apache

# Install dependencies: default-mysql-client and git
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    git

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql

# Set working directory
WORKDIR /var/www/html

# Copy composer.json and composer.lock files
COPY application/composer.json application/composer.lock ./

# Install application dependencies ignoring platform reqs
RUN composer install --no-scripts --no-autoloader --no-interaction --ignore-platform-reqs

# Copy rest of the application files
COPY application/ .

# Generate Autoloader
RUN composer dump-autoload --optimize

# Put php.ini into place
COPY docker/config/php/php.ini /usr/local/etc/php/

# Expose port 80 (for HTTP server)
EXPOSE 80

# Start Apache service
CMD ["apache2-foreground"]