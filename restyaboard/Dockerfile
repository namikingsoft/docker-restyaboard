FROM debian:wheezy-backports

# restyaboard version
ENV restyaboard_version=v0.1.3

# update & install package
RUN \
 apt-get update -y &&\
 apt-get install -y bzip2 curl cron postgresql nginx &&\
 apt-get install -y php5 php5-fpm php5-curl php5-pgsql php5-imagick libapache2-mod-php5 &&\
 apt-get install -y nodejs nodejs-legacy &&\
 curl -L https://npmjs.org/install.sh | sh &&\
 npm install -g grunt-cli &&\
 echo "postfix postfix/mailname string example.com"\
 | debconf-set-selections &&\
 echo "postfix postfix/main_mailer_type string 'Internet Site'"\
 | debconf-set-selections &&\
 apt-get install -y postfix

# deploy app
RUN mkdir /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN \
 curl -L -o /tmp/restyaboard.tar.gz \
  https://github.com/RestyaPlatform/board/archive/${restyaboard_version}.tar.gz &&\
 tar xzvf /tmp/restyaboard.tar.gz --strip-components 1 &&\
 rm /tmp/restyaboard.tar.gz &&\
 cp -R media /tmp/ &&\
 cp restyaboard.conf /etc/nginx/conf.d &&\
 npm install &&\
 grunt build:live &&\
 rm -rf node_modules

# setting php-fpm
RUN \
 sed -i 's/^.*listen.mode = 0660$/listen.mode = 0660/'\
  /etc/php5/fpm/pool.d/www.conf &&\
 sed -i 's|^.*fastcgi_pass.*$|fastcgi_pass unix:/var/run/php5-fpm.sock;|'\
  /etc/nginx/conf.d/restyaboard.conf &&\
 sed -i -e "/fastcgi_pass/a fastcgi_param HTTPS 'off';"\
  /etc/nginx/conf.d/restyaboard.conf

# volume
VOLUME /usr/share/nginx/html/media

# entry point
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]

# expose port
EXPOSE 80
