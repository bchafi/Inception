# Step 1: Base OS
FROM alpine:3.18

# Step 2: Dependencies
RUN apk update && apk add --no-cache nginx openssl

# Step 3: Cryptography
RUN mkdir -p /etc/ssl/private /etc/ssl/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=MA/ST=Khouribga/L=Khouribga/O=1337/OU=1337/CN=bchafi.42.fr"

# Step 4: Configuration
COPY conf/nginx.conf /etc/nginx/conf/nginx.conf

# Step 5: Network
EXPOSE 443

# Step 6: Execution tell nginx to run in the foreground (in 
    # background: think as a PID 1, when finished that command, down the container, )
CMD ["nginx", "-g", "daemon off;"]