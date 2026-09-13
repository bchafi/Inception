#!/bin/sh

until mysqladmin ping -h"mariadb" --silent; do
    echo "Waiting for MariaDB database to start..."
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress core files..."
    php81 -d memory_limit=512M /usr/local/bin/wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
    --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creating secondary user..."
    wp user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

echo "Starting PHP-FPM in the foreground (PID 1)..."
exec php-fpm81 -F