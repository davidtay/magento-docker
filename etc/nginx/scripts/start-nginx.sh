#! /bin/sh

# Copy and replace env vars
cat /etc/nginx/conf.d/default.template | sed "s/PHP_CONTAINER/${PHP_CONTAINER}/" | sed "s/VIRTUAL_HOST/${VIRTUAL_HOST}/" > /etc/nginx/conf.d/default.conf

nginx -g 'daemon off;'
