#! /bin/sh

KEY_PATH=/etc/opendkim/keys
DOMAIN=$(cat /etc/opendkim.conf|grep Domain | awk '{print $2}')

# 启动时检查密钥是否存在,不存在则生成
if [ ! -d ${KEY_PATH} ];then
  mkdir -p ${KEY_PATH}
fi

if [ ! -f ${KEY_PATH}/mail.private ];then
  opendkim-genkey -D ${KEY_PATH} -d ${DOMAIN} -s mail
fi

# 启动opendkim
cat /etc/opendkim/keys/mail.txt
opendkim -x /etc/opendkim.conf
tail -f /dev/null
