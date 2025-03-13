# Сервер взаимодействия 1С с PostgreSQL и MinIO в Docker 🚀

## Навигация

- [Описание](#описание)
- [Состав проекта](#состав-проекта)
- [Требования](#требования)
- [Конфигурация](#конфигурация)
- [Установка и запуск](#установка-и-запуск)
- [Управление контейнерами](#управление-контейнерами)
- [Просмотр логов](#просмотр-логов)

## Описание

Проект предназначен для развертывания сервера взаимодействия 1С с PostgreSQL и MinIO с помощью Docker Compose.  
Сервис MinIO доступен по порту `9000` и используется 1С для хранения объектов.

## Состав проекта

| Сервис         | Описание                         | Версия                           |
|----------------|----------------------------------|----------------------------------|
| `collab_server`| Сервер взаимодействия 1С         | 26.0.53 (Debian Bookworm)        |
| `postgres_db`  | База данных PostgreSQL           | 17.3                             |
| `minio`        | Объектное хранилище              | RELEASE.2025-02-28T09-55-16Z     |

### Сети и порты

| Сервис         | Порты                           | Сеть           |
|----------------|----------------------------------|----------------|
| `collab_server`| `9090:9090` (хост:контейнер)     | `external_net` |
| `postgres_db`  | `5432` (внутренний доступ)       | `internal_net` |
| `minio`        | `9000:9000` (API), `9001` (UI)   | `internal_net` |

## Требования

- **Docker**: ≥ 28.0.1  
  Проверка: `docker --version`
- **Docker Compose (plugin)**: ≥ v2.33.1  
  Проверка: `docker compose version`
- Архивы:
  - `1c_cs_26.0.53_linux_x86_64.tar.gz`
  - `axiomjdk-jre-pro11.0.25+11-linux-amd64.deb`

## Конфигурация

### Переменные окружения

Все параметры задаются в `.env` (см. пример в `.env.example`).

- **PostgreSQL**:
  - `POSTGRES_URL`, `POSTGRES_USER`, `POSTGRES_PWD`, `POSTGRES_DB`
- **MinIO**:
  - `MINIO_SERVER`, `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_BUCKET_NAME`, `MINIO_ACCESS_KEY_ID`, `MINIO_SECRET_KEY`

**Генерация ключей для MinIO:**

```bash
openssl rand -hex 10  # MINIO_ACCESS_KEY_ID (20 символов)
openssl rand -hex 16  # MINIO_SECRET_KEY (32 символа)
```

## Установка и запуск

```bash
# Клонируйте репозиторий
git clone <URL_репозитория>
cd <папка_проекта>

# Скопируйте архивы в каталог collab_serv/
cp 1c_cs_26.0.53_linux_x86_64.tar.gz ./collab_serv/
cp axiomjdk-jre-pro11.0.25+11-linux-amd64.deb ./collab_serv/

# Настройте окружение
cp .env.example .env
# (отредактируйте .env при необходимости)

# Сборка и запуск
make up_build
```

## Управление контейнерами

| Команда             | Описание                         |
|---------------------|----------------------------------|
| `make stop`         | Остановка всех сервисов          |
| `make restart`      | Перезапуск сервисов              |
| `make prune`        | Очистка ресурсов                 |
| `make conn_cs`      | Подключение к collab_server      |
| `make conn_psql`    | Подключение к PostgreSQL         |
| `make conn_mi`      | Подключение к MinIO              |

## Просмотр логов

| Команда             | Описание                         |
|---------------------|----------------------------------|
| `make logs_all`     | Логи всех контейнеров            |
| `make logs_cs`      | Логи collab_server               |
| `make logs_pg`      | Логи PostgreSQL                  |
| `make logs_mi`      | Логи MinIO                       |