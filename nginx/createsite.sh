#! /bin/sh

ENV_FILE=.env
SCRIPT_PATH=$(dirname $0)

while IFS='=' read -r key value; do
  # 跳过注释行和空行
  [ -z "$key" ] || [ "${key#\#}" != "$key" ] && continue

  export "$key=$value"
done < "$ENV_FILE"

envsubst  '${DOMAIN} ${PORT} ${SERVICE}' < ${SCRIPT_PATH}/nginx-site.template

while IFS='=' read -r key value; do
  # 跳过注释行和空行
  [ -z "$key" ] || [ "${key#\#}" != "$key" ] && continue

  unset $key
done < "$ENV_FILE"


# !!! don't forget !!!
# 1. mapping directory /var/www/${DOMAIN} 
# 2. mapping directory /etc/nginx/sites-enabled
# 3. mapping directory /etc/nginx/ssl
