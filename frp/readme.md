# FRP 内网穿透

目前主要用于微信小程序的内网穿透.

主要配置如下:

```ini
# 相当于客户端要连接的端口, 这个端口需要暴露出来给客户端使用
bindPort = 7000
# 虚拟主机的端口,这个是nginx 转发来端口
vhostHTTPPort = 8080
# 采用token验证方式
auth.method = "token"
# 需要客户端与服务端一致
auth.token = "123456"
```

## 打包

```sh
# 这里提前暴露端口是为了在docker中导出
docker build -t frps --build-arg PORT=7000 .
```

## 启动

1. 手工启动

```sh
# 启动时需要增加两个参数, VHOST_PORT, TOKEN,
# VHOST_PORT: 接受nginx转发的端口
# TOKEN: 验证的token

docker run --rm --name frps \
-e VHOST_PORT=8080 \
-e TOKEN=123456 \
-p 7000:7000 \
frps:latest
```

2. docker compose

```yml
需要注意 网络名称: shared-net,
service:
  frps:
    image: frps:latest
    restart: on-failure
    hostname: frps
    container_name: frps
    networks:
      - shared-net
```

## nginx 转发

```conf

  location ~/ {
      proxy_redirect off;
      proxy_pass http://frps:${VHOST_PORT};
      proxy_set_header Host $http_host;
      proxy_set_header cookie $http_cookie;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

```
