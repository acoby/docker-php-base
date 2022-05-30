#!/bin/sh
set -e

if [ "_${MAIL_ENABLED}_" = "_on_" ]; then
  cp /etc/msmtp.tpl/msmtprc /etc/msmtprc
  cp /etc/msmtp.tpl/aliases /etc/aliases
  cp /etc/msmtp.tpl/mail.ini /usr/local/etc/php/conf.d/mail.ini

  chmod 644 /etc/msmtprc
  
  sed -i 's/{MAIL_HOST}/'${MAIL_HOST}'/' /etc/msmtprc
  sed -i 's/{MAIL_PORT}/'${MAIL_PORT}'/' /etc/msmtprc
  sed -i 's/{MAIL_USERNAME}/'${MAIL_USERNAME}'/' /etc/msmtprc
  sed -i 's/{MAIL_PASSWORD}/'${MAIL_PASSWORD}'/' /etc/msmtprc
  sed -i 's/{MAIL_ADDRESS}/'${MAIL_ADDRESS}'/' /etc/msmtprc

  sed -i 's/{MAIL_ADDRESS}/'${MAIL_ADDRESS}'/' /etc/aliases
fi

#call original entry point
echo "Start PHP Service"
docker-php-entrypoint "$@"
