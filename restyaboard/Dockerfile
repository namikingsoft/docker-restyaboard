FROM centos:7

# add repository
RUN \
rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7; \
rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/packages/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm; \
sed -i 's/^enabled=1$/enabled=0/g' /etc/yum.repos.d/epel.repo; \
rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi; \
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
COPY etc/yum.repos.d/nginx.repo /etc/yum.repos.d/

# update & install package
RUN \
yum update -y; \
yum install -y bzip2 cronie postfix postgresql; \
yum install -y --enablerepo=nginx nginx; \
yum install -y --enablerepo=remi-php56\
 php php-fpm php-pgsql php-mbstring php-pecl-imagick; \
yum install -y --enablerepo=epel nodejs npm
RUN npm install -g grunt-cli

# setting php-fpm
RUN \
sed -i 's/^user = apache$/user = nginx/g' /etc/php-fpm.d/www.conf; \
sed -i 's/^group = apache$/group = nginx/g' /etc/php-fpm.d/www.conf

# remove document root
RUN rm -rf /usr/share/nginx/html

# volume
VOLUME /usr/share/nginx/html/media

# entry point
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]

# expose port
EXPOSE 80
