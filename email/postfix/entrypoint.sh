#!/bin/sh

DB_HOST=$(dig +short mysql)
DB_PORT=3306
DB_USER=root
DB_PASSWORD=123456
DB_NAME=mailserver

DOVECOT_HOST=$(dig +short dovecot)
DOVECOT_PORT=12345

postconf -e smtpd_sasl_path=inet:$DOVECOT_HOST:$DOVECOT_PORT

envsubst < /etc/postfix/sql/alias.cf.template > /etc/postfix/sql/alias.cf
envsubst < /etc/postfix/sql/domain.cf.template > /etc/postfix/sql/domain.cf
envsubst < /etc/postfix/sql/mailbox.cf.template > /etc/postfix/sql/mailbox.cf

# Start Postfix
postfix start
tail -f /var/log/postfix.log 