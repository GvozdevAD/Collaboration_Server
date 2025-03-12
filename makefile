include .env
export

CS_IMAGE_NAME = collab_server
PG_IMAGE_NAME = postgres_db
MI_IMAGE_NAME = minio

.PHONY: help
help:
	@echo "Makefile доступные команды:"
	@echo "----------- Docker Compose ----------"
	@echo "	 up_build 		  - Сборка и запуск"
	@echo "	 build 			  - Сборка контейнеров"
	@echo "	 stop 			  - Остановка контейнеров"
	@echo "	 restart 		  - Перезапуск всех контейнеров"

	@echo "----------- Dockerfile Сервер Взаимодействия ------------"
	@echo "  build_cs         - Собрать образ Docker для сервера взаимодействия."
	@echo "  run_cs           - Запустить отдельно контейнер для сервера взаимодействия."
	@echo "  stop_cs          - Остановить и удалить контейнер сервера взаимодействия."
	@echo "  clean_cs         - Удалить образ сервера взаимодействия."
	@echo "  conn_cs          - Подключиться к контейнеру сервера взаимодействия через bash."

	@echo "----------- Dockerfile PostgreSQL ------------"
	@echo "  build_pg         - Собрать образ Docker для PostgreSQL."
	@echo "  run_pg           - Запустить отдельно контейнер для PostgreSQL."
	@echo "  stop_pg          - Остановить и удалить контейнер PostgreSQL."
	@echo "  clean_pg         - Удалить образ PostgreSQL."
	@echo "  conn_psql        - Подключиться к контейнеру PostgreSQL и запустить psql."
	
	@echo "----------- Dockerfile MinIO ------------"
	@echo "  build_mi         - Собрать образ Docker для MinIO."
	@echo "  run_mi           - Запустить отдельно контейнер для MinIO."
	@echo "  stop_mi          - Остановить и удалить контейнер MinIO."
	@echo "  clean_mi         - Удалить образ MinIO."
	@echo "  conn_mi	  - Подключится к контейнеру MinIO через bash."

	@echo "----------- Логи -----------"
	@echo "  logs_all          - Показать логи всех контейнеров."
	@echo "  logs_cs           - Показать логи контейнера сервера взаимодействия."
	@echo "  logs_pg           - Показать логи контейнера PostgreSQL."
	@echo "  logs_mi           - Показать логи контейнера MinIO."

	@echo "----------- Очистка -----------"
	@echo "  prune             - Очистка неиспользуемых контейнеров, образов и других ресурсов."

.PHONY: up_build
up_build:
	docker compose up -d --build

.PHONY: build
build:
	docker compose build

.PHONY: stop
stop:
	docker compose stop

.PHONY: restart
restart:
	docker compose down
	docker compose up -d --build

.PHONY: build_cs
build_cs:
	docker build -t $(CS_IMAGE_NAME) ./collab_serv/.

.PHONY: run_cs
run_cs:
	docker run -d --name ${CS_IMAGE_NAME} \
	--env-file .env \
	${CS_IMAGE_NAME}

.PHONY: stop_cs
stop_cs:
	-docker stop ${CS_IMAGE_NAME}
	-docker rm ${CS_IMAGE_NAME}

.PHONY: clean_cs
clean_cs:
	docker rmi -f ${CS_IMAGE_NAME}

.PHONY: conn_cs
conn_cs:
	docker exec -it ${CS_IMAGE_NAME} /bin/bash

.PHONY: conn_psql
conn_psql:
	docker exec -it ${PG_IMAGE_NAME} psql -U $${POSTGRES_USER} -d $${POSTGRES_DB}

.PHONY: build_pg
build_pg:
	docker build -t $(PG_IMAGE_NAME) ./postgresql/.

.PHONY: run_pg
run_pg:
	docker run -d --name ${PG_IMAGE_NAME} \
	--env-file .env \
	${PG_IMAGE_NAME}

.PHONY: stop_pg
stop_pg:
	-docker stop ${PG_IMAGE_NAME}
	-docker rm ${PG_IMAGE_NAME}

.PHONY: clean_pg
clean_pg:
	docker rmi -f ${PG_IMAGE_NAME}

.PHONY: build_mi
build_mi:
	docker build -t $(MI_IMAGE_NAME) ./minio/.

.PHONY: run_mi
run_mi:
	docker run -d --name ${MI_IMAGE_NAME} \
	--env-file .env \
	${MI_IMAGE_NAME}

.PHONY: stop_mi
stop_mi:
	-docker stop ${MI_IMAGE_NAME}
	-docker rm ${MI_IMAGE_NAME}

.PHONY: clean_mi
clean_mi:
	docker rmi -f ${MI_IMAGE_NAME}

.PHONY: conn_mi
conn_mi:
	docker exec -it ${MI_IMAGE_NAME} /bin/bash 

.PHONY: logs_all
logs_all:
	docker-compose logs -f

.PHONY: logs_cs
logs_cs:
	docker logs ${CS_IMAGE_NAME}

.PHONY: logs_pg
logs_pg:
	docker logs ${PG_IMAGE_NAME}

.PHONY: logs_mi
logs_mi:
	docker logs ${MI_IMAGE_NAME}

.PHONY: prune
prune:
	docker system prune -f


.PHONY: prune_volume
prune_volume:
	docker volume prune -f

.PHONY: del_all
del_all: stop
	docker rm collab_server
	docker rm minio
	docker rm postgres_db
	docker rmi collaboration_server-collab_server
	docker rmi collaboration_server-postgres_image
	docker rmi collaboration_server-minio_image
	docker volume rm collaboration_server_minio_data
	docker volume rm collaboration_server_pgdata
	docker volume rm collaboration_server_cs_data

	docker system prune -f
	docker volume prune -f
