#!/bin/bash

set -e
MOUNTPOINT=/media/data/

if [ ! -d "/etc/nginx/http.d" ]
then
	echo "Could not find http.d config dir, exiting!"
	exit 1
fi
if [ ! -d "$MOUNTPOINT" ]
then
	echo "Could not find data $MOUNTPOINT dir, exiting!"
	exit 2
fi
if [ ! -r "$MOUNTPOINT" ]
then
	echo "Could read-access data $MOUNTPOINT dir, exiting!"
	exit 3
fi

if [ -n "$USERNAME_FILE" ] && [ -n "$PASSWORD_FILE" ]; then
	echo "Username / password taken from files."
	htpasswd -bc /etc/nginx/htpasswd "$(cat $USERNAME_FILE)" "$(cat $PASSWORD_FILE)"
elif [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
	echo "Username / password taken from env."
	htpasswd -bc /etc/nginx/htpasswd "$USERNAME" "$PASSWORD"
else
    echo Using no auth.
	sed -i 's%auth_basic "Restricted";% %g' /etc/nginx/http.d/default.conf
	sed -i 's%auth_basic_user_file /etc/nginx/htpasswd;% %g' /etc/nginx/http.d/default.conf
fi

exec "$@"
