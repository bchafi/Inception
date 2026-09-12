#!/bin/sh

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First boot: Initializing MariaDB database files..."
    
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    for i in $(seq 1 30); do
        if mysqladmin ping >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

echo "Starting MariaDB daemon in the foreground (PID 1)..."
exec mysqld --user=mysql --datadir=/var/lib/mysql