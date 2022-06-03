FROM php:7.4-apache
LABEL maintainer="Thoralf Rickert-Wendt <trw@acoby.de>"

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_BRANCH

ENV MAIL_ENABLED off
ENV MAIL_HOST localhost.localdomain
ENV MAIL_PORT 25
ENV MAIL_USERNAME nobody
ENV MAIL_PASSWORD none
ENV MAIL_ADDRESS nobody@localhost

ENV GIT_ENABLED off
ENV GIT_LOCATION https://user:pass@host/repo.git
ENV GIT_VERSION master

ENV DAV_ENABLED off
ENV DAV_USERS W10K
ENV DAV_AUTHTYPE basic

ENV DB_TYPE mysql
ENV DB_HOST database
ENV DB_PORT 3306
ENV DB_NAME database
ENV DB_USER username
ENV DB_PASS password

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="acoby PHP" \
      org.label-schema.url="https://www.acoby.de/" \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vendor="acoby GmbH" \
      org.label-schema.version=${BUILD_VERSION}

EXPOSE 80

COPY docker-entrypoint.sh /usr/local/bin/
COPY scripts /usr/local/bin/docker-hook-scripts.d

COPY etc/php.ini /usr/local/etc/php/php.ini
COPY etc/apache2/conf-enabled/x-security.conf /etc/apache2/conf-enabled/x-security.conf
COPY etc/apache2/conf-available/dav-basic.conf /etc/apache2/conf-available/dav-basic.conf
COPY etc/apache2/conf-available/dav-digest.conf /etc/apache2/conf-available/dav-digest.conf

COPY etc/msmtp/msmtprc /etc/msmtp.tpl/msmtprc
COPY etc/msmtp/aliases /etc/msmtp.tpl/aliases
COPY etc/msmtp/mail.ini /etc/msmtp.tpl/mail.ini

RUN apt-get update --allow-releaseinfo-change && apt-get dist-upgrade -y && \
    apt-get install -y \
      catdoc \
      curl \
      exiv2 \
      git \
      imagemagick \
      jq \
      libcap2-bin \
      libcurl4 \
      libcurl4-openssl-dev \
      libfreetype6-dev \
      libicu-dev \
      libjpeg62-turbo-dev \
      libldap2-dev \
      libmcrypt-dev \
      libmemcached-dev \
      libpng-dev \
      libssl-dev \
      libxml2-dev \
      libzip-dev \
      mariadb-client \
      msmtp \
      msmtp-mta \
      pngquant \
      poppler-utils \
      ssl-cert \
      tar \
      tesseract-ocr \
      tesseract-ocr-eng \
      tnef \
      unzip \
      zip \
      zlib1g-dev \
      zlib1g

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure ldap

RUN docker-php-ext-install soap pdo pdo_mysql calendar gd sysvshm sysvsem sysvmsg ldap opcache intl pcntl zip bcmath 

RUN yes "" | pecl install memcached && \
    echo "extension=memcached.so" > /usr/local/etc/php/conf.d/docker-php-ext-memcached.ini

RUN pecl install apcu && \
    docker-php-ext-enable apcu

RUN case ${TARGETARCH} in arm64) ARCH="aarch64" ;; amd64) ARCH="x86-64";; esac && \
    curl -L -o /tmp/ioncube_loader.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${ARCH}.tar.gz && \
    tar xvzfC /tmp/ioncube_loader.tar.gz /tmp/ && \
    rm /tmp/ioncube_loader.tar.gz && \
    mkdir -p /usr/local/ioncube && \
    cp /tmp/ioncube/ioncube_loader_* /usr/local/ioncube && \
    rm -rf /tmp/ioncube && \
    echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.4.so" >> /usr/local/etc/php/conf.d/00_ioncube.ini

RUN apt-get purge -y \
      binutils \
      binutils-common \
      cpp \
      dpkg-dev \
      g++ \
      gcc \
      icu-devtools \
      libasan5 \
      libatomic1 \
      libbinutils \
      libcc1-0 \
      libfreetype6-dev \
      libicu-dev \
      libitm1 \
      libjpeg62-turbo-dev \
      libldap2-dev \
      liblsan0 \
      libmpc3 \
      libmpfr6 \
      libpng-dev \
      libpng-tools \
      libquadmath0 \
      libtsan0 \
      libubsan1 \
      libxml2-dev \
      patch --autoremove || true && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/locale/* && \
    rm -rf /usr/share/man/* && \
    rm -rf /usr/share/doc/* && \
    touch /etc/apache2/conf-available/phpmyadmin-on.conf && \
    a2enmod rewrite && \
    a2enmod headers && \
    echo 'expose_php = off' > /usr/local/etc/php/conf.d/x-security.ini && \
    mkdir -p /var/lib/dav && \
    chown www-data:www-data /var/lib/dav && \
    ls -al /usr/local/bin/docker-hook-scripts.d/ && \
    chmod 755 /usr/local/bin/docker-hook-scripts.d/*.sh && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh

# rootless support (currently disabled)
# RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2
# USER www-data

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
HEALTHCHECK --interval=60s --timeout=5s --start-period=60s CMD curl --fail http://localhost/ || exit 1  
