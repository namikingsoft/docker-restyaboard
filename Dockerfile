FROM alpine:3.5

ENV RESTYABOARD_VERSION=v0.4.2 \
    ROOT_DIR=/usr/share/nginx/html \
    CONF_DIR=/etc/nginx/conf.d \
    SMTP_DOMAIN=localhost \
    SMTP_USERNAME=root \
    SMTP_PASSWORD=root \
    SMTP_SERVER=localhost \
    SMTP_PORT=465

# install packages
RUN apk add --update \
    curl \
    file \
    imagemagick \
    jq \
    nginx \
    php7 \
    postfix \
    postgresql-client \
    unzip && \
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
    rm /tmp/apps.json

# configure app
RUN addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && \
    mkdir -p ${CONF_DIR} && \
    cp ${ROOT_DIR}/restyaboard.conf ${CONF_DIR} && \
    sed -i "s/server_name.*$/server_name \"localhost\";/" ${CONF_DIR}/restyaboard.conf && \
    sed -i "s|listen 80.*$|listen 80;|" ${CONF_DIR}/restyaboard.conf && \
    sed -i "s|root.*html|root ${ROOT_DIR}|" ${CONF_DIR}/restyaboard.conf && \
    chown -R www-data:www-data ${ROOT_DIR} && \
    chmod -R 777 ${ROOT_DIR}/media && \
    chmod -R 777 ${ROOT_DIR}/client/img && \
    chmod -R 777 ${ROOT_DIR}/tmp

# entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
WORKDIR ${ROOT_DIR}
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
