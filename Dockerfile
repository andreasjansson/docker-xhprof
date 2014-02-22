FROM    ubuntu:precise
MAINTAINER Andreas Jansson andreas@jansson.me.uk

RUN     echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN     apt-get update
RUN     apt-get -y install \
            apache2 \
            php5 \
            php5-mysql \
            php5-dev \
            mysql-server \
            curl \
            graphviz \
            supervisor \
            openssh-server \
            build-essential \
            python-pip

# download and build the extension
RUN     curl -L https://github.com/preinheimer/xhprof/tarball/3bbf52e | tar xz && \
            mv preinheimer-xhprof-3bbf52e /opt/xhprof && \
            cd /opt/xhprof/extension && \
            phpize && \
            ./configure --with-php-config=/usr/bin/php-config && \
            make && \
            make install

# add some confs
ADD     config.php.tpl /opt/xhprof/xhprof_lib/
ADD     vhost.conf /tmp/
ADD     vhost_auth.conf /tmp/
RUN     rm /etc/apache2/sites-enabled/000-default

ADD     my.cnf /etc/mysql/my.cnf
ADD     schema.sql /tmp/

# setup sshd with root:root
RUN	mkdir /var/run/sshd
RUN     echo 'root:root' | chpasswd

ADD     supervisord.conf /etc/

RUN     pip install envtpl==0.2.0

ADD     start.sh /bin/
RUN     chmod +x /bin/start.sh

EXPOSE  22
EXPOSE  80
EXPOSE  3306

CMD     /bin/start.sh
