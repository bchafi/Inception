*This project has been created as part of the 42 curriculum by bchafi.*

# Inception - Containerized Infrastructure with Docker

## Description
The **Inception** project focuses on system administration, containerization, and service isolation by building a complete, production-grade web infrastructure using **Docker** and **Docker Compose**.

The core objective is to deploy an isolated **LEMP stack** (Linux, NGINX, MariaDB, PHP-FPM / WordPress) where every service runs inside its own dedicated container built from scratch using a lightweight base operating system (Alpine Linux).

### Key Architectural Pillars
- **Strict Gateway Security**: NGINX acts as the sole public entry point, serving traffic strictly over **Port 443 with TLSv1.2 or TLSv1.3**. Unencrypted HTTP (Port 80) is strictly forbidden.
- **Microservices Architecture**: The stack is decoupled into three distinct containers: **NGINX**, **WordPress (PHP-FPM)**, and **MariaDB**.
- **Process Management (PID 1)**: Primary service daemons execute directly in the foreground as **PID 1** to ensure correct signal forwarding (`SIGTERM`) and lifecycle control.
- **Persistent Storage**: Database files and WordPress assets persist across container lifecycles using named Docker volumes bound to `/home/bchafi/data/` on the host VM.
- **Isolated Custom Networking**: Services communicate over a custom bridge network (`inception_net`) using Docker's internal DNS resolver (`127.0.0.11`).

---

## Instructions

### Prerequisites
- Operating System: Linux (Debian/Ubuntu)
- Required Tools: `docker`, `docker compose` (V2), `make`, `sudo`
- Domain Setup: Map `127.0.0.1` to `bchafi.42.fr` inside `/etc/hosts`:
  ```bash
  sudo echo "127.0.0.1 bchafi.42.fr" >> /etc/hosts
  ```

### Compilation and Execution
All infrastructure operations are managed through the root `Makefile`:

- **Build and Start Infrastructure**:
  ```bash
  make
  ```
  *(Creates host directories `/home/bchafi/data/*`, compiles custom Dockerfiles, and launches containers in detached mode).*

- **Check Running Services**:
  ```bash
  make ps
  ```

- **Inspect Live Logs**:
  ```bash
  make logs
  ```

- **Stop Stack Gracefully**:
  ```bash
  make down
  ```

- **Remove Containers & Images**:
  ```bash
  make clean
  ```

- **Full Purge (Wipe Containers, Images, Volumes, & Host Data)**:
  ```bash
  make fclean
  ```

- **Rebuild Entire Stack from Scratch**:
  ```bash
  make re
  ```

---

## Project Description & Architecture Choices

### Use of Docker & Directory Hierarchy
To comply with project constraints, official pre-built application images (e.g., `FROM nginx`, `FROM mariadb`) are forbidden. Each service is built manually using minimal base OS images (`alpine:3.18`) configured via dedicated Dockerfiles under `srcs/requirements/`:

```text
srcs/
├── docker-compose.yml
├── .env
└── requirements/
    ├── mariadb/
    │   ├── Dockerfile
    │   ├── conf/mariadb-server.cnf
    │   └── tools/setup.sh
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/nginx.conf
    └── wordpress/
        ├── Dockerfile
        ├── conf/www.conf
        └── tools/setup.sh
```

### Technical Comparisons

#### 1. Virtual Machines vs. Docker
- **Virtual Machines**: Utilize a **Hypervisor** to virtualize hardware, running a full guest operating system with its own kernel for every instance. This results in heavy memory consumption, large disk footprints, and slow startup times.
- **Docker Containers**: Implement **OS-level virtualization**, sharing the host kernel while isolating processes via Linux primitives (**Namespaces** for process/network isolation and **cgroups** for resource constraints). Containers are lightweight, boot in seconds, and consume minimal resources.

#### 2. Secrets vs. Environment Variables
- **Secrets**: Encrypted strings or files managed at runtime by orchestration systems (e.g., Docker Swarm) and mounted into temporary in-memory files (e.g., `/run/secrets/`), preventing exposure in process lists or image layers.
- **Environment Variables**: Key-value pairs injected into a container's environment space at runtime via an `.env` file. While convenient for single-host setups, credentials must be handled carefully to avoid leaking through process inspection (`ps`) or command arguments. In this stack, `.env` variables dynamically inject credentials without hardcoding secrets in source files or Dockerfiles.

#### 3. Docker Network vs. Host Network
- **Host Network (`--net=host`)**: Disables network isolation between the container and host. The container shares the host's IP address and interfaces directly, exposing all bound ports without isolation.
- **Custom Docker Bridge Network (`inception_net`)**: Creates an isolated virtual bridge using Linux network namespaces. Containers receive private virtual IP addresses and resolve service names (`mariadb:3306`, `wordpress:9000`) via Docker's embedded DNS server (`127.0.0.11`). Only explicitly published ports (`443:443` for NGINX) are exposed to the host VM.

#### 4. Docker Volumes vs. Bind Mounts
- **Bind Mounts**: Direct links connecting a host directory to a container directory. They rely strictly on host folder structures and bypass Docker's volume management system. Direct bind mounts declared inside service blocks are forbidden by project rules.
- **Docker Named Volumes**: Managed storage abstraction controlled by Docker's storage drivers. In this implementation, global named volumes (`mariadb_data` and `wordpress_data`) utilize the `local` driver with kernel mount options (`driver_opts` using `type: none` and `o: bind`). This registers them as true named volumes while directing storage I/O to `/home/bchafi/data/` on the host VM, ensuring data persistence across cleanups.

---

## Resources

### References & Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose V2 Specification](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation & TLS Configuration](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.configuration.php)
- [WP-CLI Command Reference](https://developer.wordpress.org/cli/commands/)

### Use of Artificial Intelligence
Artificial Intelligence (Gemini / AI Workbench) was used as a project mentor throughout implementation for the following tasks:
1. **Architectural Deep Dives**: Explaining kernel primitives (Linux namespaces, cgroups), signal forwarding to **PID 1**, process substitution via `exec`, and UnionFS layer mechanics.
2. **Configuration & Script Debugging**: Troubleshooting setup scripts, resolving WP-CLI memory limits in Alpine Linux, and configuring `mariadb-install-db` bootstrap logic.
