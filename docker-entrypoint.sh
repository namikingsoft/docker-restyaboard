#!/bin/bash

set -e

if [ "$1" = 'start' ]; then
  # config
  sed -i "s/^.*'R_DB_NAME'.*$/define('R_DB_NAME', 'restyaboard');/g" \
    /usr/share/nginx/html/server/php/config.inc.php
  sed -i "s/^.*'R_DB_USER'.*$/define('R_DB_USER', '${POSTGRES_ENV_POSTGRES_USER}');/g" \
    /usr/share/nginx/html/server/php/config.inc.php
  sed -i "s/^.*'R_DB_PASSWORD'.*$/define('R_DB_PASSWORD', '${POSTGRES_ENV_POSTGRES_PASSWORD}');/g" \
    /usr/share/nginx/html/server/php/config.inc.php
  sed -i "s/^.*'R_DB_HOST'.*$/define('R_DB_HOST', '${POSTGRES_PORT_5432_TCP_ADDR}');/g" \
    /usr/share/nginx/html/server/php/config.inc.php
  sed -i "s/^.*'R_DB_PORT'.*$/define('R_DB_PORT', '${POSTGRES_PORT_5432_TCP_PORT}');/g" \
    /usr/share/nginx/html/server/php/config.inc.php

  # cron shell
  chmod +x /usr/share/nginx/html/server/php/shell/*.sh
  echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/shell/indexing_to_elasticsearch.sh' > /var/spool/cron/root
  echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/shell/instant_email_notification.sh' > /var/spool/cron/root
  echo '0 * * * * php /usr/share/nginx/htmlserver/php/shell/periodic_email_notification.sh' > /var/spool/cron/root
  echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/shell/webhook.sh' > /var/spool/cron/root
  echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/shell/card_due_notification.sh' > /var/spool/cron/root
  echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/shell/imap.sh' > /var/spool/cron/root
 
  # media
  cp -R /tmp/media /usr/share/nginx/html/
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
  psql -c "CREATE DATABASE restyaboard ENCODING 'UTF8'"
  if [ "$?" = 0 ]; then
    psql -d restyaboard -f /usr/share/nginx/html/sql/restyaboard_with_empty_data.sql
  fi
  set -e

  # service start
  service cron start
  service php5-fpm start
  service nginx start
  service postfix start

  # tail log
  exec tail -f /var/log/nginx/access.log /var/log/nginx/error.log
fi

exec "$@"

