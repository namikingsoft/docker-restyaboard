#!/bin/bash

set -e

if [ "$1" = 'start' ]; then
  # config
  sed -i "s/^.*'R_DB_NAME'.*$/define('R_DB_NAME', 'restyaboard');/g" \
    /usr/share/nginx/html/server/php/R/config.inc.php
  sed -i "s/^.*'R_DB_USER'.*$/define('R_DB_USER', 'restya');/g" \
    /usr/share/nginx/html/server/php/R/config.inc.php
  sed -i "s/^.*'R_DB_PASSWORD'.*$/define('R_DB_PASSWORD', '${POSTGRES_ENV_POSTGRES_PASSWORD}');/g" \
    /usr/share/nginx/html/server/php/R/config.inc.php
  sed -i "s/^.*'R_DB_HOST'.*$/define('R_DB_HOST', '${POSTGRES_PORT_5432_TCP_ADDR}');/g" \
    /usr/share/nginx/html/server/php/R/config.inc.php
  sed -i "s/^.*'R_DB_PORT'.*$/define('R_DB_PORT', '${POSTGRES_PORT_5432_TCP_PORT}');/g" \
    /usr/share/nginx/html/server/php/R/config.inc.php
 
  # media 
  cp -R /tmp/media /usr/share/nginx/html
  chmod -R go+w /usr/share/nginx/html/media
  chmod -R go+w /usr/share/nginx/html/client/img

  # init db
  export PGHOST=$POSTGRES_PORT_5432_TCP_ADDR
  export PGPORT=$POSTGRES_PORT_5432_TCP_PORT
  export PGUSER=$POSTGRES_ENV_POSTGRES_USER
  export PGPASSWORD=$POSTGRES_ENV_POSTGRES_PASSWORD
  set +e
  while :
  do
    psql -c "\q"
    if [ "$?" = 0 ]; then
      break
    fi
    sleep 1
  done
  psql -c "CREATE USER restya WITH ENCRYPTED PASSWORD '${PGPASSWORD}'"
  psql -c "CREATE DATABASE restyaboard OWNER restya ENCODING 'UTF8'"
  if [ "$?" = 0 ]; then
    psql -d restyaboard -f /usr/share/nginx/html/sql/restyaboard_with_empty_data.sql
  fi
  set -e

  # service start
  crond
  php-fpm
  nginx
  postfix start

  # tail log
  exec tail -f /var/log/nginx/access.log /var/log/nginx/error.log
fi

exec "$@"

