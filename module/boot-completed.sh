#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
mkdir -p "${PERSISTENT_DIR}"
DEST_BIN_DIR=/data/adb/ksu/bin
CUSTOM_ROM_NAMES="lineage|infinity|evolution|crdroid|mistos|axion|pixelos|rising|lunaris|halcyon|havoc|alphadroid|bliss|calyx|derpfest|graphene|lmodroid|lumine|matrixx|clover|yaap|aospa"

# Load utils
[[ -e "${MODDIR}/utils.sh" ]] && source "${MODDIR}/utils.sh"
# Load config (allowlist parser; never source untrusted file)
# POSIX sh compatible (BusyBox ash, mksh, bash, dash) - KernelSU runs boot
# scripts in BusyBox ash, so no bashisms here (no [[, no printf -v, no ${v:1:-1}).
if [ -e "${PERSISTENT_DIR}/config.sh" ]; then
  while IFS='=' read -r k v || [ -n "$k" ]; do
    # Strip CR (handle CRLF-edited files)
    k=$(printf '%s' "$k" | tr -d '\r')
    v=$(printf '%s' "$v" | tr -d '\r')
    # Strip one pair of surrounding single or double quotes
    case "$v" in
      \'*\'|\"*\")
        v=${v#?}
        v=${v%?}
        ;;
    esac
    # Allowlist: key must be config_ + [A-Za-z0-9_] only
    case "$k" in
      config_*) ;;
      *) continue ;;
    esac
    case "$k" in
      *[!A-Za-z0-9_]* ) continue ;;
    esac
    # shellcheck disable=SC2034 # config_* values are consumed across module scripts
    # Assign without eval (safe in BusyBox ash, dash, mksh, bash):
    # a plain quoted 'name="$v"' assignment does no word splitting or
    # globbing and never re-executes the value, so '$(...)', backticks
    # and ';' inside $v stay inert. The key is already allowlisted to
    # config_[A-Za-z0-9_]; dispatch on the name explicitly so that no
    # dynamic variable name (and no eval) is needed. When adding a new
    # config_ key, extend this list.
    case "$k" in
      config_brene_logs) config_brene_logs="$v" ;;
      config_custom_uname_kernel_release) config_custom_uname_kernel_release="$v" ;;
      config_custom_uname_kernel_version) config_custom_uname_kernel_version="$v" ;;
      config_custom_spoof_uname) config_custom_spoof_uname="$v" ;;
      config_developer_options) config_developer_options="$v" ;;
      config_disable_child_process_restrictions) config_disable_child_process_restrictions="$v" ;;
      config_enable_avc_log_spoofing) config_enable_avc_log_spoofing="$v" ;;
      config_enable_log) config_enable_log="$v" ;;
      config_fix_data_local_tmp_inconsistencies) config_fix_data_local_tmp_inconsistencies="$v" ;;
      config_hide_addon_d) config_hide_addon_d="$v" ;;
      config_hide_custom_recovery) config_hide_custom_recovery="$v" ;;
      config_hide_custom_rom_paths) config_hide_custom_rom_paths="$v" ;;
      config_hide_custom_rom_paths_2) config_hide_custom_rom_paths_2="$v" ;;
      config_hide_framework_res_apk) config_hide_framework_res_apk="$v" ;;
      config_hide_injections) config_hide_injections="$v" ;;
      config_hide_lineage_strings) config_hide_lineage_strings="$v" ;;
      config_hide_sus_mnts_for_non_su_procs) config_hide_sus_mnts_for_non_su_procs="$v" ;;
      config_hide_suspicious_pty) config_hide_suspicious_pty="$v" ;;
      config_kernel_umount) config_kernel_umount="$v" ;;
      config_paths_hiding__data_local_tmp) config_paths_hiding__data_local_tmp="$v" ;;
      config_paths_hiding__non_standard_sdcard) config_paths_hiding__non_standard_sdcard="$v" ;;
      config_paths_hiding__non_standard_sdcard_android) config_paths_hiding__non_standard_sdcard_android="$v" ;;
      config_paths_hiding__sdcard_android_data_media_obb) config_paths_hiding__sdcard_android_data_media_obb="$v" ;;
      config_paths_hiding__user_ca_certs) config_paths_hiding__user_ca_certs="$v" ;;
      config_pif_props) config_pif_props="$v" ;;
      config_rom_props) config_rom_props="$v" ;;
      config_saturation) config_saturation="$v" ;;
      config_selinux) config_selinux="$v" ;;
      config_selinux_hide) config_selinux_hide="$v" ;;
      config_show_refresh_rate) config_show_refresh_rate="$v" ;;
      config_spoof_cmdline_or_bootconfig) config_spoof_cmdline_or_bootconfig="$v" ;;
      config_spoof_date_properties) config_spoof_date_properties="$v" ;;
      config_spoof_fingerprint_properties) config_spoof_fingerprint_properties="$v" ;;
      config_spoof_hosts) config_spoof_hosts="$v" ;;
      config_spoof_libstagefright) config_spoof_libstagefright="$v" ;;
      config_spoof_os_patch_level_property) config_spoof_os_patch_level_property="$v" ;;
      config_spoof_os_security_patch_level_property) config_spoof_os_security_patch_level_property="$v" ;;
      config_spoof_system_properties) config_spoof_system_properties="$v" ;;
      config_spoof_system_properties_repeat) config_spoof_system_properties_repeat="$v" ;;
      config_spoof_utc_properties) config_spoof_utc_properties="$v" ;;
      config_spoof_vendor_security_patch_level_property) config_spoof_vendor_security_patch_level_property="$v" ;;
      config_su_compat) config_su_compat="$v" ;;
      config_sync_device_props) config_sync_device_props="$v" ;;
      config_umount_suspicious_mounts) config_umount_suspicious_mounts="$v" ;;
      config_spoof_uname) config_spoof_uname="$v" ;;
      config_usb_debugging) config_usb_debugging="$v" ;;
      config_spoof_verified_boot_hash) config_spoof_verified_boot_hash="$v" ;;
      config_wireless_debugging) config_wireless_debugging="$v" ;;
      *) continue ;; # unknown config_ key: ignore
    esac
  done < "${PERSISTENT_DIR}/config.sh"
fi
# Deprecated keys merged into config_spoof_system_properties (OR-migration, never disables).
if [ "${config_sync_device_props}" = "1" ]; then
  config_spoof_system_properties=1
fi
if [ "${config_spoof_system_properties_repeat}" = "1" ]; then
  config_spoof_system_properties=1
fi

# Update Description
# Fail-loud like customize.sh: only v2* counts as healthy; missing/mismatch -> honest ❌ (no exit, boot never blocked)
# Both branches carry the same detail level (kernel + susfs ver/variant + features); empty probes fall back to missing/unknown.
susfs_ver=$(${SUSFS_BIN} show version 2>/dev/null || true)
susfs_variant=$(${SUSFS_BIN} show variant 2>/dev/null || true)
susfs_features_number=$(${SUSFS_BIN} show enabled_features 2>/dev/null | wc -l)
susfs_total_features=9
kernel_version=$(cat /proc/version 2>/dev/null | awk '{print $3}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
kernel_version=${kernel_version:-unknown}
susfs_ver=${susfs_ver:-missing}
susfs_variant=${susfs_variant:-unknown}
description="A SuSFS/KernelSU module for SuSFS patched kernels"
if [[ "${susfs_ver}" == "v2"* ]]; then
	${KSU_BIN} module config set override.description "[Module Status: ✅ | Kernel: ${kernel_version} | SuSFS Patches: ✅ ${susfs_ver} (${susfs_variant}) | SuSFS Features: ${susfs_features_number}/${susfs_total_features}] ${description}" 2>/dev/null || true
else
	${KSU_BIN} module config set override.description "[Module Status: ❌ | Kernel: ${kernel_version} | SuSFS Patches: ❌ ${susfs_ver} (${susfs_variant}) | SuSFS Features: ${susfs_features_number}/${susfs_total_features}] ${description}" 2>/dev/null || true
fi

# SU Compat (fail-safe: ksud absence/rejection never blocks boot)
if [[ "${config_su_compat}" == "1" ]]; then
	${KSU_BIN} feature set su_compat 1 2>/dev/null || true
elif [[ "${config_su_compat}" == "0" ]]; then
	${KSU_BIN} feature set su_compat 0 2>/dev/null || true
fi

# Kernel Umount
if [[ "${config_kernel_umount}" == "1" ]]; then
	${KSU_BIN} feature set kernel_umount 1 2>/dev/null || true
elif [[ "${config_kernel_umount}" == "0" ]]; then
	${KSU_BIN} feature set kernel_umount 0 2>/dev/null || true
fi

# Hide SELinux modification
if [[ "${config_selinux_hide}" == "1" ]]; then
	${KSU_BIN} feature set selinux_hide 1 2>/dev/null || true
elif [[ "${config_selinux_hide}" == "0" ]]; then
	${KSU_BIN} feature set selinux_hide 0 2>/dev/null || true
fi

${KSU_BIN} feature save 2>/dev/null || true

# Developer Options
if [[ "${config_developer_options}" == "1" ]]; then
	command -v settings >/dev/null 2>&1 && settings put global development_settings_enabled 1
elif [[ "${config_developer_options}" == "0" ]]; then
	command -v settings >/dev/null 2>&1 && settings put global development_settings_enabled 0
fi

# USB Debugging
if [[ "${config_usb_debugging}" == "1" ]]; then
	command -v settings >/dev/null 2>&1 && settings put global adb_enabled 1
elif [[ "${config_usb_debugging}" == "0" ]]; then
	command -v settings >/dev/null 2>&1 && settings put global adb_enabled 0
fi

# Wireless Debugging
if [[ "${config_wireless_debugging}" == "1" ]]; then
	command -v settings >/dev/null 2>&1 && settings put global adb_wifi_enabled 1
elif [[ "${config_wireless_debugging}" == "0" ]]; then
	command -v settings >/dev/null 2>&1 && settings put global adb_wifi_enabled 0
fi

# Disable Child Process Restrictions
if [[ "${config_disable_child_process_restrictions}" == "1" ]]; then
        resetprop_n persist.sys.fflag.override.settings_enable_monitor_phantom_procs false
fi

# SELinux Enforcing
if [[ "${config_selinux}" == "1" ]] && command -v getenforce >/dev/null 2>&1 && command -v setenforce >/dev/null 2>&1; then
	[[ "$(getenforce)" != "Enforcing" ]] && setenforce 1
fi

# Remove Custom ROM Properties
if [[ "${config_rom_props}" == "1" ]]; then
	# Match on prop NAME only (value may legitimately contain e.g. "lineage" in fingerprint)
	resetprop | awk -F'[][]' '{print $2}' | grep -iE "${CUSTOM_ROM_NAMES}" | grep -E '^[a-zA-Z0-9_.-]+$' | while IFS= read -r prop; do
		resetprop -d "${prop}"
	done

	resetprop -d "ro.modversion"
fi

# Remove Play Integrity Fix Properties
if [[ "${config_pif_props}" == "1" ]]; then
	resetprop | grep -iE "pihook|pixelprops|spoof" | awk -F'[][]' '{print $2}' | grep -E '^[a-zA-Z0-9_.-]+$' | while IFS= read -r prop; do
		resetprop -d -p "${prop}"
	done
fi

# Spoof /system/lib64/libstagefright.so
if [[ "${config_spoof_libstagefright}" == "1" ]]; then
        path=/system/lib64/libstagefright.so
        safe="$(printf '%s' "${path}" | tr '/' '_')"
        fake_file_path="${PERSISTENT_DIR}/fake_files/${safe}"

        [[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
        busybox chcon --reference="${path}" "${PERSISTENT_DIR}/fake_files" 2>/dev/null || true
        [ -L "${fake_file_path}" ] && rm -f -- "${fake_file_path}"
        [[ ! -f "${fake_file_path}" ]] && {
                touch "${fake_file_path}"
        }

        brene_clone_perm "${fake_file_path}" "${path}" || true

        brene_open_redirect "${path}" "${fake_file_path}" '3' || true
fi

# Hide LineageOS Strings
if [[ "${config_hide_lineage_strings}" == "1" ]]; then
	brene_find /system /system_ext /vendor /product \( -iname "*sepolicy.cil" -o -iname "*file_contexts" \) -print0 | while IFS= read -r -d '' path; do
		safe="$(printf '%s' "$path" | tr '/' '_')"
		fake_file_path="${PERSISTENT_DIR}/fake_files/${safe}"

		[[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
		busybox chcon --reference="${path}" "${PERSISTENT_DIR}/fake_files" 2>/dev/null || true
		[ -L "${fake_file_path}" ] && rm -f -- "${fake_file_path}"
                if [[ ! -f "${fake_file_path}" ]]; then
                        cp "${path}" "${fake_file_path}" || continue
                        sed -i "s/lineage//g" "${fake_file_path}"
                fi

                brene_clone_perm "${fake_file_path}" "${path}" || true
		brene_open_redirect "${path}" "${fake_file_path}" '3' || true
	done

	brene_find /system_ext/etc/permissions -maxdepth 1 -iname "Updater.xml" -print0 | while IFS= read -r -d '' path; do
		[ -e "${path}" ] || continue
		safe="$(printf '%s' "${path}" | tr '/' '_')"
			fake_file_path="${PERSISTENT_DIR}/fake_files/${safe}"

			[[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
			busybox chcon --reference="${path}" "${PERSISTENT_DIR}/fake_files" 2>/dev/null || true
			[ -L "${fake_file_path}" ] && rm -f -- "${fake_file_path}"
			if [[ ! -f "${fake_file_path}" ]]; then
				cp "${path}" "${fake_file_path}" || continue
				sed -i "s/lineage//g" "${fake_file_path}"
			fi

			brene_clone_perm "${fake_file_path}" "${path}" || true
			brene_open_redirect "${path}" "${fake_file_path}" '3' || true
	done
fi

# Hide LineageOS Strings in RC files
if [[ "${config_hide_lineage_strings}" == "1" ]]; then
        brene_find /system /system_ext /vendor /product -iname "*.rc" -print0 | while IFS= read -r -d '' path; do
                if grep -iq "lineage" "${path}"; then
                        safe="$(printf '%s' "$path" | tr '/' '_')"
                        fake_file_path="${PERSISTENT_DIR}/fake_files/${safe}"

                        [[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
                        busybox chcon --reference="${path}" "${PERSISTENT_DIR}/fake_files" 2>/dev/null || true
                        [ -L "${fake_file_path}" ] && rm -f -- "${fake_file_path}"
                        if [[ ! -f "${fake_file_path}" ]]; then
                                cp "${path}" "${fake_file_path}" || continue
                                sed -i "s/lineage//g" "${fake_file_path}"
                        fi

                        brene_clone_perm "${fake_file_path}" "${path}" || true
                        brene_open_redirect "${path}" "${fake_file_path}" '3' || true
                fi
        done
fi

# Max Saturation
if [[ "${config_saturation}" == "1" ]]; then
	command -v service >/dev/null 2>&1 && service call SurfaceFlinger 1022 f 2.0
fi
# Show Refresh Rate
if [[ "${config_show_refresh_rate}" == "1" ]]; then
    command -v service >/dev/null 2>&1 && service call SurfaceFlinger 1034 i32 1
fi

#### Hide some sus paths, effective only for processes that are marked umounted with uid >= 10000 ####
# Spoof Android System Properties
if [[ "${config_spoof_system_properties}" == "1" ]]; then
   brene_spoof_system_properties || true
fi
# Spoof Fingerprint Properties
if [[ "${config_spoof_fingerprint_properties}" == "1" ]]; then
   brene_spoof_fingerprint_props || true
fi
# Spoof UTC Properties
if [[ "${config_spoof_utc_properties}" == "1" ]]; then
   brene_spoof_utc_props || true
fi
# Spoof Date Properties
if [[ "${config_spoof_date_properties}" == "1" ]]; then
   brene_spoof_date_props || true
fi
# Spoof OS Security Patch Level Property
if [[ "${config_spoof_os_security_patch_level_property}" == "1" ]]; then
   brene_spoof_os_security_patch_props || true
fi
# Spoof Vendor Security Patch Level Property
if [[ "${config_spoof_vendor_security_patch_level_property}" == "1" ]]; then
   brene_spoof_vendor_security_patch_props || true
fi

## First we need to wait until files are accessible in /sdcard ##
_wait_count=0; until [[ -e "/sdcard/Android" ]] || [[ "${_wait_count}" -ge 10 ]]; do sleep 1; _wait_count=$((_wait_count + 1)); done
# Helper: wait until DIR shows at least one entry (dent existence alone is not
# enough — FUSE/vold can create the mountpoint before readdir returns entries).
# Bounded only; never blocks boot. rc=0 when non-empty, 1 on timeout.
brene_wait_for_nonempty_listing() {
	local _bwf_dir="$1" _bwf_max="${2:-15}" _bwf_n=0 _bwf_cnt
	while [[ "${_bwf_n}" -lt "${_bwf_max}" ]]; do
		_bwf_cnt=$(ls -1 "${_bwf_dir}" 2>/dev/null | wc -l)
		[[ "${_bwf_cnt}" -gt 0 ]] && return 0
		sleep 2; _bwf_n=$((_bwf_n + 1))
	done
	return 1
}
# Spoof Android System Properties Every Minute
if [[ "${config_spoof_system_properties_repeat}" == "1" ]]; then
   if mkdir "${PERSISTENT_DIR}/spoof_repeat.pid.lock" 2>/dev/null; then
      trap 'rmdir "${PERSISTENT_DIR}/spoof_repeat.pid.lock" 2>/dev/null' EXIT INT TERM
      _spoof_pid="$(cat "${PERSISTENT_DIR}/spoof_repeat.pid" 2>/dev/null)"
      case "${_spoof_pid}" in
         ''|*[!0-9]*)
            # stale pidfile (empty/non-numeric) -> drop it and start a fresh single daemon
            rm -f "${PERSISTENT_DIR}/spoof_repeat.pid"
            while true; do
                  sleep 60
                  brene_spoof_system_properties
            done &
            echo $! > "${PERSISTENT_DIR}/spoof_repeat.pid"
            ;;
         *)
            if kill -0 "${_spoof_pid}" 2>/dev/null; then
               :
            else
               # stale numeric pid (dead process) -> start a fresh single daemon
               while true; do
                  sleep 60
                  brene_spoof_system_properties
               done &
               echo $! > "${PERSISTENT_DIR}/spoof_repeat.pid"
            fi
            ;;
      esac
      rmdir "${PERSISTENT_DIR}/spoof_repeat.pid.lock" 2>/dev/null
      trap - EXIT INT TERM
   fi
fi



## Remove the '..5.u.S' leftover ##
## THe reason why this sus file is created is because users have grant the MANAGE_EXTERNAL_STORAGE permission for the apps that detecting sus files in /sdcard, or in /sdcard/Android/data where the apps are exploiting the unicode bugs to create files arbitrary.
## susfs redirects the sus path to a supposed not-existing path named '..5.u.S', and this is the only way to settle the cross check of returned errno from various syscalls, but one disadvantage is that if the path itself can be written/created by the app (MANAGE_EXTERNAL_STORAGE granted), then it is futile to hide it, but at least here we automatically delete them on each boot.
## The best practise is to revoke MANAGE_EXTERNAL_STORAGE permission for all third party apps.
# [ -e "/sdcard/..5.u.S" ] && rm -rf "/sdcard/..5.u.S"
# [ -e "/sdcard/Android/data/..5.u.S" ] && rm -rf "/sdcard/Android/data/..5.u.S"
# [ -e "/sdcard/Android/media/..5.u.S" ] && rm -rf "/sdcard/Android/media/..5.u.S"

# Remove "..5.u.S"
TARGET="..5.u.S"
TARGET1="/sdcard/${TARGET}"
TARGET2="/sdcard/Android/data/${TARGET}"
TARGET3="/sdcard/Android/media/${TARGET}"
TARGET4="/sdcard/Android/obb/${TARGET}"
for t in "${TARGET1}" "${TARGET2}" "${TARGET3}" "${TARGET4}"; do
	if [[ -L "$t" ]]; then rm -f -- "$t"; continue; fi
	rm -rf -- "$t"
done
pgrep -x inotifyd >/dev/null 2>&1 || inotifyd "${MODDIR}/inotify.sh" /sdcard:n &

## For paths that are frequently modified, we can add them via 'add_sus_path_loop' ##
## Be reminded that without HMA's vold app data enabled, added sus_paths are still vulnerable to zwc exploit, so in this case users also have to add its underlying path as well ##

# Suspicious Paths Hiding

# Non-standard /sdcard
__brene_hide_nonstandard_sdcard_once() {
	local _hide_n=0 _seen=0
	local pass i x
	local standard_paths
	if [[ -z "$(resetprop ro.miui.ui.version.name)" ]]; then
		standard_paths="Alarms Android Audiobooks DCIM Documents Download Movies Music Notifications Pictures Podcasts Recordings Ringtones"
	else
		standard_paths="Alarms Android Audiobooks DCIM Documents Download Movies Music Notifications Pictures Podcasts Recordings Ringtones MIUI"
	fi

	# POSIX nullglob emulation inside function scope (set -- is local to functions):
	# an unmatched glob stays literal, so detect and drop it.
	set -- /sdcard/*
	if [ "$#" -eq 1 ] && [ ! -e "$1" ]; then set --; fi
	_seen=$#
	for i in "$@"; do
		if [ ! -e "${i}" ]; then
			[ "${config_brene_logs}" = "1" ] && brene_log "[skip] vanished/denied: ${i}"
			continue
		fi
		pass=0
		for x in ${standard_paths}; do
			if [[ "/sdcard/${x}" == "${i}" ]]; then
				pass=1
				break
			fi
		done

		[[ "${pass}" == "1" ]] && continue

		brene_sus_path_loop "${i}" && _hide_n=$((_hide_n + 1))
	done
	if [ "${_hide_n}" -eq 0 ] && [ "${config_brene_logs}" = "1" ]; then
		brene_log "[skip] /sdcard pass added 0 entries (empty listing or all standard), entries_seen=${_seen}"
	fi
}
if [[ "${config_paths_hiding__non_standard_sdcard}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
			brene_log ""
			brene_log "####################"
			brene_log "Non-standard /sdcard"
			brene_log "####################"
	fi

	if ! brene_wait_for_nonempty_listing "/sdcard" 15 && [[ "${config_brene_logs}" == "1" ]]; then
		brene_log "[wait] /sdcard listing still empty after ~30s, attempting once anyway"
	fi
	__brene_hide_nonstandard_sdcard_once
fi

# Non-standard /sdcard/Android
__brene_hide_nonstandard_sdcard_android_once() {
	local _hide_n=0 _seen=0
	local pass i x
	local standard_paths
	standard_paths="data media obb"
	set -- /sdcard/Android/*
	if [ "$#" -eq 1 ] && [ ! -e "$1" ]; then set --; fi
	_seen=$#
	for i in "$@"; do
		if [ ! -e "${i}" ]; then
			[ "${config_brene_logs}" = "1" ] && brene_log "[skip] vanished/denied: ${i}"
			continue
		fi
		pass=0
		for x in ${standard_paths}; do
			if [[ "/sdcard/Android/${x}" == "${i}" ]]; then
				pass=1
				break
			fi
		done

		[[ "${pass}" == "1" ]] && continue

		brene_sus_path_loop "${i}" && _hide_n=$((_hide_n + 1))
	done
	if [ "${_hide_n}" -eq 0 ] && [ "${config_brene_logs}" = "1" ]; then
		brene_log "[skip] /sdcard/Android pass added 0 entries, entries_seen=${_seen}"
	fi
}
if [[ "${config_paths_hiding__non_standard_sdcard_android}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
			brene_log ""
			brene_log "############################"
			brene_log "Non-standard /sdcard/Android"
			brene_log "############################"
	fi

	if ! brene_wait_for_nonempty_listing "/sdcard/Android" 15 && [[ "${config_brene_logs}" == "1" ]]; then
		brene_log "[wait] /sdcard/Android listing still empty after ~30s, attempting once anyway"
	fi
	__brene_hide_nonstandard_sdcard_android_once
fi

# Late second pass: storage often populates after boot-completed. Same functions,
# same allowlists — idempotent retry only. Backgrounded so boot is never blocked.
# NOTE: [b] self-match pattern won't match an attacker argv containing the plain
# string; rc=127 (no pgrep) or other errors -> single safe pass only, never a respawn loop.
if pgrep -f "[b]rene_hide_nonstandard_sdcard" >/dev/null 2>&1; then
   :
else
   _pgrep_rc=$?
   if [[ "${_pgrep_rc}" -eq 1 || "${_pgrep_rc}" -eq 127 ]]; then
      ( sleep 60
        [[ "${config_paths_hiding__non_standard_sdcard}" == "1" ]] && __brene_hide_nonstandard_sdcard_once
        [[ "${config_paths_hiding__non_standard_sdcard_android}" == "1" ]] && __brene_hide_nonstandard_sdcard_android_once
        [[ "${config_brene_logs}" == "1" ]] && brene_log "[retry] late sdcard hide pass done"
      ) &
   fi
fi

# Hide Custom Recovery Paths
if [[ "${config_hide_custom_recovery}" == "1" ]]; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                        brene_log ""
                        brene_log "########################"
                        brene_log "Hide Custom Recovery Paths"
                        brene_log "########################"
        fi

        [[ -e "/storage/emulated/0/Fox" ]] && brene_sus_path_loop "/storage/emulated/0/Fox"
        [[ -e "/storage/emulated/0/TWRP" ]] && brene_sus_path_loop "/storage/emulated/0/TWRP"
        [[ -e "/data/recovery" ]] && brene_sus_path_loop "/data/recovery"
        [[ -e "/cache/recovery" ]] && brene_sus_path_loop "/cache/recovery"
        [[ -e "/data/cache/recovery" ]] && brene_sus_path_loop "/data/cache/recovery"
        [[ -e "/vendor/bin/install-recovery.sh" ]] && brene_sus_path_loop "/vendor/bin/install-recovery.sh"
        [[ -e "/system/bin/install-recovery.sh" ]] && brene_sus_path_loop "/system/bin/install-recovery.sh"
        [[ -e "/storage/emulated/0/OrangeFox" ]] && brene_sus_path_loop "/storage/emulated/0/OrangeFox"
        [[ -e "/storage/emulated/0/PitchBlack" ]] && brene_sus_path_loop "/storage/emulated/0/PitchBlack"
        [[ -e "/storage/emulated/0/PBRP" ]] && brene_sus_path_loop "/storage/emulated/0/PBRP"
        [[ -e "/storage/emulated/0/SHRP" ]] && brene_sus_path_loop "/storage/emulated/0/SHRP"
        [[ -e "/storage/emulated/0/RedWolf" ]] && brene_sus_path_loop "/storage/emulated/0/RedWolf"
        [[ -e "/storage/emulated/0/.twrps" ]] && brene_sus_path_loop "/storage/emulated/0/.twrps"
        [[ -e "/storage/emulated/0/OFox" ]] && brene_sus_path_loop "/storage/emulated/0/OFox"
        [[ -e "/data/media/0/TWRP" ]] && brene_sus_path_loop "/data/media/0/TWRP"
        [[ -e "/data/media/0/Fox" ]] && brene_sus_path_loop "/data/media/0/Fox"
        [[ -e "/persist/ofrp" ]] && brene_sus_path_loop "/persist/ofrp"
        [[ -e "/data/ofrp" ]] && brene_sus_path_loop "/data/ofrp"
        [[ -e "/metadata/ofrp" ]] && brene_sus_path_loop "/metadata/ofrp"
        [[ -e "/system_ext/bin/install-recovery.sh" ]] && brene_sus_path "/system_ext/bin/install-recovery.sh"
        [[ -e "/vendor/etc/install-recovery.sh" ]] && brene_sus_path "/vendor/etc/install-recovery.sh"
        [[ -e "/system/etc/install-recovery.sh" ]] && brene_sus_path "/system/etc/install-recovery.sh"

        resetprop | awk -F'[][]' '{print $2}' | grep -iE "twrp|ofrp|pbrp|shrp|ro\.fox\." | grep -E '^[a-zA-Z0-9_.-]+$' | while IFS= read -r prop; do
                resetprop -d "${prop}"
        done
fi

# /data/local/tmp
if [[ "${config_paths_hiding__data_local_tmp}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
			brene_log ""
			brene_log "###############"
			brene_log "/data/local/tmp"
			brene_log "###############"
	fi

	for i in /data/local/tmp/*; do
		[[ -e "${i}" ]] || continue
		brene_sus_path_loop "${i}"
	done
fi

# Fix /data/local/tmp Inconsistencies
if [[ "${config_fix_data_local_tmp_inconsistencies}" == "1" ]]; then
        target_folder="/data/local/tmp"
        if [ ! -L "${target_folder}" ]; then
        mkdir -p "${target_folder}"
        chmod 0771 "${target_folder}"
        chown shell:shell "${target_folder}"
        chcon u:object_r:shell_data_file:s0 "${target_folder}"
        # add_sus_kstat_statically </path/of/file_or_directory> <ino> <dev> <nlink> <size> <atime> <atime_nsec> <mtime> <mtime_nsec> <ctime> <ctime_nsec> <blocks> <blksize>
        # ino -> %i, dev -> %d, nlink -> %h, atime -> %X, mtime -> %Y, ctime -> %Z, size -> %s, blocks -> %b, blksize -> %B
        # Example: stat -c %i <path>
        ${SUSFS_BIN} add_sus_kstat_statically "${target_folder}" '100' 'default' 'default' '4096' 'default' 'default' 'default' 'default' 'default' 'default' '8' '4096' 2>/dev/null || true
        fi
fi

# Manually-installed User CA Certificates
if [[ "${config_paths_hiding__user_ca_certs}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
			brene_log ""
			brene_log "###############################"
			brene_log "User CA Certificates"
			brene_log "###############################"
	fi

        for i in /data/misc/user/*/cacerts-added/*; do
                [[ -e "${i}" ]] || continue
		brene_sus_path_loop "${i}"
	done

	for d in /data/misc/user/*/cacerts-added; do
		brene_sus_kstat_static "${d}"
	done
fi

# /sdcard/Android/[data | media | obb]
if [[ "${config_paths_hiding__sdcard_android_data_media_obb}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
			brene_log ""
			brene_log "####################################"
			brene_log "/sdcard/Android/[data | media | obb]"
			brene_log "####################################"
	fi

	packages="
	io.github.muntashirakon.AppManager
	com.github.capntrips.kernelflasher
	com.machiav3lli.backup
	"

	for i in ${packages}; do
		path1=/sdcard/Android
		full_path1="${path1}/data/${i}"
		full_path2="${path1}/media/${i}"
		full_path3="${path1}/obb/${i}"
		[[ -e "${full_path1}" ]] && brene_sus_path_loop "${full_path1}"
		[[ -e "${full_path2}" ]] && brene_sus_path_loop "${full_path2}"
		[[ -e "${full_path3}" ]] && brene_sus_path_loop "${full_path3}"
	done

	# path1=/sdcard/Android/data
	# path2=/sdcard/Android/media
	# path3=/sdcard/Android/obb
	# for i in $(pm list packages -3 | cut -d':' -f2); do
	# 	full_path1="${path1}/${i}"
	# 	full_path2="${path2}/${i}"
	# 	full_path3="${path3}/${i}"
	# 	[[ -e "${full_path1}" ]] && brene_sus_path_loop "${full_path1}"
	# 	[[ -e "${full_path2}" ]] && brene_sus_path_loop "${full_path2}"
	# 	[[ -e "${full_path3}" ]] && brene_sus_path_loop "${full_path3}"
	# done
fi

## For paths that are read-only all the time, add them via 'add_sus_path' ##
if [[ "${config_brene_logs}" == "1" ]]; then
		brene_log ""
		brene_log "#############################"
		brene_log "Other Suspicious Paths Hiding"
		brene_log "#############################"
fi
# brene_sus_path "/sys/block/loop0"

# Load custom_sus_map.txt (validated: absolute path only, flags rejected,
# empty/comment skipped, missing warned; fail-safe per line)
if [[ -e "${PERSISTENT_DIR}/custom_sus_map.txt" ]]; then
	while IFS= read -r i || [[ -n "${i}" ]]; do
		__brene_cleaned=$(__brene_clean_hide_path "${i}"); __brene_clean_rc=$?
		case "${__brene_clean_rc}" in 0|3) brene_sus_map "${__brene_cleaned}" || true ;; esac
	done < "${PERSISTENT_DIR}/custom_sus_map.txt"
fi

# Load custom_sus_path.txt (validated; same rules as custom_sus_map.txt)
if [[ -e "${PERSISTENT_DIR}/custom_sus_path.txt" ]]; then
	while IFS= read -r i || [[ -n "${i}" ]]; do
		__brene_cleaned=$(__brene_clean_hide_path "${i}"); __brene_clean_rc=$?
		case "${__brene_clean_rc}" in 0|3) brene_sus_path "${__brene_cleaned}" || true ;; esac
	done < "${PERSISTENT_DIR}/custom_sus_path.txt"
fi

# Load custom_sus_path_loop.txt (validated; same rules as custom_sus_map.txt)
if [[ -e "${PERSISTENT_DIR}/custom_sus_path_loop.txt" ]]; then
	while IFS= read -r i || [[ -n "${i}" ]]; do
		# Validated above: absolute path only, flags rejected, missing warned
		__brene_cleaned=$(__brene_clean_hide_path "${i}"); __brene_clean_rc=$?
		case "${__brene_clean_rc}" in 0|3) brene_sus_path_loop "${__brene_cleaned}" || true ;; esac
	done < "${PERSISTENT_DIR}/custom_sus_path_loop.txt"
fi

# Load custom_sus_mount.txt (validated; same rules as custom_sus_map.txt)
if [[ -e "${PERSISTENT_DIR}/custom_sus_mount.txt" ]]; then
	while IFS= read -r i || [[ -n "${i}" ]]; do
		__brene_cleaned=$(__brene_clean_hide_path "${i}"); __brene_clean_rc=$?
		case "${__brene_clean_rc}" in 0|3) brene_sus_mount "${__brene_cleaned}" || true ;; esac
	done < "${PERSISTENT_DIR}/custom_sus_mount.txt"
fi

# Load custom_kernel_umount.txt (validated; same rules as custom_sus_map.txt)
if [[ -e "${PERSISTENT_DIR}/custom_kernel_umount.txt" ]]; then
        while IFS= read -r i || [[ -n "${i}" ]]; do
                __brene_cleaned=$(__brene_clean_hide_path "${i}"); __brene_clean_rc=$?
                case "${__brene_clean_rc}" in 0|3) brene_kernel_umount "${__brene_cleaned}" || true ;; esac
        done < "${PERSISTENT_DIR}/custom_kernel_umount.txt"
fi

#### Hide the mmapped real file from various maps in /proc/self/, effective only for processes that are marked umounted with uid >= 10000 ####
## - *Please note that it is better to do it in boot-completed starge
##   Since some target path may be mounted by ksu, and make sure the
##   target path has the same dev number as the one in global mnt ns,
##   otherwise the sus map flag won't be seen on the umounted proocess.
## - *Besides, if the source files get umounted and stay only in like zygote's memory maps,
##   then it will not work as well since sus_map checks for real file's inode.
## - To debug the namespace issue, users can do this in a root shell:
##   1. Find the pid and uid of a opened umounted app by running
##      ps -enf | grep myapp
##   2. cat /proc/<pid_of_myapp>/maps | grep "<added/sus_map/path>"'
##   3. In other root shell, run
##      cat /proc/1/mountinfo | grep "<added/sus_map/path>"'
##   4. Finally compare the dev number with both output and see if they are consistent,
##      if so, then it should be working, but if not, then the added sus_map path
##      is probably not working, and you have to find out which mnt ns the dev number
##      from step 2 belongs to, and add the path from that mnt ns:
##         busybox nsenter -t <pid_of_mnt_ns_the_target_dev_number_belongs_to> -m ksu_susfs add_sus_map <target_path>
## Hide some zygisk modules ##
# brene_sus_map /data/adb/modules/my_module/zygisk/arm64-v8a.so

# Injections Hiding
if [[ "${config_hide_injections}" == "1" ]]; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                        brene_log ""
                        brene_log "#################"
                        brene_log "Injections Hiding"
                        brene_log "#################"
        fi

        overlayfs="/data/adb/modules/meta-overlayfs/mnt"
        magic_mount="/data/adb/modules"
        [[ -e "${overlayfs}" ]] && path="${overlayfs}" || path="${magic_mount}"

        for module in "${path}"/*; do
                if [[ -e "${module}/system" ]]; then
                        brene_find "${module}/system" -type f -print0 | while IFS= read -r -d '' file; do
                                brene_sus_map "${file}" || true
                        done
                fi
        done

        brene_find /data/adb/modules -name "*.so" -print0 | while IFS= read -r -d '' file; do
                brene_sus_map "${file}" || true
        done
fi

#### Adding sus mounts to umount list via built-in KernelSU kernel umount (not via add_try_umount from old susfs) ####
# cat <<EOF >/dev/null
# ## Don't forget to notify KernelSU that all ksu modules all mounted and ready ##
# /data/adb/ksu/bin/ksud kernel notify-module-mounted

# ## This is just an example to add the sus mounts to kernel umount ##
# if [ ! -f "/data/adb/susfs_no_auto_add_kernel_umount" ]; then
# 	cat /proc/1/mountinfo | grep -E "^2[0-9]{9,} .*$|KSU" | awk '{print $5}' | while read -r LINE; do /data/adb/ksu/bin/ksud kernel umount add --flags 2 "${LINE}" 2>/dev/null; done
# fi
# EOF

#### Adding sus mounts to umount list via built-in KernelSU kernel umount (not via add_try_umount from old susfs) ####
# Umount Suspicious Mounts
if [[ "${config_umount_suspicious_mounts}" == "1" ]]; then
	## Don't forget to notify KernelSU that all ksu modules all mounted and ready ##
	${KSU_BIN} kernel notify-module-mounted 2>/dev/null || true

	cat /proc/1/mountinfo | grep -E "^2[0-9]{9,} .*$|KSU" | awk '{print $5}' | sed -e 's/\\040/ /g' -e 's/\\011/	/g' -e 's/\\134/\\/g' | while IFS= read -r mount; do
		# \012 (newline) cannot survive a line-based loop: skip honestly instead of corrupting the path
		case "${mount}" in
			*\\012*)
				[[ "${config_brene_logs}" == "1" ]] && brene_log "[skip] mountpoint contains newline escape (\\012): ${mount}"
				continue
				;;
		esac
		if [[ -z "${mount}" ]]; then
			[[ "${config_brene_logs}" == "1" ]] && brene_log "[decode] FAILED (empty mountpoint after unescape), skipping"
			continue
		fi
		${KSU_BIN} kernel umount add -f 2 -- "${mount}" 2>/dev/null || true
	done
fi

# Hide framework-res.apk
if [[ "${config_hide_framework_res_apk}" == "1" ]]; then
	brene_find /system -iname "*framework-res.apk" -print0 | while IFS= read -r -d '' path; do
		brene_sus_map "${path}" || true
	done
fi



# Android Verified Boot Hash Spoofing
if [[ "${config_spoof_verified_boot_hash}" != '' ]]; then
	case "${config_spoof_verified_boot_hash}" in
		*[!0-9a-fA-F]*|"") ;;
		*) [ "${#config_spoof_verified_boot_hash}" -eq 64 ] && resetprop_n "ro.boot.vbmeta.digest" "${config_spoof_verified_boot_hash}" ;;
	esac
fi

resetprop -c --force 2>/dev/null || true

if [[ "${config_brene_logs}" == "1" ]]; then
	echo "boot-completed.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi
