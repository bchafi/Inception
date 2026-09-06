#!/bin/sh

# 1. Check if the database is already installed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    
    # Bootstrap the basic database structure
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    
    # Start the database temporarily in the background
    mysqld --user=mysql --datadir=/var/lib/mysql &
    sleep 5 # Wait for it to boot
    
    # TODO: Inject SQL commands here using $DB_NAME, $DB_USER, $DB_PASSWORD
    # mariadb -u root -e "CREATE DATABASE IF NOT EXISTS ..."
    
    # Stop the temporary background process securely
    mysqladmin -u root shutdown
fi

echo "Starting MariaDB daemon..."
# 2. Handoff to PID 1 in the foreground
exec mysqld --user=mysql --datadir=/var/lib/mysql