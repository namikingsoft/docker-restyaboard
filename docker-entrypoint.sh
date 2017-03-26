#!/bin/bash
set -e

if [ "$1" = 'start' ]; then

  # config
  sed -i "s/^.*'R_DB_HOST'.*$/define('R_DB_HOST', '${POSTGRES_HOST}');/g" \
    ${ROOT_DIR}/server/php/config.inc.php
  sed -i "s/^.*'R_DB_PORT'.*$/define('R_DB_PORT', '5432');/g" \
    ${ROOT_DIR}/server/php/config.inc.php
  sed -i "s/^.*'R_DB_USER'.*$/define('R_DB_USER', '${POSTGRES_USER}');/g" \
    ${ROOT_DIR}/server/php/config.inc.php
  sed -i "s/^.*'R_DB_PASSWORD'.*$/define('R_DB_PASSWORD', '${POSTGRES_PASSWORD}');/g" \
    ${ROOT_DIR}/server/php/config.inc.php
  sed -i "s/^.*'R_DB_NAME'.*$/define('R_DB_NAME', '${POSTGRES_DB}');/g" \
    ${ROOT_DIR}/server/php/config.inc.php

  # postfix
  echo "[${SMTP_SERVER}]:${SMTP_PORT} ${SMTP_USERNAME}:${SMTP_PASSWORD}" > /etc/postfix/sasl_passwd
  postmap /etc/postfix/sasl_passwd
  echo "www-data@${SMTP_DOMAIN} ${SMTP_USERNAME}" > /etc/postfix/sender_canonical
  postmap /etc/postfix/sender_canonical
  sed -i '/mydomain.*/d' /etc/postfix/main.cf
  sed -i '/myhostname.*/d' /etc/postfix/main.cf
  sed -i '/myorigin.*/d' /etc/postfix/main.cf
  sed -i '/mydestination.*/d' /etc/postfix/main.cf
  sed -i "$ a mydomain = ${SMTP_DOMAIN}" /etc/postfix/main.cf
  sed -i "$ a myhostname = localhost" /etc/postfix/main.cf
  sed -i '$ a myorigin = $mydomain' /etc/postfix/main.cf
  sed -i '$ a mydestination = localhost, $myhostname, localhost.$mydomain' /etc/postfix/main.cf
  sed -i '$ a sender_canonical_maps = hash:/etc/postfix/sender_canonical' /etc/postfix/main.cf
  sed -i "s/relayhost =.*$/relayhost = [${SMTP_SERVER}]:${SMTP_PORT}/" /etc/postfix/main.cf
  sed -i '/smtp_.*/d' /etc/postfix/main.cf
  sed -i '$ a smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache' /etc/postfix/main.cf
  sed -i '$ a smtp_sasl_auth_enable = yes' /etc/postfix/main.cf
  sed -i '$ a smtp_sasl_security_options = noanonymous' /etc/postfix/main.cf
  sed -i '$ a smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd' /etc/postfix/main.cf
  sed -i '$ a smtp_use_tls = yes' /etc/postfix/main.cf
  sed -i '$ a smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt' /etc/postfix/main.cf
  sed -i '$ a smtp_tls_wrappermode = yes' /etc/postfix/main.cf
  sed -i '$ a smtp_tls_security_level = encrypt' /etc/postfix/main.cf

  # init db
  export PGHOST=${POSTGRES_HOST}
  export PGPORT=5432
  export PGUSER=${POSTGRES_USER}
  export PGPASSWORD=${POSTGRES_PASSWORD}
  export PGDATABASE=${POSTGRES_DB}
  set +e
  while :
  do
    psql -c "\q"
    if [ "$?" = 0 ]; then
      break
    fi
    sleep 1
  done
  if [ "$(psql -c '\d')" = "No relations found." ]; then
    psql -f "${ROOT_DIR}/sql/restyaboard_with_empty_data.sql"
  fi
  set -e

  # cron shell
  echo "*/5 * * * * ${ROOT_DIR}/server/php/shell/instant_email_notification.sh" >> /var/spool/cron/crontabs/root
  echo "0 * * * * ${ROOT_DIR}/server/php/shell/periodic_email_notification.sh" >> /var/spool/cron/crontabs/root
  echo "*/30 * * * * ${ROOT_DIR}/server/php/shell/imap.sh" >> /var/spool/cron/crontabs/root
  echo "*/5 * * * * ${ROOT_DIR}/server/php/shell/webhook.sh" >> /var/spool/cron/crontabs/root
  echo "*/5 * * * * ${ROOT_DIR}/server/php/shell/card_due_notification.sh" >> /var/spool/cron/crontabs/root

  # service start
  service cron start
  service php7.0-fpm start
  service nginx start
  service postfix start

  # tail log
  exec tail -f /var/log/nginx/access.log /var/log/nginx/error.log
fi

exec "$@"
