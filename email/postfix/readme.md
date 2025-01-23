# 记录

## debian 安装部署

### 部署 postfix

1. 安装依赖

```sh
sudo apt install postfix postfix-mysql
```

2. 创建数据结构并设计文件权限

```sql
-- 创建数据库
CREATE DATABASE mailserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 创建用户
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON mailserver.* TO 'mailuser'@'localhost';

FLUSH PRIVILEGES;

--
USE mailserver;

CREATE TABLE virtual_domains (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE virtual_users (
    id INT NOT NULL AUTO_INCREMENT,
    domain_id INT NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(150) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY email (email),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
);

CREATE TABLE virtual_aliases (
    id INT NOT NULL AUTO_INCREMENT,
    domain_id INT NOT NULL,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
);

```

```sh
sudo chown root:root /etc/postfix/mysql-virtual-*.cf
# 所有人都可读
sudo chmod 644 /etc/postfix/mysql-virtual-*.cf
```

2. 相关配置

```sh

```

3. 关于邮件的保存

这时 postfix 收到邮件后会保存到 `virtual_mailbox_base + 1` 的文件中，这里的 1 来自取 mysql-virtual-mailbox-maps.cf 查询出来的. 所以需要将邮件传递给 `dovecot` 去保存.

postfix 需要在`main.cf`配置中添加

```ini
# dovecot-server-ip 是 Dovecot 服务器的 IP:PORT
virtual_transport = lmtp:inet:dovecot-server-ip:24

# dovecot 还需要相应配置详细看 dovecot 配置
```

### 部署 Cyrus SASL

当 postfix 需要投递邮件时一般都会验证用户名密码(禁止匿名投递的垃圾邮件)。验让用户名和密码就有很多方式，比如 向 dovecot 验证，向 LDAP 验证，向 数据库中验证等等。

#### dovecot 验证

当 postfix 向 dovecot 验证时，如果都安装在同一台主机上，可以通过 unix 管道直接访问 dovecot,验证用户。但如果 不在同一台机器需要借助, Cyrus SASL 库来访问 dovecot。

1. 安装

```sh
## debian
sudo apt install sasl2-bin libsasl2-modules

## Alpine
sudo apk add cyrus-sasl cyrus-sasl-plain
# cyrus-sasl 包含了 Cyrus SASL 框架。
# cyrus-sasl-plain 包含了 PLAIN 认证机制模块
# 其它模块还有： cyrus-sasl-login、cyrus-sasl-digestmd5 等

# 验证Cyrus SASL 安装的插件
saslpluginviewer -a

# 查看支持的模式
saslauthd -v

```

2. 配置

```sh
# /etc/default/saslauthd
START=yes
MECHANISMS="rimap"
MECH_OPTIONS="localhost 12345"  # Dovecot 服务器的 IP 地址和端口
```

3. 用户,文件 权限

```sh
sudo usermod -aG sasl postfix

sudo mkdir -p /var/spool/postfix/var/run/saslauthd
sudo chomd a+xr /var/spool/postfix/var/run/saslauthd
```

4. 用户组,启动

```sh
sudo systemctl enable saslauthd
sudo systemctl start saslauthd

```

但配置完后我发现 postfix 只向 dovecot 发送用户名验证, 但 dovecot 接受 pop3 imap 访问时，接收到的又是完成的邮件名。虽然在 dovecot 的 `/etc/dovecot/conf.d/10-auth.conf` 文件中可以设置 `auth_default_realm = domain` 用于补全 email 地址。

#### 数据库验证

另一种是数据库直接验证用户密码, 通过数据库直接校验用户名与密码. 这里有一个天坑(卧槽~坑了我整整两天)~数据库验证也有两种方式,一种是 使用 [sql auxprop plugin](https://www.postfix.org/SASL_README.html#auxprop_sql) ,另一种是使用 `pam_mysql`.

`sql auxprop plugin` 不需要启动 `saslauthd` 服务, 把配置扔到 `/etc/postfix/sasl/smtpd.conf` 文件中就可以. 但注意看:

> Tip
> If you must store encrypted passwords, you cannot use the sql auxprop plugin. Instead, see section "Using saslauthd with PAM", and configure PAM to look up the encrypted passwords with, for example, the pam_mysql module. You will not be able to use any of the methods that require access to plaintext passwords, such as the shared-secret methods CRAM-MD5 and DIGEST-MD5.

所以要使用加密的密码验证应该使用 `pam_mysql`.

`/etc/postfix/sasl/smtpd.conf` 的配置文件

```conf
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

1. 安装

```sh
sudo apt install sasl2-bin libsasl2-modules-sql
```

2. 配置 /etc/default/saslauthd

```sh
# /etc/default/saslauthd

START=yes
MECHANISMS="auxprop"
MECH_OPTIONS=""
```

3. 配置 vim /etc/postfix/sasl/smtpd.conf

```sh
# /etc/postfix/sasl/smtpd.conf

pwcheck_method: auxprop
auxprop_plugin: sql
mech_list: PLAIN LOGIN
sql_engine: mysql
sql_hostnames: 127.0.0.1
sql_user: dbuser
sql_passwd: dbpassword
sql_database: dbname
sql_select: SELECT password FROM users WHERE username = '%u' AND domain = '%r'
```

### 部署 dovecot

1. 安装

```sh
sudo apt install dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql

```

2. 配置

2.1 /etc/dovecot/dovecot-sql.conf.ext

```ini
# /etc/dovecot/dovecot-sql.conf.ext


# %u= entire user@domain
# %n = user part of user@domain
# %d = domain part of user@domain

```

2.2 /etc/dovecot/conf.d/10-auth.conf

```ini
# /etc/dovecot/conf.d/10-auth.conf


```

### 参考文档

[Dovecot 密码格式](https://doc.dovecotpro.com/3.0.0/core/config/auth/schemes.html)
[SASL 使用数据库验证 ](https://www.postfix.org/SASL_README.html#auxprop_sql)

### 检查排错

```sh

# postfix 检查配置是否有错误, 需要使用 root 权限
sudo postfix check

# 查看 postfix 支持那些验证
postconf -a

# 查看 SASL 支持的验证模式
saslauthd -v

# 验证Cyrus SASL 安装的插件
saslpluginviewer -a

# 检查 sasl 账号
testsaslauthd -u [username] -p [password]
# testsaslauthd -u viweei@viweei.me -p linuxwindows
# 如果报权限不够，需要加入 sasl用户组.

# 检查postfix数据库是否连通
sudo postmap -q 'viweei@viweei.me' mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf

# dovecot 检查用户名与密码是否正确
sudo doveadm auth test [username]

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
docker run --rm \
--name postfix-dev \
-v $(pwd-p 25:25)/ssl:/etc/ssl \
 postfix:0.0.1

docker run --rm \
--name postfix-dev \
-v $(pwd)/ssl:/etc/ssl \
-v $(pwd)/config:/etc/postfix \
-p 25:25 postfix:0.0.1
```
