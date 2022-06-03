#!/bin/bash

# checkout GIT repo
if [ "_${GIT_ENABLED}_" = "_on_" ]; then
  if [ -d /var/www/html/.git ]; then
    echo "Pull Git Repository"
    cd /var/www/html
    git reset --hard HEAD
    git clean -f
    git pull
  else
    if [ "_${GIT_VERSION}_" = "__" ]; then
      echo "Checkout Git Repository with default branch"
      git clone ${GIT_LOCATION} /var/www/html
    else
      echo "Checkout Git Repository with branch ${GIT_VERSION}"
      git clone --branch ${GIT_VERSION} ${GIT_LOCATION} /var/www/html
    fi
  fi
fi
