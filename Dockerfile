FROM alpine:3.5

ENV RESTYABOARD_VERSION=v0.5 \
    ROOT_DIR=/usr/share/nginx/html \
    CONF_DIR=/etc/nginx/conf.d \
    SMTP_DOMAIN=localhost \
    SMTP_USERNAME=root \
    SMTP_PASSWORD=root \
    SMTP_SERVER=localhost \
    SMTP_PORT=465 \
    TZ=Etc/UTC

# install packages
RUN apk add --update \
    curl \
    file \
    imagemagick \
    jq \
    nginx \
    openssl \
    php7 \
    php7-curl \
    php7-fpm \
    php7-imap \
    php7-json \
    php7-mbstring \
    php7-pdo \
    php7-pdo_pgsql \
    php7-pgsql \
    php7-xml \
    postfix \
    postgresql-client \
    supervisor \
    tzdata \
    unzip && \
    rm -rf /var/cache/apk/*

RUN curl -L -s -o /etc/apk/keys/php-alpine.rsa.pub http://php.codecasts.rocks/php-alpine.rsa.pub && \
    echo "http://php.codecasts.rocks/7.0" >> /etc/apk/repositories && \
    apk add --update php7-imagick && \
    rm -rf /var/cache/apk/*

# deploy app and extensions
RUN curl -L -s -o /tmp/restyaboard.zip https://github.com/RestyaPlatform/board/releases/download/${RESTYABOARD_VERSION}/board-${RESTYABOARD_VERSION}.zip && \
    mkdir -p  ${ROOT_DIR} && \
    unzip /tmp/restyaboard.zip -d ${ROOT_DIR} && \
    rm /tmp/restyaboard.zip && \
    curl -L -s -o /tmp/apps.json https://raw.githubusercontent.com/RestyaPlatform/board-apps/master/apps.json && \
    chmod -R go+w /tmp/apps.json && \
    mkdir -p "${ROOT_DIR}/client/apps" && \
    for fid in $(jq -r '.[] | .id + "-v" + .version' /tmp/apps.json); \
    do \
        curl -L -s -G -o /tmp/$fid.zip https://github.com/RestyaPlatform/board-apps/releases/download/v1/$fid.zip; \
        file /tmp/$fid.zip | grep Zip && unzip /tmp/$fid.zip -d "${ROOT_DIR}/client/apps"; \
        rm /tmp/$fid.zip; \
    done && \
    rm /tmp/apps.json && \
    apk del file jq

# configure app
RUN addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && \
    sed -i "s/user nginx;/user www-data;/" /etc/nginx/nginx.conf && \
    rm /etc/nginx/conf.d/default.conf && \
    mkdir -p ${CONF_DIR} && \
    cp ${ROOT_DIR}/restyaboard.conf ${CONF_DIR} && \
    sed -i "s/server_name.*$/server_name \"localhost\";/" ${CONF_DIR}/restyaboard.conf && \
    sed -i "s|listen 80.*$|listen 80;|" ${CONF_DIR}/restyaboard.conf && \
    sed -i "s|root.*html|root ${ROOT_DIR}|" ${CONF_DIR}/restyaboard.conf && \
    sed -i "s|user = nobody|user = www-data|" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|group = nobody|group = www-data|" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|listen = 127.0.0.1:9000|listen = /run/php/php7.0-fpm.sock|" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner = nobody|listen.owner = www-data|" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = www-data|" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;listen.mode = 0660|listen.mode = 0660|" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|GLOB_BRACE|defined('GLOB_BRACE') ? GLOB_BRACE : 0|g" ${ROOT_DIR}/server/php/R/r.php && \
    chown -R www-data:www-data ${ROOT_DIR} && \
    chmod -R 777 ${ROOT_DIR}/media && \
    chmod -R 777 ${ROOT_DIR}/client/img && \
    chmod -R 777 ${ROOT_DIR}/tmp && \
    chmod +x ${ROOT_DIR}/server/php/shell/*.sh && \
    sed -i "s|bin/bash|bin/sh|" ${ROOT_DIR}/server/php/shell/*.sh && \
    sed -i "s|php |php7 |g" ${ROOT_DIR}/server/php/shell/*.sh && \
    chown -R www-data:www-data /var/lib/nginx && \
    mkdir -p /run/nginx && \
    mkdir -p /run/php

# entrypoint
COPY supervisord.conf /supervisord.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
