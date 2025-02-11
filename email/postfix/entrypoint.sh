#!/bin/sh

export DB_HOST=$(dig +short mysql | head -n 1)
export DB_PORT=3306
export DB_USER=mail
export DB_PASSWORD=123456
export DB_NAME=mailserver

envsubst < /etc/postfix/sql/alias.cf.template > /etc/postfix/sql/alias.cf
envsubst < /etc/postfix/sql/domains.cf.template > /etc/postfix/sql/domains.cf
envsubst < /etc/postfix/sql/mailbox.cf.template > /etc/postfix/sql/mailbox.cf

# 设置 dovecot 关联
DOVECOT_HOST=$(dig +short dovecot | head -n 1)
postconf -e smtpd_sasl_path=inet:${DOVECOT_HOST}:12345
postconf -e virtual_transport=lmtp:${DOVECOT_HOST}:24

# 设置过滤器
OPENDKIM_HOST=$(dig +short opendkim | head -n 1)
postconf -e milter_default_action=tempfail
postconf -e milter_protocol=6
postconf -e smtpd_milters=inet:${OPENDKIM_HOST}:8891
postconf -e non_smtpd_milters=inet:${OPENDKIM_HOST}:8891

# Start Postfix
postfix reload
postfix start
tail -f /var/log/postfix.log 