#!/bin/bash

set -e

# render config templates
envtpl -f /opt/xhprof/xhprof_lib/config.php.tpl
envtpl /etc/apache2/sites-enabled/xhprof.conf.tpl

if [ "$HTTP_AUTH_USER"]
    htpasswd -cb /etc/apache2/htpasswd "$HTTP_AUTH_USER" "$HTTP_AUTH_PASS"
fi

set -eu

# start mysql in the background while we create user accounts
mysqld_safe &
while ! nc -zv localhost 3306
do
    sleep 1
done

# create db and table
echo "CREATE DATABASE xhprof" | mysql -uroot
mysql -uroot xhprof < /tmp/schema.sql

# disalbe remote root login
echo "DELETE FROM user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')" | mysql -uroot mysql
echo "FLUSH PRIVILEGES" | mysql -uroot

# create new user
echo "GRANT ALL ON xhprof.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'" | mysql -uroot xhprof
echo "GRANT ALL ON xhprof.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'" | mysql -uroot xhprof

mysqladmin -uroot shutdown

supervisord -n
