#!/bin/sh

# To disable warning libdc1394 error: Failed to initialize libdc1394
ln -s /dev/null /dev/raw1394

envtpl /usr/src/app/thumbor.conf.tpl  --allow-missing --keep-template
envtpl /etc/nginx/nginx.conf.tpl  --allow-missing


exec /etc/init.d/supervisor start