# 关于邮件系统的搭建

## 相关系统的说明

### postfix

SMTP 协议服务器,用于邮件的投递.

### cyrusSASL

postfix 本身是不具备账户验证功能,当投递邮件时需要验证用户名密码时,需要依赖 SASL 协议(简单认证和安全层),而 CyrusSASL 是 SASL 协议的一个实现。 postfix 通过 unix 管道与 cyrusSASL(saslauthd) 通信。
