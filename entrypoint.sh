#!/bin/sh

set -eu

MOUNTPOINT="/media/data/"
CONFIG_FILE="/etc/nginx/http.d/default.conf"
CONFIG_TEMPLATE="/etc/nginx/http.d/default.conf.template"
HTPASSWD="/var/lib/nginx/htpasswd"

if [ ! -d "/etc/nginx/http.d" ]; then
	echo "Could not find http.d config dir, exiting!"
	exit 1
fi
if [ ! -f "$CONFIG_TEMPLATE" ]; then
	echo "Could not find config template $CONFIG_TEMPLATE, exiting!"
	exit 2
fi
if [ ! -d "$MOUNTPOINT" ]; then
	echo "Could not find data $MOUNTPOINT dir, exiting!"
	exit 3
fi
if [ ! -r "$MOUNTPOINT" ]; then
	echo "Could not read-access data $MOUNTPOINT dir, exiting!"
	exit 4
fi

# Regenerate the config from the immutable template on every start to stay idempotent
cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

USERNAME="${USERNAME:-}"
PASSWORD="${PASSWORD:-}"
USERNAME_FILE="${USERNAME_FILE:-}"
PASSWORD_FILE="${PASSWORD_FILE:-}"
GZIP="${GZIP:-}"

if [ -n "$USERNAME_FILE" ] && [ -n "$PASSWORD_FILE" ]; then
	if [ -r "$USERNAME_FILE" ] && [ -r "$PASSWORD_FILE" ]; then
		echo "Username / password taken from files."
		USERNAME_CONTENT="$(cat "$USERNAME_FILE")"
		PASSWORD_HASH="$(openssl passwd -6 -stdin < "$PASSWORD_FILE")"
		printf '%s:%s\n' "$USERNAME_CONTENT" "$PASSWORD_HASH" > "$HTPASSWD"
	else
		echo "Files $USERNAME_FILE and/or $PASSWORD_FILE are not readable!"
		exit 5
	fi
elif [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
	echo "Username / password taken from env."
	PASSWORD_HASH="$(printf '%s' "$PASSWORD" | openssl passwd -6 -stdin)"
	printf '%s:%s\n' "$USERNAME" "$PASSWORD_HASH" > "$HTPASSWD"
else
	echo "Using no auth."
	sed -i '/auth_basic/d' "$CONFIG_FILE"
fi

if [ "$GZIP" != "1" ]; then
	sed -i '/gzip/d' "$CONFIG_FILE"
fi

if [ -f "$HTPASSWD" ]; then
	chmod 600 "$HTPASSWD"
fi

# Validate the generated config before starting nginx
nginx -t

exec "$@"
