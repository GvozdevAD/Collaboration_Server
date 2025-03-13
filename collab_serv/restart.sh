#!/bin/bash
set -e

echo "Starting restart script..."
sleep 10

echo "Stopping services..."
if ! ring hazelcast --instance hcdev service stop; then
    echo "ERROR: Не удалось остановить Hazelcast."
    exit 1
fi
if ! ring elasticsearch --instance esdev service stop; then
    echo "ERROR: Не удалось остановить Elasticsearch."
    exit 1
fi
if ! ring cs --instance csdev service stop; then
    echo "ERROR: Не удалось остановить сервис CS."
    exit 1
fi

echo "Waiting for services to stop..."
sleep 10

echo "Starting services..."
if ! ring hazelcast --instance hcdev service start; then
    echo "ERROR: Не удалось запустить Hazelcast."
    exit 1
fi
sleep 1
if ! ring elasticsearch --instance esdev service start; then
    echo "ERROR: Не удалось запустить Elasticsearch."
    exit 1
fi
sleep 1
if ! ring cs --instance csdev service start; then
    echo "ERROR: Не удалось запустить сервис CS."
    exit 1
fi

echo "Restart completed successfully!"
