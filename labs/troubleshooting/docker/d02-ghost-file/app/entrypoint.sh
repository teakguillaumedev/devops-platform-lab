#!/bin/sh
set -e
echo "entrypoint: rendering config for env=${APP_ENV:-dev}"
echo "listen=0.0.0.0:8080" > /tmp/app.conf
echo "entrypoint: config ready, starting app"
exec "$@"
