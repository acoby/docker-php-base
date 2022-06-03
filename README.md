# docker-php-base

A base PHP Image with Ioncube, MemCache, PDO, MySQL, LDAP and GD Support. 
Also we provide a basic MSMTP support to use default PHP mail functions to not use localhost SMTP server.

    MAIL_ENABLED - default: off - enable MSMTP support
    MAIL_HOST - default localhost.localdomain - the external mail server host
    MAIL_PORT - default 25 - the external mail server port
    MAIL_USERNAME - default nobody - the user to use to authenticate on external mail server
    MAIL_PASSWORD - default none - the password to use to authenticate on external mail server
    MAIL_ADDRESS - default nobody@localhost - the mail from address to use

If `MAIL_ENABLED` is turned `on`, then PHP is configured to use the external mail server. Then we always enable SMTP authentication with TLS support via msmtp.

Also the image provides a GIT support, which means at initializing time the container checks out a git repository (or pulls the newest changes)

    GIT_ENABLED - default: off - enable git support
    GIT_LOCATION - default: https://user:pass@host/repo.git - the location of the git repository.
    GIT_VERSION - default: master - the branch which should be checked out

If you set `GET_ENABED=on`, then the docker entrypoint tries to clone the given GIT repository.

The image contains also a WebDAV support to allow manually changing the docroot files.

    DAV_ENABLED - default: off - enable the WebDAV support
    DAV_USERS - default: W10K - a base64 encoded JSON string containing an array of users+passwords like [{"u":"username","p":"password"}], the default is an empty list
    DAV_AUTHTYPE - default: basic

When the DAV support is enabled with `DAV_ENABLED=on` then under the alias path http://hostname/dav you'll have access to the docroot via WebDAV. We support `basic` and `digest` authentication.

The image can also receive some other environment vars

    DB_TYPE
    DB_HOST
    DB_PORT
    DB_NAME
    DB_USER
    DB_PASS

The default docroot is still `/var/www/html`. The image is based on php:apache

## Changelog

- more log output at entrypoint
- added GIT support
- added DAV support
- do not override php.ini after php extensions configuration
- added mail support
- added security report
- initial version with PHP7.4 and Ioncube
