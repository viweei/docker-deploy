# Nignx docker 部署

docker 采用官方发布版本, 只需要映射 3 个目录即可.

1. `/etc/nginx/conf.d` 本地站点的配置文件,站点的配置文件需要 `.conf` 结尾. 以 `help.viweei.me` 为例,配置文件应为 `help.viweei.me.conf`.

2. `/etc/nginx/ssl` 站点的证书文件,虽然 `conf` 文件可以修改, 但建议以 DOMAIN+.cert 和 DOMAIN+.key 保存.

```sh
ssl_certificate /etc/nginx/ssl/viweei.me.cert;
ssl_certificate_key /etc/nginx/ssl/viweei.me.key;
```

3. `/var/www/${DOMAIN}` 站点的静态目录文件,注意多建一级${DOMAIN} 目录.

具体的可以参考 `./nginx-site.template`.

## docker-compose.yml

包含了本项目中,需要通过 nginx 转发服务。
