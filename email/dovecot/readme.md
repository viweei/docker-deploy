## 端口说明

143: IMAP 非加密
993: IMAPS（SSL/TLS）
24: LMTP 本地邮件传输
12345: RIMAP 用户验证

## 命令

```sh
# 检查配置
dovecot -n

# 生成密码, 需要注意 auth.conf.ext 里加密方式
doveadm pw -s SSHA256

# dovecot 检查用户名与密码是否正确
doveadm auth test [username]

# 启动
dovecot -F
```

## 镜像启动

```sh
docker build -t dovecot:0.0.1 .

docker run -it --rm \
-p 143:143 \
-p 993:993 \
-p 24:24 \
-p 12345:12345 \
-v ~/procject/docker/email/dovecot/sql:/etc/dovecot/sql \
dovecot:0.0.1 /usr/bin/fish
```
