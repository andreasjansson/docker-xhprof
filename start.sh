#!/bin/bash

envtpl -f /opt/xhprof/xhprof_lib/config.php.tpl || exit 1

if [ -z "$HTTP_AUTH_USER"]
then
    htpasswd -cb /etc/apache2/htpasswd "$HTTP_AUTH_USER" "$HTTP_AUTH_PASS"
    envtpl -f /tmp/vhost_auth.conf.tpl -o /etc/apache2/sites-enabled/xhprof.conf || exit 1
else
    envtpl -f /tmp/vhost.conf.tpl -o /etc/apache2/sites-enabled/xhprof.conf || exit 1
fi

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

killall mysqld_safe

supervisord -n
