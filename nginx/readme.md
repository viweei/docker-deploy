# Nignx 部署

## 系统介绍

1. frp 内网穿透
2. shadowsocks 翻墙小飞机

## nginx 导出目录

1. `/etc/nginx/conf.d` 本地站点的配置文件,站点的配置文件需要 `.conf` 结尾. 以 `help.viweei.me` 为例,配置文件应为 `help.viweei.me.conf`.

2. `/etc/nginx/ssl` 站点的证书文件,虽然 `conf` 文件可以修改, 但建议以 DOMAIN+.cert 和 DOMAIN+.key 保存.

```sh
ssl_certificate /etc/nginx/ssl/viweei.me.cert;
ssl_certificate_key /etc/nginx/ssl/viweei.me.key;
```

3. `/var/www/${DOMAIN}` 站点的静态目录文件,注意多建一级${DOMAIN} 目录.

具体的可以参考 `./nginx-site.template`.

## 打包

打包依赖于 `.env` 文件中的几个环境变量.

1. DOMAIN: 用于在各服务器使用的域名, 目前 frp, ss 都依赖.
2. PASSWORD: 密码,用于 frp, ss 连接时的鉴权.
3. SS_PORT: shadowsocks 的监听端口，借助 v2ray-plugin 将 ss 伪装到 nginx 中. 不必对外网暴露.
4. FRP_PORT: FRPS 的监听端口, 需要对外暴露,让 FRPC 连接.
5. VHOST_PORT: FRP 网关的监听端口, nginx 收到请求后转发到该端口.
