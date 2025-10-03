#!/bin/sh

set -e
MOUNTPOINT=/media/data/

if [ ! -d "/etc/nginx/http.d" ]; then
	echo "Could not find http.d config dir, exiting!"
	exit 1
fi
if [ ! -d "$MOUNTPOINT" ]; then
	echo "Could not find data $MOUNTPOINT dir, exiting!"
	exit 2
fi
if [ ! -r "$MOUNTPOINT" ]; then
	echo "Could not read-access data $MOUNTPOINT dir, exiting!"
	exit 3
fi

if [ -n "$USERNAME_FILE" ] && [ -n "$PASSWORD_FILE" ]; then
	if [ -r "$USERNAME_FILE" ] && [ -r "$PASSWORD_FILE" ]; then
		echo "Username / password taken from files."
		htpasswd < "$PASSWORD_FILE" -ic /etc/nginx/permissive/htpasswd "$(cat $USERNAME_FILE)"
	else
		echo "Files $USERNAME_FILE and/or $PASSWORD_FILE are not readable!"
		exit 4
	fi
elif [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
	echo "Username / password taken from env."
	htpasswd -bc /etc/nginx/permissive/htpasswd "$USERNAME" "$PASSWORD"
else
    echo Using no auth.
	sed -i 's%auth_basic "Restricted";% %g' /etc/nginx/permissive/default.conf
	sed -i 's%auth_basic_user_file /etc/nginx/permissive/htpasswd;% %g' /etc/nginx/permissive/default.conf
fi

unset USERNAME
unset PASSWORD
unset USERNAME_FILE
unset PASSWORD_FILE

chmod 0444 /etc/nginx/permissive/default.conf
if [ -f /etc/nginx/permissive/htpasswd ]; then
	chmod 0444 /etc/nginx/permissive/htpasswd
fi
chmod 0555 /etc/nginx/permissive

exec "$@"
