#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

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
    # Trim spaces around the pair: a hand-edited "key = value" line must not be
    # dropped by the allowlist below (it strips anything outside [A-Za-z0-9_]).
    k=${k#"${k%%[![:space:]]*}"}; k=${k%"${k##*[![:space:]]}"}
    v=${v#"${v%%[![:space:]]*}"}; v=${v%"${v##*[![:space:]]}"}
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
      config_hide_ksu_directories) config_hide_ksu_directories="$v" ;;
      config_hide_third_party_apps) config_hide_third_party_apps="$v" ;;
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
mkdir -p "${PERSISTENT_DIR}"

if [[ "${config_brene_logs}" == "1" ]]; then
        echo "service.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi

# Fingerprint tail re-check: the spoofed fingerprint is final by now. It rides
# on the Spoof System Properties toggle instead of a key of its own. A
# mismatched ro.build.id vs the fingerprint is an integrity signal.
if [[ "${config_spoof_system_properties}" == "1" ]]; then
        brene_align_fingerprint_tail "Fingerprint Tail (recheck)" || true
fi

# Best-effort update for custom kstat entries at a later stage.
# Mapping (see brene_kstat_update_line in utils.sh):
#   normal (bare path) -> update_sus_kstat
#   full_clone (fullclone:/path) -> update_sus_kstat_full_clone
#   static (13-field line) -> update_sus_kstat (completes the static add
#     after mounts are up, per susfs docs; same as brene_sus_kstat_static)
# Every outcome is logged as [custom_sus_kstat:update*]: OK / FAILED rc=N.
# Skip the whole stage when the list has no real line (comments/blank only).
if [[ -e "${PERSISTENT_DIR}/custom_sus_kstat.txt" ]] && grep -qEv '^[[:space:]]*(#|$)' "${PERSISTENT_DIR}/custom_sus_kstat.txt"; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                        brene_log ""
                        brene_log "########################"
                        brene_log "Custom KSTAT (late update)"
                        brene_log "########################"
        fi
        while IFS= read -r i || [[ -n "${i}" ]]; do
                brene_kstat_update_line "${i}" || true
        done < "${PERSISTENT_DIR}/custom_sus_kstat.txt"
fi

# The manager does not run boot-completed.sh on every ROM/boot, so apply the
# getpriority uid filter here too: wait for boot to complete, then let
# apply_uid_filter.sh build the list (PackageManager is ready by then).
if [ "${config_hide_third_party_apps}" = "1" ] && [ -f "${MODDIR}/apply_uid_filter.sh" ]; then
	(
		i=0
		while [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ] && [ "$i" -lt 150 ]; do
			sleep 2
			i=$((i + 1))
		done
		[ "$i" -lt 150 ] || exit 0
		sleep 5
		config_brene_logs="${config_brene_logs}" sh "${MODDIR}/apply_uid_filter.sh"
	) >/dev/null 2>&1 &
fi
