#!/bin/bash
# Translated from
# https://github.com/thomasmassmann/exim4-light/blob/master/recipes/default.rb
# and our old chef recipe

# set environment variables
MAILNAME_TEMPLATE="/etc/mailname"
PASSWD_TEMPLATE="/etc/exim4/passwd.client"
CONFIG_TEMPLATE="/etc/exim4/update-exim4.conf.conf"

CONFIG_TYPE=${EXIM4_CONFIGTYPE:-smarthost}

if [ "$SERVER_ENVIRONMENT" != "production" ]; then
  SMARTHOST_SERVER="127.0.0.1"
  SMARTHOST_PORT="1025"
else
  SMARTHOST_SERVER="email-smtp.us-west-2.amazonaws.com"
  SMARTHOST_PORT="587"
  # Amazon will resolve to a different server name each time (via the load
  # balancer), so you can’t just put your smtp server name in here.
  SMARTHOST_AUTH_SERVER="*.amazonaws.com"
  SMARTHOST_LOGIN="$SMTP_USERNAME"
  SMARTHOST_PWD="$SMTP_PASSWORD"
fi

OTHER_HOSTNAMES=$FQDN
LOCAL_INTERFACES="127.0.1.1" # make way for mailcatcher
RELAY_DOMAINS=""
MINIMALDNS="false"
RELAY_NETS=""
USE_SPLIT_CONFIG="false"
HIDE_MAILNAME="false"
LOCALDELIVERY="maildir_home"

# create mailname template
cat <<EOF >$MAILNAME_TEMPLATE
$FQDN
EOF


cat <<EOF >$PASSWD_TEMPLATE
$SMARTHOST_AUTH_SERVER:$SMARTHOST_LOGIN:$SMARTHOST_PWD
EOF

chmod 640 $PASSWD_TEMPLATE
chown root:$EXIM4_USER $PASSWD_TEMPLATE

# create update-exim4.conf.conf template
cat <<EOF >$CONFIG_TEMPLATE
dc_eximconfig_configtype='$CONFIG_TYPE'
dc_other_hostnames='$OTHER_HOSTNAMES'
dc_local_interfaces='$LOCAL_INTERFACES'
dc_readhost=''
dc_relay_domains='$RELAY_DOMAINS'
dc_minimaldns='$MINIMALDNS'
dc_relay_nets='$RELAY_NETS'
dc_smarthost='$SMARTHOST_SERVER::$SMARTHOST_PORT'
CFILEMODE='644'
dc_use_split_config='$USE_SPLIT_CONFIG'
dc_hide_mailname='$HIDE_MAILNAME'
dc_mailname_in_oh='true'
dc_localdelivery='$LOCALDELIVERY'
EOF

chmod 644 $CONFIG_TEMPLATE
chown root:root $CONFIG_TEMPLATE

# update exim4 config
update-exim4.conf -v -c /etc/exim4/exim4.conf.template
