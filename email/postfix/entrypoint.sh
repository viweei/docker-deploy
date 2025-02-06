#!/bin/sh


DOVECOT_HOST=$(dig +short dovecot)
DOVECOT_PORT=12345

postconf -e "smtpd_sasl_path=inet:${DOVECOT_HOST}:${DOVECOT_PORT}"

export DB_HOST=$(dig +short mysql)
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=123456
export DB_NAME=mailserver

envsubst < /etc/postfix/sql/alias.cf.template > /etc/postfix/sql/alias.cf
envsubst < /etc/postfix/sql/domains.cf.template > /etc/postfix/sql/domains.cf
envsubst < /etc/postfix/sql/mailbox.cf.template > /etc/postfix/sql/mailbox.cf

# Start Postfix
postfix start
tail -f /var/log/postfix.log 