#!/bin/bash
set -e
set -x  

if [[ -z "$MINIO_SERVER" || -z "$MINIO_BUCKET_NAME" || -z "$MINIO_ACCESS_KEY_ID" || -z "$MINIO_SECRET_KEY" || -z "$POSTGRES_URL" || -z "$POSTGRES_USER" || -z "$POSTGRES_PWD" || -z "$POSTGRES_DB" ]]; then
    echo "ERROR: Некоторые переменные окружения не установлены. Пожалуйста, проверьте .env файл."
    exit 1
fi

echo "Ожидаем запуска MinIO..."
until curl -s "http://minio:9000/minio/health/live" >/dev/null 2>&1; do
    echo "MinIO ещё не готов, ждём 3 секунды..."
    sleep 3
done
echo "MinIO готов!"

echo "Настройка пула common для PostgreSQL..."
if ! ring cs --instance csdev jdbc pools --name common set-params --url "jdbc:$POSTGRES_URL/$POSTGRES_DB?currentSchema=public"; then
    echo "ERROR: Не удалось установить параметры для PostgreSQL (common)."
    exit 1
fi
if ! ring cs --instance csdev jdbc pools --name common set-params --username "$POSTGRES_USER"; then
    echo "ERROR: Не удалось установить параметры для PostgreSQL (common username)."
    exit 1
fi
if ! ring cs --instance csdev jdbc pools --name common set-params --password "$POSTGRES_PWD"; then
    echo "ERROR: Не удалось установить параметры для PostgreSQL (common password)."
    exit 1
fi

echo "Настройка пула privileged для PostgreSQL..."
if ! ring cs --instance csdev jdbc pools --name privileged set-params --url "jdbc:$POSTGRES_URL/$POSTGRES_DB?currentSchema=public"; then
    echo "ERROR: Не удалось установить параметры для PostgreSQL (privileged)."
    exit 1
fi
if ! ring cs --instance csdev jdbc pools --name privileged set-params --username "$POSTGRES_USER"; then
    echo "ERROR: Не удалось установить параметры для PostgreSQL (privileged username)."
    exit 1
fi
if ! ring cs --instance csdev jdbc pools --name privileged set-params --password "$POSTGRES_PWD"; then
    echo "ERROR: Не удалось установить параметры для PostgreSQL (privileged password)."
    exit 1
fi

echo "Настройка WebSocket..."
if ! ring cs --instance csdev websocket set-params --hostname "0.0.0.0"; then
    echo "ERROR: Не удалось установить параметры для WebSocket."
    exit 1
fi
if ! ring cs --instance csdev websocket set-params --port 9090; then
    echo "ERROR: Не удалось установить параметры для WebSocket (порт)."
    exit 1
fi

./restart.sh


echo "Ожидаем готовности сервиса на порту 8087..."
until curl -s "http://localhost:8087" >/dev/null 2>&1; do
    echo "Сервис ещё не готов, ждём 3 секунды..."
    sleep 3
done
echo "Сервис на порту 8087 готов!"

echo "Конфигурация PostgreSQL bucket server..."
if ! curl -Sf \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"jdbc:$POSTGRES_URL/$POSTGRES_DB\", \"username\": \"$POSTGRES_USER\", \"password\": \"$POSTGRES_PWD\", \"enabled\": true}" \
    -u admin:admin "http://localhost:8087/admin/bucket_server"; then
    echo "ERROR: Не удалось настроить PostgreSQL bucket server."
    exit 1
fi

echo "Конфигурация MinIO storage server..."
if ! curl -Sf \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"apiType\": \"AMAZON\", \"storageType\": \"DEFAULT\", \"baseUrl\": \"$MINIO_SERVER\", \"containerUrl\": \"$MINIO_SERVER/\${container_name}\", \"pathStyleAccessEnabled\": true, \"containerName\": \"$MINIO_BUCKET_NAME\", \"region\": \"eu-west-1\", \"accessKeyId\": \"$MINIO_ACCESS_KEY_ID\", \"secretKey\": \"$MINIO_SECRET_KEY\", \"signatureVersion\": \"V4\", \"uploadLimit\": 1073741824, \"downloadLimit\": 1073741824, \"fileSizeLimit\": 104857600, \"bytesToKeep\": 104857600, \"daysToKeep\": 31}" \
    -u admin:admin "http://localhost:8087/admin/storage_server"; then
    echo "ERROR: Не удалось настроить MinIO storage server."
    exit 1
fi

echo "Скрипт выполнен успешно!"
