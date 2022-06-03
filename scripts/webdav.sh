#!/bin/bash

# enable WebDAV
if [ "_${DAV_ENABLED}_" = "_on_" ]; then
  echo "Enable WebDAV Support"
  a2enmod dav
  a2enmod dav_fs
  if [ "_${DAV_AUTHTYPE}_" = "_basic_" ]; then
    a2enmod auth_basic
    a2enmod authn_file
    cp /etc/apache2/conf-available/dav-${DAV_AUTHTYPE}.conf /etc/apache2/conf-enabled/dav.conf
  elif [ "_${DAV_AUTHTYPE}_" = "_digest_" ]; then
    a2enmod auth_digest
    a2enmod authn_file
    cp /etc/apache2/conf-available/dav-${DAV_AUTHTYPE}.conf /etc/apache2/conf-enabled/dav.conf
  fi

  # DAV_USERS=$(echo '[{"u":"trw","p":"pass"},{"u":"mkas","p":"pass2"}]' | base64)
  # echo $DAV_USERS
  _DAV_USERS=$(echo ${DAV_USERS} | base64 --decode)
  DAV_REALM=dav

  echo "Create DAV user database"
  mkdir -p /var/lib/dav
  rm -f /var/lib/dav/users
  touch /var/lib/dav/users
  chown www-data:www-data /var/lib/dav/users
  chmod 640 /var/lib/dav/users

  for row in $(echo "${_DAV_USERS}" | jq -r '.[] | @base64'); do
    DAV_USER=$(echo ${row} | base64 --decode | jq -r '.u')
    DAV_PASS=$(echo ${row} | base64 --decode | jq -r '.p')
    echo " - $DAV_USER"
    if [ "_${DAV_AUTHTYPE}_" = "_basic_" ]; then
      htpasswd -B /var/lib/dav/users "${DAV_USER}" "${DAV_PASS}"
    elif [ "_${DAV_AUTHTYPE}_" = "_digest_" ]; then
      digest="$( printf "%s:%s:%s" "$DAV_USER" "$DAV_REALM" "$DAV_PASS" | md5sum | awk '{print $1}' )"
      printf "%s:%s:%s\n" "$DAV_USER" "$DAV_REALM" "$digest" >> /var/lib/dav/users
    fi
  done

  echo "Done"
fi