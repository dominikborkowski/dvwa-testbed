FROM debian:stretch-slim

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debconf-utils && \
    echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apache2 \
        mariadb-server \
        php \
        php-mysql \
        php-pgsql \
        php-pear \
        php-gd \
        iputils-ping \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY php.ini /etc/php5/apache2/php.ini
COPY DVWA/ /var/www/html

COPY config.inc.php /var/www/html/config/

COPY dvwa.sql /root/dvwa.sql

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html

RUN service mysql start && \
    sleep 3 && \
    mysql -uroot -pvulnerables -e "CREATE USER app@localhost IDENTIFIED BY 'vulnerables';CREATE DATABASE dvwa;GRANT ALL privileges ON dvwa.* TO 'app'@localhost;" && \
    mysql -uroot -pvulnerables dvwa < /root/dvwa.sql

EXPOSE 80

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
