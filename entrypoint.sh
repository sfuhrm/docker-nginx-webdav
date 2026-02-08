#!/bin/sh

set -e
MOUNTPOINT=/media/data/
CONFIG_FILE="/etc/nginx/http.d/default.conf"
CONFIG_BACKUP="/etc/nginx/http.d/default.conf.bak"

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

# Restore original config if it exists, or create backup to ensure idempotency
if [ -f "$CONFIG_BACKUP" ]; then
    cp "$CONFIG_BACKUP" "$CONFIG_FILE"
else
    cp "$CONFIG_FILE" "$CONFIG_BACKUP"
fi

if [ -n "$USERNAME_FILE" ] && [ -n "$PASSWORD_FILE" ]; then
	if [ -r "$USERNAME_FILE" ] && [ -r "$PASSWORD_FILE" ]; then
		echo "Username / password taken from files."
		echo "$(cat "$USERNAME_FILE"):$(openssl passwd -5 -stdin < "$PASSWORD_FILE")" > /etc/nginx/htpasswd
	else
		echo "Files $USERNAME_FILE and/or $PASSWORD_FILE are not readable!"
		exit 4
	fi
elif [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
	echo "Username / password taken from env."
	echo "$USERNAME:$(echo "$PASSWORD" | openssl passwd -5 -stdin)" > /etc/nginx/htpasswd
else
    echo "Using no auth."
	sed -i 's%auth_basic "Restricted";% %g' "$CONFIG_FILE"
	sed -i 's%auth_basic_user_file /etc/nginx/htpasswd;% %g' "$CONFIG_FILE"
fi

exec "$@"
