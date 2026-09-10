FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php81 \ 
    # the FastCGI process manager
    php81-fpm \
    # the SQL translator for your database connection.
    php81-mysqli \
    php81-phar \
    php81-json \
    php81-iconv \
    php81-curl \
    php81-dom \
    mariadb-client \
    curl

# Install wp-cli (WordPress Command Line Interface)
# terminal-based installation instead of a manual browser setup.
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy our custom PHP-FPM pool config
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

# Copy and setup the initialization script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]