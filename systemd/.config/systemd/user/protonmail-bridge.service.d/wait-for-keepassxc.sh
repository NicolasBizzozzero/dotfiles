#!/bin/sh
# Block until KeePassXC's Secret Service has an unlocked "default" collection,
# which is where Bridge stores its vault key. KeePassXC sometimes exposes the
# database without that alias (Bridge then fails with "no keychain"), so point
# it at the first unlocked collection when it is missing.
dest=org.freedesktop.secrets
svc=/org/freedesktop/secrets

unlocked() {
	busctl --user get-property $dest "$1" org.freedesktop.Secret.Collection Locked 2>/dev/null | grep -q false
}

while :; do
	alias=$(busctl --user call $dest $svc org.freedesktop.Secret.Service ReadAlias s default 2>/dev/null | cut -d'"' -f2)
	if [ -n "$alias" ] && [ "$alias" != / ]; then
		unlocked "$alias" && exit 0
	else
		for c in $(busctl --user get-property $dest $svc org.freedesktop.Secret.Service Collections 2>/dev/null | cut -d' ' -f3- | tr -d '"'); do
			unlocked "$c" && busctl --user call $dest $svc org.freedesktop.Secret.Service SetAlias so default "$c" && exit 0
		done
	fi
	sleep 5
done
