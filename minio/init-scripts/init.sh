#!/bin/bash
set -e

# Устанавливаем MINIO_SERVER, если он не задан
MINIO_SERVER="${MINIO_SERVER:-http://localhost:9000}"

echo "Ожидаем клиента MinIO (mc)..."
until mc alias set myminio "$MINIO_SERVER" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"; do
  sleep 1
done
echo "Алиас установлен"

mc mb myminio/"$MINIO_BUCKET_NAME" || echo "Бакет уже существует"
echo "Бакет настроен"

mc admin policy attach myminio readwrite --user "$MINIO_TMS_USER"
echo "Политика привязана"

mc admin accesskey create myminio --access-key "$MINIO_ACCESS_KEY_ID" --secret-key "$MINIO_SECRET_KEY"
echo "Ключ доступа создан"