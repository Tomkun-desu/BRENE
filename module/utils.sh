#!/bin/bash
# shellcheck disable=SC2154
PATH=/data/adb/ksu/bin:$PATH
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

# Atomic + sanitized logger for logs.txt (POSIX sh compatible, no bashisms).
# Sanitizes newline/CR -> space and C0 controls/DEL -> '?' (UTF-8 bytes kept),
# then appends atomically with flock when available.
brene_log() {
    local _brene_log_msg _brene_log_file
    [ -z "${PERSISTENT_DIR:-}" ] && return 0
    _brene_log_msg=$(printf '%s' "${1:-}" | tr '\n\r' '  ' | tr '\000-\010\013\014\016-\037\177' '[?*]')
    [ -d "${PERSISTENT_DIR}" ] || mkdir -p "${PERSISTENT_DIR}" 2>/dev/null || return 0
    _brene_log_file="${PERSISTENT_DIR}/logs.txt"
    if command -v flock >/dev/null 2>&1; then
        (flock -x 9 || true; printf '%s\n' "${_brene_log_msg}" >&9) 9>>"${_brene_log_file}" 2>/dev/null || printf '%s\n' "${_brene_log_msg}" >>"${_brene_log_file}" 2>/dev/null || true
    else
        printf '%s\n' "${_brene_log_msg}" >>"${_brene_log_file}" 2>/dev/null || true
    fi
    _brene_log_msg=""
    _brene_log_file=""
    return 0
}

## brene_clone_perm <file/or/dir/perm/to/be/changed> <file/or/dir/to/clone/from>
brene_clone_perm() {
	local TO=$1
	local FROM=$2
	local permission owner group

	if [[ -z "${TO}" ]] || [[ -z "${FROM}" ]]; then
		return 1
	fi

	read -r permission owner group <<EOF || return 1
$(busybox stat -c "%a %U %G" "${FROM}" 2>/dev/null)
EOF
	[[ -n "${permission}" ]] || return 1

	busybox chmod "${permission}" "${TO}" || return 1
	busybox chown "${owner}":"${group}" "${TO}" || return 1
	busybox chcon --reference="${FROM}" "${TO}" || return 1
}

# susfs_list_full_file_access_for_third_party_apps() {
# 	local TARGET_PERMISSION="android.permission.MANAGE_EXTERNAL_STORAGE"
# 	pm list packages -3 | cut -d':' -f2 | while read -r PKGNAME; do
# 		if pm dump-package "${PKGNAME}" | grep -Eq "${TARGET_PERMISSION}"; then
# 			echo "susfs: package '${PKGNAME}' has '${TARGET_PERMISSION}' permission declared." | tee /dev/kmsg
# 		fi
# 	done
# }

resetprop_n() {
	resetprop -n "$1" "$2" || { [[ "${config_brene_logs}" == "1" ]] && brene_log "[resetprop FAILED]: $1 $2"; }
}
if_prop_exits_resetprop_n() {
	local PROP_NAME=$1
	local EXPECTED_VALUE=$2
	local CURRENT_VALUE
	CURRENT_VALUE=$(resetprop "${PROP_NAME}")

        [[ -z "${CURRENT_VALUE}" ]] || [[ "${CURRENT_VALUE}" == "${EXPECTED_VALUE}" ]] || resetprop_n "${PROP_NAME}" "${EXPECTED_VALUE}"
}

# if_contains_resetprop_n() {
# 	local PROP_NAME=$1
#   local CONTAINS_VALUE=$2
#   local NEW_VALUE=$3

#   [[ "$(resetprop ${PROP_NAME})" = *"${CONTAINS_VALUE}"* ]] && resetprop -n "${PROP_NAME}" "${NEW_VALUE}"
# }

spoof_android_system_properties() {
	local size sdk
	resetprop_n "init.svc.adbd" "stopped"
	resetprop_n "init.svc_debug_pid.adbd" ""
	resetprop_n "persist.sys.usb.config" "mtp"
	resetprop_n "ro.adb.secure" "1"
	resetprop_n "ro.crypto.state" "encrypted"
	resetprop_n "ro.debuggable" "0"
	resetprop_n "ro.force.debuggable" "0"
	resetprop_n "ro.secure" "1"
	resetprop_n "ro.secureboot.lockstate" "locked"
	resetprop_n "ro.is_ever_orange" "0"
	resetprop_n "ro.bootmode" "normal"
	resetprop_n "ro.bootimage.build.tags" "release-keys"
	resetprop_n "ro.build.type" "user"
	resetprop_n "ro.build.tags" "release-keys"
	resetprop_n "vendor.boot.vbmeta.device_state" "locked"
	resetprop_n "vendor.boot.verifiedbootstate" "green"

	resetprop_n "ro.boot.flash.locked" "1"
	resetprop_n "ro.boot.realme.lockstate" "1"
	resetprop_n "ro.boot.realmebootstate" "green"
	resetprop_n "ro.boot.verifiedbooterror" ""
	resetprop_n "ro.boot.verifiedbootstate" "green"
	resetprop_n "ro.boot.veritymode" "enforcing"
	resetprop_n "ro.boot.veritymode.managed" "yes"

	size=$(blockdev --getsize64 "/dev/block/by-name/vbmeta$(resetprop ro.boot.slot_suffix)" 2>/dev/null); [[ -n "$size" ]] && resetprop_n "ro.boot.vbmeta.size" "$size"
	resetprop_n "ro.boot.vbmeta.hash_alg" "sha256"
	resetprop_n "ro.boot.vbmeta.avb_version" "1.3"
	resetprop_n "ro.boot.vbmeta.device_state" "locked"
	resetprop_n "ro.boot.vbmeta.invalidate_on_error" "yes"

	if_prop_exits_resetprop_n "ro.warranty_bit" "0"
	if_prop_exits_resetprop_n "ro.vendor.boot.warranty_bit" "0"
	if_prop_exits_resetprop_n "ro.vendor.warranty_bit" "0"
	if_prop_exits_resetprop_n "ro.boot.warranty_bit" "0"

	# NOTE: fingerprint/utc/date are separate toggles (brene_spoof_fingerprint_props / brene_spoof_utc_props / brene_spoof_date_props).

	## Delete some prop names for newer pixel device ##
	resetprop -d "ro.boot.verifiedbooterror"
	resetprop -d "ro.boot.verifyerrorpart"
	resetprop -d "vendor.boot.verifyerrorpart"
	resetprop -d "vendor.boot.verifiedbooterror"
	resetprop -d "crashrecovery.rescue_boot_count"

	resetprop -d service.adb.root
	resetprop -d service.adb.tcp.port

	sdk="$(resetprop ro.build.version.sdk)"; case "$sdk" in ''|*[!0-9]*) sdk=0;; esac
	if [[ "$sdk" -ge 36 ]]; then
		resetprop -d sys.oem_unlock_allowed
	else
		resetprop_n "sys.oem_unlock_allowed" "0"
	fi

	resetprop -c --force
}

# Fingerprint subset fallback (mirrors upstream spoof_fingerprint_properties dcbf30f).
# Owned by config_spoof_fingerprint_properties toggle.
# Same 10-prop list + same 4-string sanitize (userdebug->user, strip evolution/crdroid/lineage).
brene_spoof_fingerprint_props() {
	local fingerprint_value new_fingerprint_value
	fingerprint_value=$(resetprop ro.build.fingerprint)
	new_fingerprint_value="${fingerprint_value//userdebug/user}"
	new_fingerprint_value="${new_fingerprint_value//evolution/}"
	new_fingerprint_value="${new_fingerprint_value//crdroid/}"
	new_fingerprint_value="${new_fingerprint_value//lineage/}"
	[[ -z "${new_fingerprint_value}" ]] && return 0
	if_prop_exits_resetprop_n "ro.bootimage.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.odm.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.odm_dlkm.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.product.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.system.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.system_dlkm.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.system_ext.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.vendor.build.fingerprint" "${new_fingerprint_value}"
	if_prop_exits_resetprop_n "ro.vendor_dlkm.build.fingerprint" "${new_fingerprint_value}"
}

brene_spoof_utc_props() {
	local new_utc_value
	new_utc_value=$(resetprop ro.build.date.utc)
	[[ -z "${new_utc_value}" ]] && return 0
	if_prop_exits_resetprop_n "ro.bootimage.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.odm.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.odm_dlkm.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.product.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.system.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.system_dlkm.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.system_ext.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.vendor.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "ro.vendor_dlkm.build.date.utc" "${new_utc_value}"
	if_prop_exits_resetprop_n "persist.vendor.build.date.utc" "${new_utc_value}"
}

brene_spoof_date_props() {
	local new_date_value
	new_date_value=$(resetprop ro.build.date)
	[[ -z "${new_date_value}" ]] && return 0
	if_prop_exits_resetprop_n "ro.bootimage.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.odm.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.odm_dlkm.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.product.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.system.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.system_dlkm.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.system_ext.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.vendor.build.date" "${new_date_value}"
	if_prop_exits_resetprop_n "ro.vendor_dlkm.build.date" "${new_date_value}"
}

brene_sus_path() {
	local _rc
	${SUSFS_BIN} add_sus_path "$1"; _rc=$?
	if [[ "${_rc}" -eq 0 && "${config_brene_logs}" == "1" ]]; then
		brene_log "[sus_path]: $1"
	fi
	return "${_rc}"
}
brene_sus_path_loop() {
	local _sus_err _sus_rc
	_sus_err=$(${SUSFS_BIN} add_sus_path_loop "$1" 2>&1); _sus_rc=$?
	if [[ "${_sus_rc}" -eq 0 ]]; then
		[[ "${config_brene_logs}" == "1" ]] && brene_log "[sus_path_loop]: $1"
	else
		[[ "${config_brene_logs}" == "1" ]] && brene_log "[sus_path_loop] FAILED rc=${_sus_rc}: $1 :: ${_sus_err}"
	fi
	return "${_sus_rc}"
}
brene_sus_map() {
	local _rc
	${SUSFS_BIN} add_sus_map "$1"; _rc=$?
	if [[ "${_rc}" -eq 0 && "${config_brene_logs}" == "1" ]]; then
		brene_log "[sus_map]: $1"
	fi
	return "${_rc}"
}
# add_open_redirect <src> <dst> <uid_scheme>: both must already exist.
# Only absolute paths are accepted (never flags). No auto SELinux fix:
# fix the redirected path context yourself, e.g. brene_clone_perm "$DST" "$SRC".
brene_open_redirect() {
	local SRC=$1
	local DST=$2
	local UID_SCHEME=${3:-3}
	local _or_bad=""
	local _or_err _or_rc
	[ -z "${SRC}" ] && _or_bad="empty path"
	[ -z "${DST}" ] && _or_bad="empty path"
	if [ -z "${_or_bad}" ]; then
		case "${SRC}" in /*) ;; *) _or_bad="not absolute";; esac
	fi
	if [ -z "${_or_bad}" ]; then
		case "${DST}" in /*) ;; *) _or_bad="not absolute";; esac
	fi
	if [ -z "${_or_bad}" ]; then
		case "${UID_SCHEME}" in [0-4]) ;; *) _or_bad="bad uid_scheme '${UID_SCHEME}'";; esac
	fi
	if [ -z "${_or_bad}" ]; then
		[ "${SRC}" = "${DST}" ] && _or_bad="src==dst"
	fi
	if [ -z "${_or_bad}" ]; then
		[ -e "${SRC}" ] || _or_bad="missing src"
		if [ ! -e "${DST}" ]; then
			if [ -n "${_or_bad}" ]; then
				_or_bad="${_or_bad}+missing dst"
			else
				_or_bad="missing dst"
			fi
		fi
	fi
	if [ -n "${_or_bad}" ]; then
		[ "${config_brene_logs}" = "1" ] && brene_log "[open_redirect] SKIPPED (${_or_bad}): ${SRC} -> ${DST} (${UID_SCHEME})"
		return 1
	fi
	_or_err=$(${SUSFS_BIN} add_open_redirect "${SRC}" "${DST}" "${UID_SCHEME}" 2>&1); _or_rc=$?
	if [ "${_or_rc}" -eq 0 ]; then
		[ "${config_brene_logs}" = "1" ] && brene_log "[open_redirect]: ${SRC} -> ${DST} (${UID_SCHEME})"
	else
		[[ "${config_brene_logs}" == "1" ]] && brene_log "[open_redirect] FAILED rc=${_or_rc}: ${SRC} -> ${DST} (${UID_SCHEME}) :: ${_or_err}"
	fi
	return "${_or_rc}"
}
brene_set_uname() {
	local _rc
	${SUSFS_BIN} set_uname "$1" "$2"; _rc=$?
	if [[ "${_rc}" -eq 0 && "${config_brene_logs}" == "1" ]]; then
		brene_log "[set_uname]: $1 $2"
	fi
	return "${_rc}"
}
brene_kernel_umount() {
	local TARGET=$1
	${KSU_BIN} kernel notify-module-mounted
	${KSU_BIN} kernel umount add -f 2 "$TARGET" 2> /dev/null
}

# Backward compatibility for existing custom_sus_mount.txt users.
brene_sus_mount() {
	brene_kernel_umount "$1"
}
brene_sus_kstat_static() {
	local TARGET=$1 STAT_OUT INO DEV NLINK SIZE BLOCKS BLKSIZE _kstat_rc
	[ -z "${TARGET}" ] && return
	[ ! -e "${TARGET}" ] && return

	STAT_OUT=$(stat -c "%i %d %h %s %b %B" "${TARGET}" 2>/dev/null)
	[ -z "${STAT_OUT}" ] && return
	set -f
	set -- ${STAT_OUT}
	[[ $# -eq 6 ]] || return 1
	set +f
	INO=$1; DEV=$2; NLINK=$3; SIZE=$4; BLOCKS=$5; BLKSIZE=$6

	${SUSFS_BIN} add_sus_kstat_statically "${TARGET}" "${INO}" "${DEV}" "${NLINK}" "${SIZE}" 'default' 'default' 'default' 'default' 'default' 'default' "${BLOCKS}" "${BLKSIZE}"; _kstat_rc=$?
	if [[ "${_kstat_rc}" -eq 0 && "${config_brene_logs}" == "1" ]]; then
		brene_log "[sus_kstat_static]: ${TARGET} (ino=${INO} dev=${DEV} nlink=${NLINK} size=${SIZE} blocks=${BLOCKS} blksize=${BLKSIZE})"
	fi
	[[ "${_kstat_rc}" -eq 0 ]] && ${SUSFS_BIN} update_sus_kstat "${TARGET}" 2> /dev/null
	return "${_kstat_rc}"
}

# Log one kstat line (only when brene logs are enabled).
__brene_kstat_log() {
	[[ "${config_brene_logs}" == "1" ]] && brene_log "$1"
}

# Run one susfs kstat command, capturing the REAL exit status (never
# `if var="$(...)"`, whose status is always 0). Logs OK/FAILED uniformly.
# Usage: __brene_kstat_run <log-tag> <susfs-cmd> [args...]
__brene_kstat_run() {
	local _tag="$1"; shift
	local _err _rc
	_err="$("${SUSFS_BIN}" "$@" 2>&1)"; _rc=$?
	if [[ "${_rc}" -eq 0 ]]; then
		__brene_kstat_log "[custom_sus_kstat:${_tag}]: OK: $*"
	else
		__brene_kstat_log "[custom_sus_kstat:${_tag}] FAILED rc=${_rc}: $* :: ${_err}"
	fi
	return "${_rc}"
}

# Validate one static kstat value: 'default'/empty or decimal digits.
__brene_kstat_valid_val() {
	case "$1" in
		""|default) return 0 ;;
		*[^0-9]*) return 1 ;;
		*) return 0 ;;
	esac
}

# brene_kstat_add_line <raw-line>
# Parse one custom_sus_kstat.txt line and issue the matching susfs add command:
#   bare /path            -> add_sus_kstat (normal, boot-time snapshot)
#   fullclone:/path       -> add_sus_kstat (full-clone snapshot)
#   13 TAB fields         -> add_sus_kstat_statically (explicit values)
#   13 space fields       -> same (legacy hand-edited lines)
# Safe to call live from a root shell (e.g. via su -c) as well as from boot.
# Returns 0 on add success, 1 on failure/skip (2 = empty/comment, silent).
brene_kstat_add_line() {
	local _raw="$1" _line _trim _n _p _had_glob=0 _oldifs
	# Strip ONE trailing CR (CRLF-edited files). NOTE: $'\r' must NOT be
	# quoted -- "...$'\r'..." would strip the literal 4 chars $'\r' instead.
	_line=${_raw%$'\r'}
	_trim="$(printf '%s' "${_line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	[[ -z "${_trim}" || "${_trim}" == "#"* ]] && return 2

	case $- in *f*) _had_glob=1 ;; esac
	set -f
	_oldifs="${IFS}"; IFS=$'\t'; set -- ${_line}; IFS="${_oldifs}"
	_n=$#
	[[ "${_had_glob}" -eq 0 ]] && set +f

	if [[ "${_n}" -eq 1 ]]; then
		case "$1" in
			fullclone:/*)
				_p="${1#fullclone:}"
				if [[ ! -e "${_p}" ]]; then
					__brene_kstat_log "[custom_sus_kstat] SKIPPED (not found): ${_line}"
					return 1
				fi
				__brene_kstat_run "fullclone" add_sus_kstat "${_p}"
				return $? ;;
			/*)
				# Legacy fallback: space-separated static line (13 ws fields).
				set -f; set -- $1
				if [[ "$#" -eq 13 ]]; then
					[[ "${_had_glob}" -eq 0 ]] && set +f
					__brene_kstat_add_static "(legacy space-separated)" "${_line}" "$@"
					return $?
				fi
				[[ "${_had_glob}" -eq 0 ]] && set +f
				if [[ ! -e "$1" ]]; then
					__brene_kstat_log "[custom_sus_kstat] SKIPPED (not found): ${_line}"
					return 1
				fi
				__brene_kstat_run "normal" add_sus_kstat "$1"
				return $? ;;
			*)
				__brene_kstat_log "[custom_sus_kstat] SKIPPED (not absolute path): ${_line}"
				return 1 ;;
		esac
	elif [[ "${_n}" -eq 13 ]]; then
		case "$1" in
			/*) __brene_kstat_add_static "" "${_line}" "$@"; return $? ;;
			*) __brene_kstat_log "[custom_sus_kstat] SKIPPED (not absolute path): ${_line}"; return 1 ;;
		esac
	else
		__brene_kstat_log "[custom_sus_kstat] SKIPPED (expected 1 or 13 fields, got ${_n}): ${_line}"
		return 1
	fi
}

# __brene_kstat_add_static <note> <rawline> <path> <12 values...>
# (internal: validates values, checks existence, runs add_sus_kstat_statically)
# NOTE: no bash arrays here -- the installer parses every *.sh with plain sh,
# where `arr+=(x)` is a hard syntax error (while [[ ]] merely parses as a
# command name). Values are validated to digits/'default' so plain
# word-splitting below is safe.
__brene_kstat_add_static() {
	local _note="$1" _raw="$2" _p="$3"
	shift 3
	local _v _list=""
	for _v in "$@"; do
		[ -z "${_v}" ] && _v="default"
		if ! __brene_kstat_valid_val "${_v}"; then
			__brene_kstat_log "[custom_sus_kstat] SKIPPED (bad value '${_v}'): ${_raw}"
			return 1
		fi
		_list="${_list} ${_v}"
	done
	if [[ ! -e "${_p}" ]]; then
		__brene_kstat_log "[custom_sus_kstat] SKIPPED (not found): ${_raw}"
		return 1
	fi
	# shellcheck disable=SC2086
	if __brene_kstat_run "static" add_sus_kstat_statically "${_p}" ${_list}; then
		[[ -n "${_note}" ]] && __brene_kstat_log "[custom_sus_kstat:static] note ${_note}: ${_raw}"
		return 0
	fi
	return 1
}

# brene_kstat_update_line <raw-line>
# Late-stage refresh for one custom_sus_kstat.txt line (called from service.sh):
#   normal / bare path      -> update_sus_kstat
#   fullclone:/path         -> update_sus_kstat_full_clone
#   static (13 fields)      -> update_sus_kstat (completes the static add
#                              after mounts are up, per susfs docs)
# Returns 0 on update success, 1 on failure/skip (2 = empty/comment, silent).
brene_kstat_update_line() {
	local _raw="$1" _line _trim _n _p _had_glob=0 _oldifs
	_line=${_raw%$'\r'}
	_trim="$(printf '%s' "${_line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	[[ -z "${_trim}" || "${_trim}" == "#"* ]] && return 2

	case $- in *f*) _had_glob=1 ;; esac
	set -f
	_oldifs="${IFS}"; IFS=$'\t'; set -- ${_line}; IFS="${_oldifs}"
	_n=$#
	[[ "${_had_glob}" -eq 0 ]] && set +f

	if [[ "${_n}" -eq 1 ]]; then
		case "$1" in
			fullclone:/*)
				_p="${1#fullclone:}"
				__brene_kstat_run "update-full-clone" update_sus_kstat_full_clone "${_p}"
				return $? ;;
			/*)
				set -f; set -- $1
				if [[ "$#" -eq 13 ]]; then
					[[ "${_had_glob}" -eq 0 ]] && set +f
					__brene_kstat_run "update-static" update_sus_kstat "$1"
					return $?
				fi
				[[ "${_had_glob}" -eq 0 ]] && set +f
				__brene_kstat_run "update" update_sus_kstat "$1"
				return $? ;;
			*) return 1 ;;
		esac
	elif [[ "${_n}" -eq 13 ]]; then
		case "$1" in
			/*) __brene_kstat_run "update-static" update_sus_kstat "$1"; return $? ;;
			*) return 1 ;;
		esac
	else
		return 1
	fi
}
