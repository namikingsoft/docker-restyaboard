#!/bin/bash

set -e

if [ "$1" = 'start' ]; then
  # deploy
  if [ ! -e /usr/share/nginx/html/restyaboard.conf ]; then
    cd /tmp
    curl -L -o restyaboard.tar.gz https://github.com/RestyaPlatform/board/archive/${RESTYABOARD_VERSION}.tar.gz
    mkdir html && tar xzvf restyaboard.tar.gz -C html --strip-components 1
    cp -rf html /usr/share/nginx/
    cd /usr/share/nginx/html
    cp restyaboard.conf /etc/nginx/conf.d
    npm install
    grunt build:live
  fi

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
  echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/R/shell/cron.php' > /var/spool/cron/root
 
  # media
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

