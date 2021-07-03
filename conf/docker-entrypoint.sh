#!/bin/sh

# To disable warning libdc1394 error: Failed to initialize libdc1394

envtpl /usr/src/app/thumbor.conf.tpl  --allow-missing --keep-template
envtpl /etc/nginx/nginx.conf.tpl  --allow-missing


nginx & /usr/src/app/thumbor-entrypoint.sh thumbor
