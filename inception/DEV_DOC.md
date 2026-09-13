*This project has been created as part of the 42 curriculum by bchafi.*

# Inception - Developer Documentation (DEV_DOC.md)

---

## 1. Setting Up the Environment from Scratch

### Prerequisites
Developers and evaluators must ensure the host system has the following tools installed:
- Operating System: Linux (Debian 12 / Ubuntu 22.04 LTS recommended)
- Prerequisites: `docker` (Engine 24.0+), `docker compose` (V2 plugin), `make`, `curl`, `sudo`

### Host Directory Setup
Ensure your local user account belongs to the `docker` user group to execute commands without `sudo`:
```bash
sudo usermod -aG docker \$USER && newgrp docker
```

### Configuration Files (`srcs/.env`)

The stack relies on `srcs/.env` for runtime configuration. Create the file under `srcs/.env` with the following structure:

```
DOMAIN_NAME=

MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_ROOT_PASSWORD=

WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=

WP_USER=bader_author
WP_USER_PASSWORD=
WP_USER_EMAIL=
```

---

## 2\. Building and Launching the Infrastructure

The infrastructure architecture is built entirely from lightweight base operating system images (`alpine:3.18`). Pre-built application images from Docker Hub are strictly prohibited.

### Command Execution Sequence

Build custom images, prepare persistent host storage, and start container services in detached mode:

```
make
```

Under the hood, `make` triggers:

1. `mkdir -p /home/bchafi/data/wordpress`
2. `mkdir -p /home/bchafi/data/mariadb`
3. `docker compose -f srcs/docker-compose.yml up -d --build`

---

## 3\. Container and Volume Management Commands

Developers can use standard Makefile targets or raw Docker CLI commands to manage the infrastructure:

### Infrastructure Management Targets

* **Build and Launch**: `make` or `make all`
* **Stop Containers**: `make down`
* **Clean Images & Containers**: `make clean`
* **Full System Purge (Wipe Volumes & Data)**: `make fclean`
* **Rebuild Entire Environment**: `make re`
* **Tail Container Logs**: `make logs`
* **List Running Containers**: `make ps`

### Advanced Container Inspection & Debugging

* **Verify Foreground Process Management (PID 1 Check)**:

```
docker exec -it nginx ps aux
docker exec -it wordpress ps aux
docker exec -it mariadb ps aux
```

*(Expected:* *nginx* *,* *php-fpm81* *, and* *mysqld* *must run directly as PID 1).*

* **Execute Interactive Shell Inside WordPress Container**:
```
docker exec -it wordpress /bin/sh
```

* **Inspect Database Tables and User Accounts Directly**:

```
docker exec -it mariadb mariadb -u root -p -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"
```

* **Test Internal Network Connectivity from NGINX to PHP-FPM**:
```
docker exec -it nginx nc -zv wordpress 9000
```

---

## 4\. Project Data Storage and Persistence Mechanics

### Data Storage Paths

Data persistence is handled by mapping container internal directories directly to dedicated storage directories on the host Virtual Machine:

* **WordPress Files (Themes, Plugins, Uploads,** **wp-config.php** **)**:
  * Host Path: `/home/bchafi/data/wordpress`
  * Container Path: `/var/www/wordpress` (Mounted in both NGINX and WordPress containers)
* **MariaDB Database Files (Binary Schemas, Tables, System Catalogs)**:
  * Host Path: `/home/bchafi/data/mariadb`
  * Container Path: `/var/lib/mysql` (Mounted in MariaDB container)

### Volume Persistence Engineering

Direct bind mounts declared directly inside service blocks (e.g., `- /host/path:/container/path`) are forbidden by project rules. To ensure persistence while satisfying this constraint, storage is configured using **Docker Global Named Volumes** with kernel-level `local` driver options in `srcs/docker-compose.yml`:

```
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      device: /home/bchafi/data/wordpress
      o: bind
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      device: /home/bchafi/data/mariadb
      o: bind
```

#### Why This Works:

1. Docker registers `wordpress_data` and `mariadb_data` as standard **Named Volumes** (visible in `docker volume ls`).
2. The `driver_opts` configuration passes system mount flags (`type: none`, `o: bind`) to the Linux kernel, directing volume read/write operations directly to `/home/bchafi/data/*` on the host machine .
3. When containers are stopped (`make down`) or deleted, the host files under `/home/bchafi/data/*` remain intact, ensuring full data persistence across container deployments .