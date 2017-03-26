FROM debian:stretch

ENV RESTYABOARD_VERSION=v0.4.2 \
    ROOT_DIR=/usr/share/nginx/html \
    CONF_FILE=/etc/nginx/conf.d/restyaboard.conf \
    SMTP_DOMAIN=localhost \
    SMTP_USERNAME=root \
    SMTP_PASSWORD=root \
    SMTP_SERVER=localhost \
    SMTP_PORT=465

# update & install package
RUN apt-get update && \
    echo "postfix postfix/mailname string localhost" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
    TERM=linux DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cron \
    curl \
    imagemagick \
    jq \
    libpq5 \
    nginx \
    php7.0 \
    php7.0-cli \
    php7.0-common \
    php7.0-curl \
    php7.0-fpm \
    php7.0-imagick \
    php7.0-imap \
    php7.0-ldap \
    php7.0-mbstring \
    php7.0-pgsql \
    php7.0-xml \
    postfix \
    postgresql-client \
    unzip

# deploy app
RUN curl -L -s -o /tmp/restyaboard.zip https://github.com/RestyaPlatform/board/releases/download/${RESTYABOARD_VERSION}/board-${RESTYABOARD_VERSION}.zip && \
    unzip /tmp/restyaboard.zip -d ${ROOT_DIR} && \
    rm /tmp/restyaboard.zip

# extensions
RUN curl -L -s -o /tmp/apps.json https://raw.githubusercontent.com/RestyaPlatform/board-apps/master/apps.json && \
    chmod -R go+w /tmp/apps.json && \
    mkdir -p "${ROOT_DIR}/client/apps" && \
	for fid in $(jq -r '.[] | .id + "-v" + .version' /tmp/apps.json); \
	do \
	    curl -L -s -G -o /tmp/$fid.zip https://github.com/RestyaPlatform/board-apps/releases/download/v1/$fid.zip; \
        file /tmp/$fid.zip | grep Zip && unzip /tmp/$fid.zip -d "${ROOT_DIR}/client/apps"; \
        rm /tmp/$fid.zip; \
	done && \
    rm /tmp/apps.json

# setting app
WORKDIR ${ROOT_DIR}
RUN rm /etc/nginx/sites-enabled/default && \
    cp restyaboard.conf ${CONF_FILE} && \
    sed -i "s/server_name.*$/server_name \"localhost\";/" ${CONF_FILE} && \
	sed -i "s|listen 80.*$|listen 80;|" ${CONF_FILE} && \
    sed -i "s|root.*html|root ${ROOT_DIR}|" ${CONF_FILE} && \
    chown -R www-data:www-data . && \
    chmod -R 777 media && \
    chmod -R 777 client/img && \
    chmod -R 777 tmp

# cleanup
RUN apt-get autoremove -y --purge && \
    apt-get clean

# entry point
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
