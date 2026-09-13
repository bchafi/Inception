NAME = inception

SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml
DATA_PATH = /home/bchafi/data

all: build

build:
	@echo "Creating host data persistent directories if missing..."
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	@echo "Building and starting Inception infrastructure..."
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down

clean: down
	@echo "Cleaning container images..."
	docker compose -f $(COMPOSE_FILE) down --rmi all

fclean:
	@echo "Full purge of infrastructure, volumes, and host storage..."
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	docker system prune -af

re: fclean all

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

ps:
	docker compose -f $(COMPOSE_FILE) ps

images:
	docker compose -f $(COMPOSE_FILE) images

.PHONY: all build down clean fclean re logs ps