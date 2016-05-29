FROM        ubuntu:16.04
MAINTAINER  Ivan N. Ivanov "inivanoff1@gmail.com"

#
# Setting up the environment...
#

ENV HOME /root

RUN locale-gen en_GB.UTF-8 && \
    echo 'LANG="en_GB.UTF-8"' > /etc/default/locale
# RUN dpkg-reconfigure locales

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config
RUN echo "    LogLevel ERROR" >> /etc/ssh/ssh_config

#
# Installing nginx...
#

RUN apt-get update
RUN apt-get -y install nginx

ADD ./nginx.conf /etc/nginx/nginx.conf
# ADD ./our-custom-sites-enabled/ /etc/nginx/sites-enabled/
# ADD ./our-custom-html/ /var/www/html/

#
# Installing Apache...
#

RUN apt-get update
RUN apt-get -y install apache2

ADD ./apache2.conf /etc/apache2/apache2.conf
# ADD ./our-custom-sites-enabled/ /etc/apache2/sites-enabled/
# ADD ./our-custom-html/ /var/www/html/

#
# Installing PostgreSQL...
#

VOLUME ["/var/lib/postgresql/9.5/main"]
RUN apt-get update
RUN apt-get -y install postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5

ADD ./postgresql.conf /etc/postgresql/9.5/main/postgresql.conf
ADD .pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf

RUN /etc/init.d/postgresql start

#
# Installing libraries necessary for our application...
#

# RUN apt-get update
# RUN apt-get -y install <packages>

#
# Installing supervisord...
#



#
# Opening ports...
#

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-n"]

