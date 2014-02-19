FROM    ubuntu:precise

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

# add some template confs
ADD     config.php.tpl /opt/xhprof/xhprof_lib/
ADD     vhost.conf.tpl /tmp/
ADD     vhost_auth.conf.tpl /tmp/
RUN     rm /etc/apache2/sites-enabled/000-default

ADD     schema.sql /tmp/

# setup sshd with root:root
RUN	mkdir /var/run/sshd
RUN     echo 'root:root' | chpasswd

ADD     supervisord.conf /etc/

RUN     pip install envtpl

ADD     start.sh /opt/

EXPOSE  3306
EXPOSE  22
EXPOSE  80

CMD     source /opt/start.sh
