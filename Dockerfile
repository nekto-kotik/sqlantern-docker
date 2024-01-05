# Inspired by `https://github.com/alfg/docker-php-apache`
# Thank you, Alfred Gutierrez, it's such a small image based on your Dockerfile!
FROM alpine:latest

# `apk` is the package manager in Alpine Linux

# PHP, PHP modules, git
RUN apk --update add --no-cache php-apache2 php-json php-mbstring php-mysqli php-openssl php-pgsql php-session git

# configs:
# /etc/apache2/httpd.conf
# /etc/php82/php.ini
# but PHP changes from version to version and thus can't be easily used

# listen at port 1111, DON'T listen at 80
# this is an overkill and user would override it at runtime anyways, it's more of enforcing caution and not occupying a popular port accidentally
RUN sed -i 's/Listen 80/Listen 1111/' /etc/apache2/httpd.conf
# AllowOverride is required to set PHP options in `.htaccess` (and setting them there is better so they persist through PHP version change)
RUN sed -i 's/AllowOverride None/AllowOverride All/gi' /etc/apache2/httpd.conf

# respond to "localhost" and an alternative "sqlantern.local" (which must be added to host)
# and, of course, it'll also work if requrested by IP, naturally
RUN echo -e "<VirtualHost *:1111>\nServerName localhost\nServerAlias sqlantern.local\nDocumentRoot /var/www/localhost/htdocs\n</VirtualHost>\n" >> /etc/apache2/httpd.conf

# some PHP options are set to pretty high values below, but again: this docker MUST NOT be run on publicly exposed machines, it is intended for dev only
RUN cd /var/www/localhost/htdocs \
        && rm -rf index.html \
        && git clone https://github.com/nekto-kotik/sqlantern.git . \
        && echo -e "<?php\ndefine(\"SQL_MULTIHOST\", true);\n" > php/config.sys.php \
        && echo -e "php_value memory_limit 256M\nphp_value post_max_size 256M\nphp_value upload_max_filesize 256M\nphp_value max_execution_time 120\nphp_value gc_maxlifetime 86400\nphp_value max_input_time 300\n" > php/.htaccess

# Apache must be run directly, not as a service (as far as I could understand; I'm very new to Docker)
RUN echo -e '#!'"/bin/sh\n\ncd /var/www/localhost/htdocs\ngit pull\n\nln -sf /dev/stderr /var/log/apache2/error.log\n\nmkdir -p /run/apache2 && /usr/sbin/httpd -D FOREGROUND\n\nexit \"\$@\"" > /opt/entrypoint.sh

EXPOSE 1111

# consider running `chmod` instead, to allow running the script manually in `-it` mode for debug
ENTRYPOINT ["sh", "/opt/entrypoint.sh"]
