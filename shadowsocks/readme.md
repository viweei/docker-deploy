# rust-shadowsocks docker 部署

这个部署用到了 `v2ray-plugin` 和 `nginx` 分流.需要先编译后再运行。

## 编译

编译依赖 `DOMAIN` , `PORT` 和 `PASSWORD`变量.

1. 变更可以写在`.env`文件中,使用 build.sh 脚本打包.该方法会随机生成 PASSWORD。
2. 手动部打包

```sh
# 脚本打包
./build.sh

# 手动打包
docker build -t shadowsocks \
--build-arg DOMAIN=${DOMAIN} \
--build-arg PORT=${PORT} \
--build-arg PASSWORD=${PASSWORD} .
```

## 启动

```sh

docker run -d --rm \
  --name shadowsocks \
  --network vmail-net \
  -p 8388:8388 \
  shadowsocks:latest

```

或者使用 `docker compose`

```yml
# name: shadowsocks

networks:
  virtual-net:
    name: virtual-net

services:
  shadowsocks:
    image: shadowsocks:latest
    restart: on-failure
    hostname: shadowsocks
    container_name: shadowsocks
    networks:
      - virtual-net

  nginx:
    image: nginx:stable-alpine3.20
    restart: always
    container_name: nginx
    volumes:
      - ${conf.d}:/etc/nginx/conf.d
      - ${ssl}:/etc/nginx/ssl
      - ${www}:/var/www/${DOMAIN}
    ports:
      - 80:80
      - 443:443
    networks:
      - virtual-net
```
