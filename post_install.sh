#!/bin/csh

set dbadmin="`openssl rand -base64 12`"
echo "DB Root Password"
echo $dbadmin
set wpdbuser="`openssl rand -base64 12`"
echo "WPDB User Password"
echo $wpdbuser
set wpadmin="`openssl rand -base64 12`"
echo "WP Admin Password"
echo $wpadmin

sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf nginx_enable="YES"
sysrc -f /etc/rc.conf php_fpm_enable="YES"

service mysql-server start

printf "\n\n$dbadmin\n$dbadmin\n\n\n\n"
printf "\n\n$dbadmin\n$dbadmin\n\n\n\n" | mysql_secure_installation

mysql -u root -p$dbadmin -e "create database wpdb;"
mysql -u root -p$dbadmin -e "grant all privileges on wpdb.* to wpdbuser@'%' identified by '$wpdbuser';"
mysql -u root -p$dbadmin -e "FLUSH PRIVILEGES;"

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
mkdir /usr/local/www/wp
cd /usr/local/www/wp
chown -R www:wheel /usr/local/www/wp/
sudo -u www wp core download
sudo -u www wp config create --dbname=wpdb --dbuser=wpdbuser --dbpass=$wpdbuser
sudo -u www wp core install --url=wordpress.local --title=iocage-wp-plugin --admin_user=wpadmin --admin_password=$wpadmin --admin_email=no@email.sry

cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini

/sed -i "" 's%;open_basedir =%open_basedir = /usr/local/www/wp:/tmp%g' /usr/local/etc/php.ini
/sed -i "" 's/memory_limit = 128M/memory_limit = 256M/g' /usr/local/etc/php.ini
/sed -i "" 's/post_max_size = 8M/post_max_size = 32M/g' /usr/local/etc/php.ini
/sed -i "" 's/upload_max_filesize = 2M/upload_max_filesize = 32M/g' /usr/local/etc/php.ini
/sed -i "" 's/max_execution_time = 30/max_execution_time = 180/g' /usr/local/etc/php.ini
/sed -i "" 's/max_input_time = 60/max_input_time = 180/g' /usr/local/etc/php.ini

/sed -i "" 's%listen = 127.0.0.1:9000%listen = 127.0.0.1:9000%g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;listen.owner = www/listen.owner = www/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;listen.group = www/listen.group = www/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;listen.mode = 0660/listen.mode = 0660/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/pm = dynamic/pm = ondemand/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/pm.max_children = 5/pm.max_children = 50/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;pm.process_idle_timeout = 10s;/pm.process_idle_timeout = 30s/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;pm.max_requests = 500/pm.max_requests = 500/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;security.limit_extensions = .php .php3 .php4 .php5 .php7/security.limit_extensions = .php .php3 .php4 .php5 .php7/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;php_flag[display_errors] = off/php_flag[display_errors] = off/g' /usr/local/etc/php-fpm.d/www.conf
/sed -i "" 's/;php_admin_flag[log_errors] = on/php_admin_flag[log_errors] = on/g' /usr/local/etc/php-fpm.d/www.conf

service php-fpm start

nginx -t
service nginx start
