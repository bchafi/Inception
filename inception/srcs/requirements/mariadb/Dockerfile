FROM alpine:3.18

# Install database packages
RUN apk update && apk add --no-cache mariadb mariadb-client
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Overwrite default bind-address configuration
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy and prepare setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]