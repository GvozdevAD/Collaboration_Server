#!/bin/bash
set -e

# Запускаем MinIO сервер в фоновом режиме
minio server --address :9000 --console-address :9001 /var/cs/s3store/data &

# Задаём URL MinIO сервера
echo "Ожидаем запуска MinIO..."
until curl -f "$MINIO_SERVER/minio/health/live"; do
  sleep 3
done
echo "MinIO запущен!"

# Проверяем подключение к MinIO
echo "Проверяем соединение с MinIO..."
if ! mc alias set myminio $MINIO_SERVER $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD || ! mc ls myminio/"$MINIO_BUCKET_NAME" >/dev/null 2>&1; then
    echo "Соединение не удалось или бакет не найден, запускаем скрипт инициализации..."
    /docker-entrypoint-initdb.d/init.sh
else
    echo "Соединение успешно и бакет существует, пропускаем скрипт инициализации..."
fi

# Ждём завершения процесса MinIO
wait