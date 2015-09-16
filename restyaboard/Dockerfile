FROM centos:7

# update package
RUN yum update -y
RUN yum install -y git bzip2 postgresql cronie

# add repository
RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
RUN rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/packages/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN sed -i 's/^enabled=1$/enabled=0/g' /etc/yum.repos.d/epel.repo
RUN rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# install nginx
COPY etc/yum.repos.d/nginx.repo /etc/yum.repos.d/
RUN yum install -y --enablerepo=nginx nginx

# install postfix
RUN yum install -y postfix

# install php5.6
RUN yum install -y --enablerepo=remi-php56\
 php php-fpm php-pgsql php-mbstring php-pecl-imagick
RUN sed -i 's/^user = apache$/user = nginx/g' /etc/php-fpm.d/www.conf
RUN sed -i 's/^group = apache$/group = nginx/g' /etc/php-fpm.d/www.conf

# install node.js
RUN yum install -y --enablerepo=epel nodejs npm
RUN npm install -g grunt-cli

# install restyaboard
RUN rm -rf /usr/share/nginx/html
RUN git clone https://github.com/RestyaPlatform/board.git\
 /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN cp restyaboard.conf /etc/nginx/conf.d
RUN cp -R media /tmp
RUN npm install
RUN grunt build:live
RUN echo '*/5 * * * * php /usr/share/nginx/htmlserver/php/R/shell/cron.php'\
 > /var/spool/cron/root

# volume
VOLUME /usr/share/nginx/html/media

# entry point
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
