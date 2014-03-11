#!/bin/bash

set -e

# render config templates
envtpl /opt/xhprof/xhprof_lib/config.php.tpl
envtpl /etc/apache2/sites-enabled/xhprof_vhost.conf.tpl

[ -n "$HTTP_AUTH_USER" ] && htpasswd -cb /etc/apache2/htpasswd "$HTTP_AUTH_USER" "$HTTP_AUTH_PASS"

set -eu

# start mysql in the background while we create user accounts
mysqld_safe &
while ! nc -zv localhost 3306
do
    sleep 1
done

# create db and table
echo "CREATE DATABASE xhprof" | mysql
mysql xhprof < /tmp/schema.sql

# disalbe remote root login
echo "DELETE FROM user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')" | mysql mysql
echo "FLUSH PRIVILEGES" | mysql

# create new user
echo "GRANT ALL ON xhprof.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'" | mysql xhprof
echo "GRANT ALL ON xhprof.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'" | mysql xhprof

mysqladmin shutdown

supervisord -n
