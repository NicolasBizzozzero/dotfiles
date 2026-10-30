#!/bin/sh
# Block until KeePassXC's Secret Service has an unlocked "default" collection,
# which is where Bridge stores its vault key. KeePassXC sometimes exposes the
# database without that alias (Bridge then fails with "no keychain"), so point
# it at the first unlocked collection when it is missing.
# KeePassXC 2.8 can crash right as the database is unlocked, and Bridge started
# in that second finds no keychain and makes a new empty vault: only go on once
# the collection has stayed unlocked over two checks, 5 seconds apart.
dest=org.freedesktop.secrets
svc=/org/freedesktop/secrets

ready() {
	alias=$(busctl --user call $dest $svc org.freedesktop.Secret.Service ReadAlias s default 2>/dev/null | cut -d'"' -f2)
	if [ -n "$alias" ] && [ "$alias" != / ]; then
		unlocked "$alias"
	else
		for c in $(busctl --user get-property $dest $svc org.freedesktop.Secret.Service Collections 2>/dev/null | cut -d' ' -f3- | tr -d '"'); do
			unlocked "$c" && busctl --user call $dest $svc org.freedesktop.Secret.Service SetAlias so default "$c" && return 0
		done
		return 1
	fi
}

unlocked() {
	busctl --user get-property $dest "$1" org.freedesktop.Secret.Collection Locked 2>/dev/null | grep -q false
}

checks=0
while :; do
	if ready; then
		checks=$((checks + 1))
		[ $checks -ge 2 ] && exit 0
	else
		checks=0
	fi
	sleep 5
done
