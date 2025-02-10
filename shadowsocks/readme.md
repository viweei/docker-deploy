## 编译

```sh
# 编译需要导出2个变量,需要在 .env中修改后使用build.sh脚本创建

# 也可以手动指定
docker build -t shadowsocks \
--build-arg DOMAIN=${DOMAIN} \
--build-arg PORT=${PORT} \
--build-arg PASSWORD=${PASSWORD} .

```

## 启动

```sh

docker run -d --rm \
  --name shadowsocks \
  -p 8388:$(cat .env |grep PORT | awk -F '=' '{print $2}') \
  shadowsocks

docker run -d \
  --name shadowsocks \
  --network vmail-net \
  -p 8499:$(cat .env |grep PORT | awk -F '=' '{print $2}') \
  shadowsocks

```

或者可以使用 `docker compose`

```yaml
name: shadowsocks

networks:
  virtual-net:

services:
  shadowsocks:
    build:
      context: ./
      dockerfile: dockerfile
    restart: on-failure
    hostname: shadowsocks
    container_name: shadowsocks
    networks:
      - vmail-net

  nginx:
    image: nginx:stable-alpine3.20
    restart: always
    container_name: nginx
    volumes:
      - ${sites-enabled}:/etc/nginx/sites-enabled
      - ${ssl}:/etc/nginx/ssl
    ports:
      - 80:80
      - 443:443
    networks:
      - virtual-net
```
