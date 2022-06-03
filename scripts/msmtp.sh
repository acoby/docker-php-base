#!/bin/bash

# enable MSMTP
if [ "_${MAIL_ENABLED}_" = "_on_" ]; then
  echo "Enable MSMTP Support"
  
  cp /etc/msmtp.tpl/msmtprc /etc/msmtprc
  cp /etc/msmtp.tpl/aliases /etc/aliases
  cp /etc/msmtp.tpl/mail.ini /usr/local/etc/php/conf.d/mail.ini

  chmod 644 /etc/msmtprc
  
  echo "Set Mail Host: ${MAIL_HOST}"
  sed -i 's/{MAIL_HOST}/'${MAIL_HOST}'/' /etc/msmtprc

  echo "Set Mail Port: ${MAIL_PORT}"
  sed -i 's/{MAIL_PORT}/'${MAIL_PORT}'/' /etc/msmtprc

  echo "Set Mail Username: ${MAIL_USERNAME}"
  sed -i 's/{MAIL_USERNAME}/'${MAIL_USERNAME}'/' /etc/msmtprc
  sed -i 's/{MAIL_PASSWORD}/'${MAIL_PASSWORD}'/' /etc/msmtprc

  echo "Set Mail Address: ${MAIL_ADDRESS}"
  sed -i 's/{MAIL_ADDRESS}/'${MAIL_ADDRESS}'/' /etc/msmtprc
  sed -i 's/{MAIL_ADDRESS}/'${MAIL_ADDRESS}'/' /etc/aliases
fi
