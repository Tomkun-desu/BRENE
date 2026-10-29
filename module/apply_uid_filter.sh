#!/bin/sh
# Blanket getpriority uid filter: hide every package whose uid is in the app
# range (10000-19999), system or data app. The kernel resolves each name from
# /data/data/<pkg>, so a single unresolvable name fails the whole call; names
# without a data dir are skipped. POSIX sh: KernelSU runs module scripts with
# BusyBox ash / mksh, so no bashisms here.
PERSISTENT_DIR=/data/adb/brene
SUSFS_BIN=/data/adb/ksu/bin/susfs
LOG="${PERSISTENT_DIR}/log.txt"

candidates=$(pm list packages -U 2>/dev/null | sed -n 's/^package:\([^ ]*\) uid:\([0-9]*\)$/\1:\2/p')

packages=""
for entry in $candidates; do
	name=${entry%%:*}
	uid=${entry##*:}
	[ "$uid" -ge 10000 ] 2>/dev/null || continue
	[ "$uid" -le 19999 ] 2>/dev/null || continue
	[ -d "/data/data/${name}" ] || continue
	packages="${packages}${packages:+,}${name}"
done

[ -n "$packages" ] || exit 0

if out=$("$SUSFS_BIN" set_priority_uid_filter "$packages" 2>&1); then
	[ "${config_brene_logs}" = "1" ] && echo "hide_third_party_apps ok (${#packages} bytes)" >> "$LOG"
else
	echo "hide_third_party_apps failed (${#packages} bytes): ${out:-no output}" >> "$LOG"
fi
exit 0
