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

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="acoby PHP" \
      org.label-schema.url="https://www.acoby.de/" \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vendor="acoby GmbH" \
      org.label-schema.version=${BUILD_VERSION}

EXPOSE 80

COPY ci/docker-entrypoint.sh /usr/local/bin/

RUN apt-get update --allow-releaseinfo-change && apt-get dist-upgrade -y && \
    apt-get install -y \
      git \
      curl \
      libxml2-dev \
      libpng-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libicu-dev \
      libssl-dev \
      libcurl4 \
      libcurl4-openssl-dev \
      zip \
      unzip \
      tnef \
      ssl-cert \
      libldap2-dev \
      catdoc \
      tar \
      pngquant \
      imagemagick \
      tesseract-ocr \
      tesseract-ocr-eng \
      poppler-utils \
      exiv2 \
      libzip-dev \
      mariadb-client \
      msmtp \
      msmtp-mta \
      memcached \
      libmemcached-tools \
      libmemcached-dev \
      libzip-dev \
      zlibc \
      zlib1g-dev \
      zlib1g && \
    docker-php-ext-configure zip --with-libzip && \
    docker-php-ext-install zip && \
    pecl install memcached && \
    docker-php-ext-configure memcached && \
    docker-php-ext-install memcached && \
    docker-php-ext-enable memcached && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure ldap && \
    docker-php-ext-install soap pdo pdo_mysql calendar gd sysvshm sysvsem sysvmsg ldap opcache intl pcntl zip bcmath && \
    yes "" | pecl install memcached && \
    echo "extension=memcached.so" > $PHP_INI_DIR/conf.d/docker-php-ext-memcached.ini && \
    pecl install apcu && \
    docker-php-ext-enable apcu && \
    apt purge -y binutils binutils-common cpp dpkg-dev g++ gcc icu-devtools \
        libasan5 libatomic1 libbinutils libcc1-0 libfreetype6-dev libicu-dev \
        libitm1 libjpeg62-turbo-dev libldap2-dev liblsan0 libmpc3 libmpfr6 libpng-dev \
        libpng-tools libquadmath0  libtsan0 libubsan1 libxml2-dev patch --autoremove || true && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/locale/* && \
    rm -rf /usr/share/man/* && \
    rm -rf /usr/share/doc/* && \
    touch /etc/apache2/conf-available/phpmyadmin-on.conf && \
    case ${TARGETARCH} in arm64) ARCH="aarch64" ;; amd64) ARCH="x86-64";; esac && \
    curl -L -o /tmp/ioncube_loader.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${ARCH}.tar.gz && \
    tar xvzfC /tmp/ioncube_loader.tar.gz /tmp/ && \
    rm /tmp/ioncube_loader.tar.gz && \
    mkdir -p /usr/local/ioncube && \
    cp /tmp/ioncube/ioncube_loader_* /usr/local/ioncube && \
    rm -rf /tmp/ioncube && \
    echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.4.so" >> /usr/local/etc/php/conf.d/00_ioncube.ini && \
    a2enmod rewrite && \
    a2enmod headers && \
    echo 'expose_php = off' > /usr/local/etc/php/conf.d/security.ini && \
    mkdir /etc/msmtp.tpl

COPY ./ci/etc/php.ini /usr/local/etc/php/
COPY ./ci/etc/apache.conf /etc/apache2/conf-enabled/x-security.conf

COPY ./ci/msmtp/msmtprc /etc/msmtp.tpl/msmtprc
COPY ./ci/msmtp/aliases /etc/msmtp.tpl/aliases
COPY ./ci/msmtp/mail.ini /etc/msmtp.tpl/mail.ini


WORKDIR /var/www/html
ENTRYPOINT ["/usr/local/bin/docker-go-entrypoint.sh"]
HEALTHCHECK --interval=60s --timeout=5s --start-period=60s CMD curl --fail http://localhost/ || exit 1  
