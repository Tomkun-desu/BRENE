#!/bin/sh
# Blanket getpriority uid filter: hide every package whose uid is in the app
# range (10000-19999), system or data app. The kernel resolves each name from
# /data/data/<pkg>, so a single unresolvable name fails the whole call; names
# without a data dir are skipped. POSIX sh: KernelSU runs module scripts with
# BusyBox ash / mksh, so no bashisms here.
PERSISTENT_DIR=/data/adb/brene
SUSFS_BIN=/data/adb/ksu/bin/susfs
LOG="${PERSISTENT_DIR}/log.txt"

if [ "${config_hide_all_apps_with_uid_10000_and_above}" = "1" ]; then
	candidates=$(awk '$1 !~ /^#/ && $2 >= 10000 && $2 <= 19999 {print $1 ":" $2}' /data/system/packages.list 2>/dev/null)
	label="hide_all_apps"
else
	candidates=$(cmd package list packages -U 2>/dev/null | sed -n 's/^package:\([^ ]*\) uid:\([0-9]*\)$/\1:\2/p')
	label="hide_third_party_apps"
fi

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
	[ "${config_brene_logs}" = "1" ] && echo "${label} ok (${#packages} bytes)" >> "$LOG"
else
	echo "${label} failed (${#packages} bytes): ${out:-no output}" >> "$LOG"
fi
exit 0
