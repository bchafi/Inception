# Name of the project
NAME = inception

# Paths
SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml
DATA_PATH = /home/bchafi/data

# Phony targets to prevent conflicts with files of the same name
.PHONY: all build up down clean fclean re logs ps

# Default rule
all: build

# Create necessary host directories and launch the stack
build:
	@echo "Creating host data persistent directories if missing..."
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	@echo "Building and starting Inception infrastructure..."
	docker compose -f $(COMPOSE_FILE) up -d --build

# Stop the containers without deleting volume data
down:
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down

# Stop containers and remove images and networks
clean: down
	@echo "Cleaning container images..."
	docker compose -f $(COMPOSE_FILE) down --rmi all

# Full purge: remove containers, images, volumes, and wipe host data directories
fclean:
	@echo "Full purge of infrastructure, volumes, and host storage..."
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	docker system prune -af

# Rebuild everything from a completely clean state
re: fclean all

# Helper targets for debugging during evaluation
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

ps:
	docker compose -f $(COMPOSE_FILE) ps

images:
	docker compose -f $(COMPOSE_FILE) images