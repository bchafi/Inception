#!/bin/sh

# 1. Wait for MariaDB to be fully ready by testing a real login
echo "Waiting for MariaDB database to start..."
while ! mariadb -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready!"

# 2. Download and configure WordPress (if it doesn't already exist)
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Installing WordPress..."
    
    # Download core files
    wp core download --allow-root
    
    # Generate wp-config.php using your .env variables
    wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=mariadb --allow-root
    
    # Install the actual CMS and create the Admin user
    wp core install --url=bchafi.42.fr --title="Inception" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --allow-root
    
    # Create a second standard user
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root
fi

echo "Starting PHP-FPM..."
# 3. Take over PID 1
exec php-fpm81 -F