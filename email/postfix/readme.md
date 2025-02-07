# postfix

postfix 是 SMTP 服务器, dovecot 是邮箱服务器, 其工作流程是：

1. 外部 STMP 服务器先把邮件投递到本地的 SMTP 服务器(postfix).
2. postfix 根据 virtual_mailbox_domains 判断域名是否是本地邮件.
3. 如果是本地邮件则保存邮件,外部邮件则投递给外部的 STMP 服务器
   3.1 如果配置了 dovecot 则使用 ltmp 协议转给 dovecot 去保存.
   3.2 如果没有则配置保存到本地文件中.

postfix 只会验证是否存在该用户,以及如何保存。当 STMP 需要验证密码时,则需要通过 SASL 或 dovecot 去验证密码.

## 安装

```sh
# debian
apt install postfix postfix-mysql

# apline
apk add postfix postfix-mysql
```

## 数据库支持

```sql
-- 创建数据库
CREATE DATABASE mailserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON mailserver.* TO 'mailuser'@'localhost';
FLUSH PRIVILEGES;

USE mailserver;

CREATE TABLE domains (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    domain_id INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE KEY,
    password VARCHAR(150) NOT NULL,
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
);

CREATE TABLE aliases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    domain_id INT NOT NULL,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
);
```

但配置完后我发现 postfix 只向 dovecot 发送用户名验证, 但 dovecot 接受 pop3 imap 访问时，接收到的又是完成的邮件名。虽然在 dovecot 的 `/etc/dovecot/conf.d/10-auth.conf` 文件中可以设置 `auth_default_realm = domain` 用于补全 email 地址。

## 数据库验证

直接通过数据库直接校验用户名与密码. 这里有一个天坑(卧槽~坑了我整整两天)~数据库验证也有两种方式,一种是 使用 [sql auxprop plugin](https://www.postfix.org/SASL_README.html#auxprop_sql) ,另一种是使用 `pam_mysql`.

`sql auxprop plugin` 不需要启动 `saslauthd` 服务, 把配置扔到 `/etc/postfix/sasl/smtpd.conf`,但是 `sql auxprop plugin` 只能处理明文密码，不能使用加密密码,在官网中有提到

> If you must store encrypted passwords, you cannot use the sql auxprop plugin. Instead, see section "Using saslauthd with PAM", and configure PAM to look up the encrypted passwords with, for example, the pam_mysql module. You will not be able to use any of the methods that require access to plaintext passwords, such as the shared-secret methods CRAM-MD5 and DIGEST-MD5.

所以要使用加密的密码验证应该使用 `pam_mysql`。但是后来发现 `pam_mysql`的密码保存格式与 `dovecot` 不相同,两者要统一还需要改进。

**sql auxprop plugin** 的配置文件

```ini
# /etc/postfix/sasl/smtpd.conf

pwcheck_method: auxprop
auxprop_plugin: sql
mech_list: PLAIN LOGIN
sql_engine: mysql
sql_hostnames: viweei.me:4407
sql_user: root
sql_passwd: 123456
sql_database: mailserver
sql_select: SELECT password FROM virtual_users WHERE email = '%u@%r'
# %u 是用户名, %r 是域名
```

## 配置项说明

### Submission 服务

Submission 服务（端口 587）是专门用于邮件客户端提交邮件的服务，它与标准 SMTP（端口 25）有以下主要区别：

1. 专门用于邮件客户端（如 Outlook、Thunderbird 等）发送邮件
2. 而端口 25 主要用于邮件服务器之间的通信

所以 Submission 通常要求强制 TLS 加密,必须进行身份验证（SASL 认证）,更安全，避免垃圾邮件.

Submission 的配置项在 `master.cf` 中.

```sh
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt         # 强制TLS加密
  -o smtpd_sasl_auth_enable=yes               # 启用SASL认证
  -o smtpd_tls_auth_only=yes                  # 只允许TLS连接
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject  # 只允许认证用户
```

`smtpd_sasl_auth_enable` 启用后发送邮件则需要密码认证.至于怎么认证则取自`main.cf`里的配置.

## 参考文档

[Dovecot 密码格式](https://doc.dovecotpro.com/3.0.0/core/config/auth/schemes.html)
[SASL 使用数据库验证 ](https://www.postfix.org/SASL_README.html#auxprop_sql)

### 检查排错

```sh
# postfix 检查配置是否有错误, 需要使用 root 权限
postfix check

# 查看 postfix 支持那些验证
postconf -a

# 查看 postfix 参数
postconf -n

# 设置 postfix 参数
postconf -e virtual_transport=lmtp:127.0.0.1:24



# 查看 SASL 支持的验证模式
saslauthd -v

# 验证Cyrus SASL 安装的插件
saslpluginviewer -a

# 检查 sasl 账号
testsaslauthd -u [username] -p [password]
# testsaslauthd -u viweei@viweei.me -p linuxwindows
# 如果报权限不够，需要加入 sasl用户组.

# 检查postfix数据库是否连通
postmap -q 'testi@viweei.me' mysql:/etc/postfix/sql/mailbox.cf
```

### 问题集

> connect to mysql server viweei.me:4407: Plugin caching_sha2_password could not be loaded

mysql8 之前的版本中加密规则是 mysql_native_password,而 mysql8 之后,加密规则是 caching_sha2_password

```sh
#
ALTER USER 'username' IDENTIFIED WITH mysql_native_password BY 'password';
```

## docker 部署

```sh
# 编译
docker build -t postfix:0.0.1 .

# 启动
docker run -it --rm \
-v ~/procject/docker/email/postfix/sql:/etc/postfix/sql \
-p 25:25 \
-p 587:587 \
postfix:0.0.1 /usr/bin/fish


```

# 操~关于 STMP 无法解析 DNS 的问题

/var/spool/postfix/etc/
