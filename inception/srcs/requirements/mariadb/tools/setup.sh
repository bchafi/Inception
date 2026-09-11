#!/bin/sh

# Ensure proper directory permissions inside the container filesystem
chown -R mysql:mysql /var/lib/mysql

# 1. Check if the database system tables are initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First boot: Initializing MariaDB database files..."
    
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    
    # Start the daemon temporarily in the background
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    # Wait for the local socket to open
    for i in $(seq 1 30); do
        if mysqladmin ping >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    
    # Inject secure configurations using environment variables
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    
    # Clean up and shutdown the temporary background daemon
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

echo "Starting MariaDB daemon in the foreground (PID 1)..."
# 2. Re-launch mysqld replacing the shell script process space
exec mysqld --user=mysql --datadir=/var/lib/mysql