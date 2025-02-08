## OpenDKIM 的作用

1. 签名邮件：OpenDKIM 可以在邮件发送时对邮件进行签名，添加一个基于域名的数字签名到邮件头部。签名使用域名的私钥生成。

2. 验证邮件：OpenDKIM 可以在邮件接收时验证邮件的 DKIM 签名，确保邮件确实来自声明的域名，并且在传输过程中未被篡改。验证使用域名的公钥进行。

## DKIM 的工作原理

1. 生成密钥对：域名所有者生成一对公钥和私钥。私钥用于签名邮件，公钥发布在 DNS 记录中。

2. 签名邮件：发送邮件时，邮件服务器使用私钥对邮件头部进行签名，并将签名添加到邮件头部。

3. 发布公钥：域名所有者在 DNS 记录中发布公钥，供接收邮件服务器验证签名。

4. 验证签名：接收邮件服务器收到邮件后，查询发送域名的 DNS 记录，获取公钥，并使用公钥验证邮件的签名。

## 特别需要注意

1. 使用 opendkim-genkey, alpine 和 debian 获取的密钥长度不一样。

```sh
# debian
default._domainkey      IN      TXT     ( "v=DKIM1; h=sha256; k=rsa; "
          "p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2Jg3K/gmH6yxk3FmA4rqK3jAZGtGOYsVgQM4GYrzilbLv43MsPng79J/xjxa8J0gHsa+XiYPjfyD2wj5l5lDgtVjCUAx0Oz+B16DUS36cW9w8E65whWRN9ZcYx9UgtvDkVsABbSXZ8DksVfTK2/1L9eR0+DX5JsFwm/VLjl2nl/ClH3NATVkuxs4xAcbojuBkmIKt9Mv4U+m2Q"
          "FILhbZL17cDi70KA058T9y7qWoooYmdq84/kKyiP0SinLSp6Lmd2G9VrdVkBQjBRnLD4JZuorl07LGbaYdd00wzdWWTffN9p7vMHpMV3g1p3pwKtva7KAKfLVgYIoJpIrLhwGsWwIDAQAB" )  ; ----- DKIM key default for viweei.me

# debian 需要将两段内容合并,去掉引号。
```

```sh
#alpine
mail._domainkey     IN      TXT     ( "v=DKIM1; k=rsa; "
"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDv86vyWpscy4mPgHCSqiFtaVXSMN0jHSPHNsK0q3uoU5e4Ao70YOlXTskyxOmi36fKuQq9Z6TJuN1iWX9aw5TVv7kyHmFPjYpSpAWVMmb9yWhX3FhqhjQVs6Z3B8f7FFUW8UDZjOwbr9MmAxysp0JgjxIYA20JxNzhajhW0DBIrwIDAQAB" )  ; ----- DKIM key mail for example.com

# alpine中只有一段
```

2. 使用`opendkim`需要将 `括号` 里的内容去掉 `引号` 添加到 DNS 中. 前缀就是 `mail._domainkey`,以 debian 为例:

```sh
default._domainkey    TXT   v=DKIM1; h=sha256; k=rsa;  p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2Jg3K/gmH6yxk3FmA4rqK3jAZGtGOYsVgQM4GYrzilbLv43MsPng79J/xjxa8J0gHsa+XiYPjfyD2wj5l5lDgtVjCUAx0Oz+B16DUS36cW9w8E65whWRN9ZcYx9UgtvDkVsABbSXZ8DksVfTK2/1L9eR0+DX5JsFwm/VLjl2nl/ClH3NATVkuxs4xAcbojuBkmIKt9Mv4U+m2QFILhbZL17cDi70KA058T9y7qWoooYmdq84/kKyiP0SinLSp6Lmd2G9VrdVkBQjBRnLD4JZuorl07LGbaYdd00wzdWWTffN9p7vMHpMV3g1p3pwKtva7KAKfLVgYIoJpIrLhwGsWwIDAQAB
```

## 验证是否生效

```sh
dig TXT mail._domainkey.viweei.me
```
