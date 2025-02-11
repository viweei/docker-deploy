# FRP 内网穿透

目前主要用于微信小程序的内网穿透,配置说明如下:

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

## 客户端使用

```sh
# 安装
wget https://github.com/fatedier/frp/releases/download/v0.61.1/frp_0.61.1_linux_amd64.tar.gz
tar -xvf frp_0.61.1_linux_amd64.tar.gz
sudo cp frp_0.61.1_linux_amd64/frpc /usr/local/bin/frpc
rm -rf frp_0.61.1_linux_amd64 frp_0.61.1_linux_amd64.tar.gz

# 将下面的配置文件对应修改后放到 /etc下即可

# 启动
frpc -c /etc/frp_client.toml
```

```ini
# 转发器主机地址, 可以IP、域名
serverAddr = "viweei.me"
# 转发器主机端口
serverPort = 7000
auth.method = "token"
# 验证TOKEN
auth.token = "dLZmxx^Ksvx4(jWG"

[[proxies]]
name = "http"
# 转发的类型
type = "http"
# 收到请求后转发的 目的地主机地址
localIP = "127.0.0.1"
# 目的地主机端口
localPort = 3000
# 接收的域名
customDomains = ["www.viweei.me"]
# 启用加密
transport.useEncryption = true
# 启用压缩
transport.useCompression = true
```
