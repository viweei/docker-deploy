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