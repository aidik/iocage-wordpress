#!/bin/csh

set dbadmin="`openssl rand -base64 12`"
echo $dbadmin
set wpdbuser="`openssl rand -base64 12`"
echo $wpdbuser
set wpadmin="`openssl rand -base64 12`"
echo $wpadmin

sysrc mysql_enable="YES"
sysrc nginx_enable="YES"
sysrc php_fpm_enable="YES"
service mysql-server start
service nginx start

printf "\n\n$abadmin\n$dbadmin\n\n\n\n\n\n " | mysql_secure_installation

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
#wp core config
#wp core install