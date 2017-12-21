FROM alpine:edge
MAINTAINER Chinaxiang

# 环境变量
ENV DATA_DIR /srv/data
ENV MYSQL_AUTOCONF=true \
    MYSQL_HOST="localhost" \
    MYSQL_PORT="3306" \
    MYSQL_USER="root" \
    MYSQL_PWD="root3306" \
    MYSQL_DB="pdns" \
    MYSQL_ADMIN_DB="pdns_admin"

# Custom API Key for PowerDNS.
# Leave empty to autogenerate one ( HIGHLY SUGGESTED! )
ENV API_KEY ""

# Create Volume entry points
VOLUME $DATA_DIR

# Copy required files
COPY src/* /root/

# Create missing directories
RUN mkdir -p $DATA_DIR

# Set the work directory
WORKDIR /root

# Fix permissions
RUN chmod 0644 * \
    && chmod 0755 *.sh

# Install required packages
##############################
RUN apk --update add --no-cache \
    bash \
    supervisor \
    pdns \
    pdns-doc \
    pdns-backend-mysql \
    mysql-client \
    mariadb-dev \
    curl \
    dbus \
    libldap

# Required by PowerDNS Admin
RUN apk --update add --no-cache --virtual .build-deps \
    git \
    gcc \
    musl-dev \
    python \
    python-dev \
    py-pip \
    libffi-dev \
    openldap-dev

# Install PowerDNS Admin
##############################
RUN mkdir -p /usr/share/webapps/ \
    && cd /usr/share/webapps/ \
    && git clone https://github.com/Chinaxiang/PowerDNS-Admin.git powerdns-admin \
    && cd /usr/share/webapps/powerdns-admin \
    && pip install MySQL-python \
    && pip install --no-cache-dir -r requirements.txt

# Cleanup
#########
RUN find /usr/local \
      \( -type d -a -name test -o -name tests \) \
      -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
      -exec rm -rf '{}' + \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Replace default configurations
################################
RUN rm /etc/pdns/pdns.conf \
    && rm /etc/supervisord.conf \
    && mv /root/pdns.conf /etc/pdns \
    && mv /root/config.py /usr/share/webapps/powerdns-admin \
    && mv /root/supervisord.conf /etc

# Allow redirection of stdout to docker logs
############################################
RUN ln -sf /proc/1/fd/1 /var/log/docker.log

# Expose required ports
#######################
EXPOSE 53
EXPOSE 53/udp
EXPOSE 8080
EXPOSE 8081

# Change Shell
##############
SHELL ["/bin/bash", "-c"]

# Set the entry point to init.sh
###########################################
ENTRYPOINT /root/init.sh
