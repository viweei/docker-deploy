#! /bin/sh

ENV_FILE=.env
SCRIPT_PATH=$(dirname $0)

while IFS='=' read -r key value; do
  # 跳过注释行和空行
  [ -z "$key" ] || [ "${key#\#}" != "$key" ] && continue

  export "$key=$value"
done < "$ENV_FILE"

# 生成随机密码
length=16
characters="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_\-+=<>?"
PASSWORD=$(head /dev/urandom | tr -dc "$characters" | head -c"$length")

docker build -t shadowsocks \
--build-arg DOMAIN=${DOMAIN} \
--build-arg PORT=${PORT} \
--build-arg PASSWORD=${PASSWORD} .

while IFS='=' read -r key value; do
  # 跳过注释行和空行
  [ -z "$key" ] || [ "${key#\#}" != "$key" ] && continue

  unset $key
done < "$ENV_FILE"


