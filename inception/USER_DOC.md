*This project has been created as part of the 42 curriculum by bchafi.*

# Inception - User & Administrator Documentation (USER_DOC.md)

---

## 1. Services Provided by the Stack

The **Inception** infrastructure provides a complete, secure, and containerized **LEMP web application stack** comprising three core microservices:

1. **NGINX (TLS Reverse Proxy &amp; Web Gateway)**
   - Acts as the sole public-facing entry point to the infrastructure.
   - Enforces encrypted communications by serving content exclusively over **Port 443 with TLSv1.2 or TLSv1.3**.
   - Directly serves static web assets (images, CSS, JavaScript) from shared storage.

2. **WordPress &amp; PHP-FPM (Application Server)**
   - Executes dynamic PHP application code via PHP-FPM 8.1.
   - Hosts the WordPress Content Management System (CMS), allowing administrators to create posts, manage media, and configure site settings.
   - Listens internally on TCP Port 9000 for FastCGI requests forwarded by NGINX.

3. **MariaDB (Relational Database)**
   - Serves as the persistent backend database storage engine.
   - Stores all site tables, blog posts, user credentials, comments, and configuration settings.
   - Listens internally on TCP Port 3306 to process SQL queries initiated by WordPress.

---

## 2. Starting and Stopping the Project

All container lifecycle operations are managed from the project root using the provided `Makefile`.

### Starting the Infrastructure
To start the entire stack, open a terminal at the repository root and run:
```bash
make
```

*This command automatically creates the required host storage directories (* */home/bchafi/data/\** *), compiles custom Dockerfiles, creates the isolated bridge network, and starts all containers in detached mode.*

### Stopping the Infrastructure

To stop running containers without destroying your persistent data:

```
make down
```

### Full Teardown and Cleanup

To stop containers and completely remove all images, volumes, and host persistent storage:

```
make fclean
```

### Restarting / Rebuilding

To perform a complete wipe and rebuild the stack from scratch:

```
make re
```

---

## 3\. Accessing the Website and Administration Panel

### Domain Configuration (Prerequisite)

Before accessing the website in a web browser, map your local loopback IP address to the project domain name in your host operating system's `/etc/hosts` file:

```
sudo echo "127.0.0.1 bchafi.42.fr" &gt;&gt; /etc/hosts
```

### Accessing the Public Website

Open your browser and navigate to:

```
https://bchafi.42.fr
```

*(Note: Because the SSL certificate is self-signed for development purposes, your browser will display a security warning. Click* **Advanced** *and select* **Proceed to bchafi.42.fr** *).*

### Accessing the WordPress Administration Panel

To access the administrative backend:

1. Navigate to: `https://bchafi.42.fr/wp-admin` (or `https://bchafi.42.fr/wp-login.php`).
2. Log in using the administrator credentials configured in your environment file.
---

## 4\. Locating and Managing Credentials

All system passwords, database users, and administrator credentials are strictly managed through runtime environment variables and are **never hardcoded** in source files.

### File Location

Credentials are stored inside the environment file located at:

```
srcs/.env
```

### Environment Variables Breakdown

| Variable              | Description                      | Default Purpose                   |
| --------------------- | -------------------------------- | --------------------------------- |
| DOMAIN\_NAME          | Primary domain name              | bchafi.42.fr                      |
| MYSQL\_DATABASE       | MariaDB schema name              | bchafi\_db                        |
| MYSQL\_USER           | WordPress database user          | bchafi\_user                      |
| MYSQL\_PASSWORD       | Password for MYSQL\_USER         | Database access authentication    |
| MYSQL\_ROOT\_PASSWORD | Administrator root DB password   | MariaDB system administration     |
| WP\_ADMIN\_USER       | WordPress administrator username | Managing CMS settings and users   |
| WP\_ADMIN\_PASSWORD   | WordPress administrator password | Logging into /wp-admin            |
| WP\_ADMIN\_EMAIL      | Administrator contact email      | System notifications              |
| WP\_USER              | Secondary author username        | Content creation (non-admin role) |
| WP\_USER\_PASSWORD    | Secondary author password        | Secondary user login              |
| WP\_USER\_EMAIL       | Secondary author contact email   | Author user account profile       |

### Updating Credentials

To change credentials:

1. Modify the values inside `srcs/.env`.
2. Perform a clean rebuild so initialization scripts re-provision the updated settings:

```
make re
```

---

## 5\. Checking Service Health and Status

Administrators can verify service health and operational status using these commands:

### Service Status Overview

To view running containers, container IDs, and host port mappings:

```
make ps
```

*Expected Output*: Three containers (`nginx`, `wordpress`, `mariadb`) running with `Up` status. Only NGINX should show port `443` mapped to the host (`0.0.0.0:443-&gt;443/tcp`).

### Service Logs Verification

To stream live consolidated container logs:
```
make logs
```

### Verification via Terminal CLI (`curl`)

Test HTTPS connection and TLS handshake response:

```
curl -kv https://bchafi.42.fr

```

Test unencrypted HTTP rejection (must fail or be refused):

```
curl -I http://bchafi.42.fr
```
---
