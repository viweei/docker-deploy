## 镜像启动

端口
IMAP 默认端口是 143（非加密）
IMAPS（SSL/TLS）默认端口是 993

```sh
docker build -t dovecot:0.0.2 .


docker run -it --rm \
-p 143:143 \
-p 24:24 \
-p 12345:12345 \
-v ~/procject/docker/email/dovecot/env:/etc/dovecot/env \
dovecot:0.0.2 /usr/bin/fish
```
