#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin
mkdir -p "${PERSISTENT_DIR}"
[[ -x "${SUSFS_BIN}" ]] || { echo "[!] susfs missing" >> "${PERSISTENT_DIR}/log.txt" 2>/dev/null || true; }
SUSFS_VARIANT=$(${SUSFS_BIN} show variant 2>/dev/null)
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
    # Escape single quotes for safe eval (single-quoted assignment = no expansion)
    v_esc=$(printf '%s' "$v" | sed "s/'/'\\\\''/g")
    eval "$k='$v_esc'"
  done < "${PERSISTENT_DIR}/config.sh"
fi

mkdir -p "${PERSISTENT_DIR}"
# Clear logs
true > "${PERSISTENT_DIR}/log.txt"
true > "${PERSISTENT_DIR}/logs.txt"

## Important Notes:
## - The following command can be run at other stages like service.sh, boot-completed.sh etc..,
## - This module is just an demo showing how to use ksu_susfs tool to commuicate with kernel
##

#### Spoof the stat of file/directory dynamically, effective only for processes that are marked umounted with uid >= 10000 ####
## Important Note:
##  - It is stronly suggested to use dynamically if the target path will be mounted
# cat <<EOF >/dev/null
# # First, clone the permission before adding to sus_kstat
# brene_clone_perm "$MODDIR/hosts" /system/etc/hosts

# # Second, before bind mount your file/directory, use 'add_sus_kstat' to add the path #
# ${SUSFS_BIN} add_sus_kstat '/system/etc/hosts'

# # Now bind mount or overlay your path #
# mount -o bind "$MODDIR/hosts" /system/etc/hosts

# # Finally use 'update_sus_kstat' to update the path again for the changed ino and device number #
# # update_sus_kstat updates ino, but blocks and size are remained the same as current stat #
# ${SUSFS_BIN} update_sus_kstat '/system/etc/hosts'

# # Or if you want to fully clone the stat value from the original stat, use update_sus_kstat_full_clone instead #
# #${SUSFS_BIN} update_sus_kstat_full_clone '/system/etc/hosts'
# EOF

#### Spoof the stat of file/directory statically, effective only for processes that are marked umounted with uid >= 10000 ####
## Important Note:
##  - It is suggested to use statically if you don't need to mount anything but simply change the stat of a target path
# cat <<EOF >/dev/null
# Usage: ksu_susfs add_sus_kstat_statically </path/of/file_or_directory> \
#                         <ino> <dev> <nlink> <size> <atime> <atime_nsec> <mtime> <mtime_nsec> <ctime> <ctime_nsec> \
#                         <blocks> <blksize>
# ${SUSFS_BIN} add_sus_kstat_statically '/system/framework/services.jar' 'default' 'default' 'default' 'default' '1230768000' '0' '1230768000' '0' '1230768000' '0' 'default' 'default'
# EOF

#### Redirect opened target path to user-defined path ####
# Please be reminded the following #
# 1. Both target_pathname and redirected_pathname must be existed before they can be added to kernel.
# 2. Users have to take care of the selinux permission for both target_pathname and redirected_pathname by themselves first.
## Set the permission of the redirected path first ##
# brene_clone_perm '/data/local/tmp/my_hosts' '/system/etc/hosts'
## Now add the target path and redirected path with pre-defined uid scheme to kernel ##
## *Run 'ksu_susfs add_open_redirect' for more details of <uid_scheme> ##
# ${SUSFS_BIN} add_open_redirect '/system/etc/hosts' '/data/local/tmp/my_hosts' '0'



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

        brene_clone_perm "${fake_file_path}" "${path}"

        ${SUSFS_BIN} add_open_redirect "${path}" "${fake_file_path}" '3'
fi

#### Spoof /proc/cmdline or /proc/bootconfig, effective for all processes ####
# No root process detects it for now, and this spoofing won't help much actually #
# /proc/bootconfig #
# cat <<EOF >/dev/null
# FAKE_BOOTCONFIG=${MODDIR}/fake_bootconfig.txt
# cat /proc/bootconfig > ./fake_bootconfig.txt
# sed -i 's/^androidboot.bootreason.*$/androidboot.bootreason = "reboot"/g' ${FAKE_BOOTCONFIG}
# sed -i 's/^androidboot.vbmeta.device_state.*$/androidboot.vbmeta.device_state = "locked"/g' ${FAKE_BOOTCONFIG}
# sed -i 's/^androidboot.verifiedbootstate.*$/androidboot.verifiedbootstate = "green"/g' ${FAKE_BOOTCONFIG}
# sed -i '/androidboot.verifiedbooterror/d' ${FAKE_BOOTCONFIG}
# sed -i '/androidboot.verifyerrorpart/d' ${FAKE_BOOTCONFIG}
# ${SUSFS_BIN} set_cmdline_or_bootconfig ${FAKE_BOOTCONFIG}
# EOF

# /proc/cmdline #
# cat <<EOF >/dev/null
# FAKE_PROC_CMDLINE_FILE=${MODDIR}/fake_proc_cmdline.txt
# cat /proc/cmdline > ${FAKE_PROC_CMDLINE_FILE}
# sed -i 's/androidboot.verifiedbootstate=orange/androidboot.verifiedbootstate=green/g' ${FAKE_PROC_CMDLINE_FILE}
# sed -i 's/androidboot.vbmeta.device_state=unlocked/androidboot.vbmeta.device_state=locked/g' ${FAKE_PROC_CMDLINE_FILE}
# ${SUSFS_BIN} set_cmdline_or_bootconfig ${FAKE_PROC_CMDLINE_FILE}
# EOF

if [[ "${config_spoof_cmdline_or_bootconfig}" == "1" ]]; then

	if [[ "${SUSFS_VARIANT}" == "GKI" ]]; then
		FAKE_BOOTCONFIG="${PERSISTENT_DIR}/fake_bootconfig"
		[ -L "${FAKE_BOOTCONFIG}" ] && rm -f -- "${FAKE_BOOTCONFIG}"

		cat /proc/bootconfig > "${FAKE_BOOTCONFIG}"
		sed -i 's/androidboot.warranty_bit = "1"/androidboot.warranty_bit = "0"/' "${FAKE_BOOTCONFIG}"
		sed -i 's/androidboot.verifiedbootstate = "orange"/androidboot.verifiedbootstate = "green"/' "${FAKE_BOOTCONFIG}"
		if [[ -s "${FAKE_BOOTCONFIG}" ]]; then
			${SUSFS_BIN} set_cmdline_or_bootconfig "${FAKE_BOOTCONFIG}"
		elif [[ "${config_brene_logs}" == "1" ]]; then
			echo "[cmdline_or_bootconfig] SKIPPED (empty FAKE_BOOTCONFIG)" >> "${PERSISTENT_DIR}/logs.txt"
		fi
	else
		FAKE_CMDLINE="${PERSISTENT_DIR}/fake_cmdline"
		[ -L "${FAKE_CMDLINE}" ] && rm -f -- "${FAKE_CMDLINE}"

		cat /proc/cmdline > "${FAKE_CMDLINE}"
		sed -i 's/androidboot.warranty_bit=1/androidboot.warranty_bit=0/' "${FAKE_CMDLINE}"
		sed -i 's/androidboot.verifiedbootstate=orange/androidboot.verifiedbootstate=green/' "${FAKE_CMDLINE}"
		if [[ -s "${FAKE_CMDLINE}" ]]; then
			${SUSFS_BIN} set_cmdline_or_bootconfig "${FAKE_CMDLINE}"
		elif [[ "${config_brene_logs}" == "1" ]]; then
			echo "[cmdline_or_bootconfig] SKIPPED (empty FAKE_CMDLINE)" >> "${PERSISTENT_DIR}/logs.txt"
		fi
	fi
fi

#### Hiding the exposed /proc interface of ext4 loop and jdb2 when mounting ext4 img using sus_path ####
# if [[ $config_hide_modules_img == 1 ]]; then
## Hide all sus ext4 loops and jbd2 journals if they are still mounted and with jdb2 journal enabled ##
# 	for device in $(ls -Ld /proc/fs/jbd2/loop*8 | sed 's|/proc/fs/jbd2/||; s|-8||'); do
# 		brene_sus_path /proc/fs/jbd2/${device}-8
# 		brene_sus_path /proc/fs/ext4/${device}
# 	done
## Also we need to spoof the nlink of /proc/fs/jbd2 to 2 ##
# ${SUSFS_BIN} add_sus_kstat_statically '/proc/fs/jbd2' 'default' 'default' '2' 'default' 'default' 'default' 'default' 'default' 'default' 'default' 'default' 'default'
# fi

#### Enable avc log spoofing to bypass 'su' domain detection via /proc/<pid> enumeration, effective for all processes ####
## disable it when users want to do some debugging with the permission issue or selinux issue ##
#ksu_susfs enable_avc_log_spoofing 0
if [[ "${config_enable_avc_log_spoofing}" == "1" ]]; then
	${SUSFS_BIN} enable_avc_log_spoofing 1
fi

#### Hide all sus mounts for NON-SU processes in this stage just to prevent zygote from caching them in memory ####
## This should be mainly applied if you have ReZygisk enabled but without TreatWheel module ##
## Or it is up to you to keep it enabled since su process can still see the mounts ##
if [[ "${config_hide_sus_mnts_for_non_su_procs}" == "1" ]]; then
	${SUSFS_BIN} hide_sus_mnts_for_non_su_procs 1
fi

# Uname Spoofing
#### Spoof the uname, effective for all processes ####
# You can get your uname args by running 'uname {-r|-v}' on your stock ROM.
# pass 'default' to tell susfs to use the default value by uname.
# ${SUSFS_BIN} set_uname 'default' 'default'

# Custom Uname has priority over Automatic Uname.
if [[ "${config_custom_uname_spoofing}" == "1" ]]; then

if [[ "${config_brene_logs}" == "1" ]]; then
                {
                        echo ""
                        echo "#####################"
                        echo "Custom Uname Spoofing"
                        echo "#####################"
                } >> "${PERSISTENT_DIR}/logs.txt"
        fi

        final_uname_release="${config_custom_uname_kernel_release}"
        final_uname_version="${config_custom_uname_kernel_version}"

        # Shell-side allowlist (config.sh is sourced; hand edits must not become code exec).
        # Release: default or [A-Za-z0-9._+~-] ; Version: default or [A-Za-z0-9 #(),.:+_~@-]
        case "${final_uname_release}" in
                default) ;;
                *[!A-Za-z0-9._+~-]*|"") final_uname_release="default" ;;
        esac
        case "${final_uname_version}" in
                default) ;;
                *[!A-Za-z0-9\ \#\(\),.:+_~@-]*|"") final_uname_version="default" ;;
        esac

        # Preserve BRENE's custom 'default' fallback behavior.
        if [[ "${final_uname_release}" == "default" || "${final_uname_version}" == "default" ]]; then
                auto_kernel_version=$(cat /proc/version | awk '{print $3}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
                auto_uname_version="#1 SMP PREEMPT $(resetprop ro.build.date | tr -s ' ')"

                if [[ -n "${auto_kernel_version}" ]]; then
                        if [[ "${SUSFS_VARIANT}" == "GKI" ]]; then
                                auto_kmi=$(${KSU_BIN} boot-info current-kmi | cut -d'-' -f1)
                                if [[ -n "${auto_kmi}" ]]; then
                                        auto_uname_release="${auto_kernel_version}-${auto_kmi}-9-g$(shuf -i 10000000-99999999 -n 1 2>/dev/null || awk 'BEGIN{srand();printf "%08d", rand()*90000000+10000000}')"
                                fi
                        else
                                auto_uname_release="${auto_kernel_version}-g$(shuf -i 10000000-99999999 -n 1 2>/dev/null || awk 'BEGIN{srand();printf "%08d", rand()*90000000+10000000}')"
                        fi

                        [[ -n "${auto_uname_release:-}" && "${final_uname_release}" == "default" ]] && final_uname_release="${auto_uname_release}"
                        [[ "${final_uname_version}" == "default" ]] && final_uname_version="${auto_uname_version}"
                fi
        fi

        brene_set_uname "${final_uname_release}" "${final_uname_version}"

elif [[ "${config_uname_spoofing}" == "1" ]]; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                {
                        echo ""
                        echo "##############"
                        echo "Uname Spoofing"
                        echo "##############"
                } >> "${PERSISTENT_DIR}/logs.txt"
        fi

        kernel_version=$(cat /proc/version | awk '{print $3}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
        uname_kernel_version="#1 SMP PREEMPT $(resetprop ro.build.date | tr -s ' ')"

        if [[ -n "${kernel_version}" ]]; then
                if [[ "${SUSFS_VARIANT}" == "GKI" ]]; then
                        kmi=$(${KSU_BIN} boot-info current-kmi | cut -d'-' -f1)
                        if [[ -n "${kmi}" ]]; then
                                uname_kernel_release="${kernel_version}-${kmi}-9-g$(shuf -i 10000000-99999999 -n 1 2>/dev/null || awk 'BEGIN{srand();printf "%08d", rand()*90000000+10000000}')"
                        fi
                else
                        uname_kernel_release="${kernel_version}-g$(shuf -i 10000000-99999999 -n 1 2>/dev/null || awk 'BEGIN{srand();printf "%08d", rand()*90000000+10000000}')"
                fi

                [[ -n "${uname_kernel_release:-}" ]] && brene_set_uname "${uname_kernel_release}" "${uname_kernel_version}"
        fi
fi

## Disable susfs kernel log ##
if [[ "${config_enable_log}" == "1" ]]; then
	${SUSFS_BIN} enable_log 1
elif [[ "${config_enable_log}" == "0" ]]; then
	${SUSFS_BIN} enable_log 0
fi

# Hide /system/addon.d Path
if [[ "${config_hide_addon_d}" == "1" ]]; then
	brene_sus_map "/system/addon.d"
    brene_sus_path_loop "/system/addon.d"
fi

# Hide Custom ROM Paths
if [[ "${config_hide_custom_rom_paths}" == "1" ]]; then
	for i in ${CUSTOM_ROM_NAMES//|/ }; do
		find /system /system_ext /vendor /product -iname "*${i}*" -print0 2>/dev/null | while IFS= read -r -d '' path; do
			brene_sus_map "${path}"
			brene_sus_path_loop "${path}"
		done

		find /data -maxdepth 1 -iname "*${i}*" -print0 2>/dev/null | while IFS= read -r -d '' path; do
			brene_sus_path_loop "${path}"
		done
	done
fi

# Hide Custom ROM Paths (Extreme)
if [[ "${config_hide_custom_rom_paths_2}" == "1" ]]; then
        for i in ${CUSTOM_ROM_NAMES//|/ }; do
                find /data/misc /data/dalvik-cache /data/resource-cache -iname "*${i}*" -print0 2>/dev/null | while IFS= read -r -d '' path; do
                        brene_sus_map "${path}"
                        brene_sus_path_loop "${path}"
                done
        done
fi
# Hide LineageOS Strings
if [[ "${config_hide_lineage_strings}" == "1" ]]; then
	find /system /system_ext /vendor /product \( -iname "*sepolicy.cil" -o -iname "*file_contexts" \) -print0 2>/dev/null | while IFS= read -r -d '' path; do
		safe="$(printf '%s' "$path" | tr '/' '_')"
		fake_file_path="${PERSISTENT_DIR}/fake_files/${safe}"

		[[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
		busybox chcon --reference="${path}" "${PERSISTENT_DIR}/fake_files" 2>/dev/null || true
		[ -L "${fake_file_path}" ] && rm -f -- "${fake_file_path}"
                if [[ ! -f "${fake_file_path}" ]]; then
                        cp "${path}" "${fake_file_path}" || continue
                        sed -i "s/lineage//g" "${fake_file_path}"
                fi

                brene_clone_perm "${fake_file_path}" "${path}"
		${SUSFS_BIN} add_open_redirect "${path}" "${fake_file_path}" '3'
	done
fi


#### Fully sync all build-related props (fingerprint + sub-fields) across all partitions ####
## Fully device-agnostic + fail-safe: never blocks boot even if resetprop errors ##
## Skipped during hot install (live session) — live resetprop of build fingerprint fields
## is unsafe while zygote/system_server are already running; it will apply normally on
## the next real reboot instead. ##
BRENE_UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
case "$BRENE_UPTIME_SEC" in ''|*[!0-9]*) BRENE_UPTIME_SEC=999;; esac
if [[ "${config_sync_device_props}" == "1" && "${BRENE_UPTIME_SEC}" -lt 120 ]]; then
    RESETPROP=""
    for candidate in /data/adb/ksu/bin/resetprop /data/adb/magisk/resetprop /data/adb/ap/bin/resetprop; do
        [[ -x "${candidate}" ]] && RESETPROP="${candidate}" && break
    done

    if [[ -n "${RESETPROP}" ]]; then
        MAIN_FP=$(getprop ro.build.fingerprint)
        MAIN_FP="${MAIN_FP//userdebug/user}"
        MAIN_FP="${MAIN_FP//evolution/}"
        MAIN_FP="${MAIN_FP//crdroid/}"
        MAIN_FP="${MAIN_FP//lineage/}"
        MAIN_ID=$(getprop ro.build.id)
        MAIN_RELEASE=$(getprop ro.build.version.release)
        MAIN_SDK=$(getprop ro.build.version.sdk)
        MAIN_SDK_FULL=$(getprop ro.build.version.sdk_full)
        MAIN_INCREMENTAL=$(getprop ro.build.version.incremental)
        MAIN_RELEASE_CODENAME=$(getprop ro.build.version.release_or_codename)
        MAIN_DATE=$(getprop ro.build.date)
        MAIN_DATE_UTC=$(getprop ro.build.date.utc)
        MAIN_SECURITY_PATCH=$(getprop ro.build.version.security_patch)
        MAIN_TAGS=$(getprop ro.build.tags)
        MAIN_TYPE=$(getprop ro.build.type)
        MAIN_BRAND=$(getprop ro.product.brand)
        MAIN_DEVICE=$(getprop ro.product.device)
        MAIN_MANUFACTURER=$(getprop ro.product.manufacturer)
        MAIN_MODEL=$(getprop ro.product.model)
        MAIN_NAME=$(getprop ro.product.name)

        FIELDS="fingerprint id version.release version.sdk version.incremental version.release_or_codename version.sdk_full date date.utc version.security_patch tags type"
        PRODUCT_FIELDS="brand device manufacturer model name"

        if [[ "${config_brene_logs}" == "1" ]]; then
            {
                echo ""
                echo "########################"
                echo "Build Props Spoofing"
                echo "########################"
            } >> "${PERSISTENT_DIR}/logs.txt"
        fi

        if [[ -n "${MAIN_FP}" ]]; then
            DISCOVERED_PARTS=$(getprop | grep -oE '^\[ro\.[a-z0-9_]+\.build\.fingerprint\]' | sed -E 's/^\[ro\.([a-z0-9_]+)\.build\.fingerprint\]$/\1/')

            for part in ${DISCOVERED_PARTS}; do
                [[ "${part}" == "build" ]] && continue
                [[ "${part}" == "bootimage" ]] && continue

                for field in ${FIELDS}; do
                    prop_name="ro.${part}.build.${field}"
                    current_value=$(getprop "${prop_name}")

                    if [[ -n "${current_value}" ]]; then
                        new_value=""
                        case "${field}" in
                            fingerprint) new_value="${MAIN_FP}" ;;
                            id) new_value="${MAIN_ID}" ;;
                            version.release) new_value="${MAIN_RELEASE}" ;;
                            version.sdk) new_value="${MAIN_SDK}" ;;
                            version.incremental) new_value="${MAIN_INCREMENTAL}" ;;
                            version.release_or_codename) new_value="${MAIN_RELEASE_CODENAME}" ;;
                            version.sdk_full) new_value="${MAIN_SDK_FULL}" ;;
                            date) new_value="${MAIN_DATE}" ;;
                            date.utc) new_value="${MAIN_DATE_UTC}" ;;
                            version.security_patch) new_value="${MAIN_SECURITY_PATCH}" ;;
                            tags) new_value="${MAIN_TAGS}" ;;
                            type) new_value="${MAIN_TYPE}" ;;
                            *) continue ;;
                        esac

                        if [[ -n "${new_value}" && "${current_value}" != "${new_value}" ]]; then
                            if timeout 3 "${RESETPROP}" "${prop_name}" "${new_value}" 2>/dev/null; then
                                if [[ "${config_brene_logs}" == "1" ]]; then
                                    echo "[sync_prop]: ${prop_name}: ${current_value} -> ${new_value}" >> "${PERSISTENT_DIR}/logs.txt"
                                fi
                            fi
                        fi
                    fi
                done

                for pfield in ${PRODUCT_FIELDS}; do
                    prop_name="ro.product.${part}.${pfield}"
                    current_value=$(getprop "${prop_name}")

                    if [[ -n "${current_value}" ]]; then
                        new_value=""
                        case "${pfield}" in
                            brand) new_value="${MAIN_BRAND}" ;;
                            device) new_value="${MAIN_DEVICE}" ;;
                            manufacturer) new_value="${MAIN_MANUFACTURER}" ;;
                            model) new_value="${MAIN_MODEL}" ;;
                            name) new_value="${MAIN_NAME}" ;;
                            *) continue ;;
                        esac

                        if [[ -n "${new_value}" && "${current_value}" != "${new_value}" ]]; then
                            if timeout 3 "${RESETPROP}" "${prop_name}" "${new_value}" 2>/dev/null; then
                                if [[ "${config_brene_logs}" == "1" ]]; then
                                    echo "[sync_prop]: ${prop_name}: ${current_value} -> ${new_value}" >> "${PERSISTENT_DIR}/logs.txt"
                                fi
                            fi
                        fi
                    fi
                done
            done
        fi
    fi
fi

# Load custom_sus_kstat.txt
# Format per line:
#   bare `/absolute/path`            : normal -> add_sus_kstat <path> (snapshot boot-time stat values)
#   bare `fullclone:/absolute/path`  : full_clone -> add_sus_kstat <path> (same cmd, full_clone mode)
#   13 fields (TAB-separated):   static -> add_sus_kstat_statically <path> <12 values>
#     <path> <ino> <dev> <nlink> <size> <atime> <atime_nsec> <mtime> <mtime_nsec> <ctime> <ctime_nsec> <blocks> <blksize>
# Use the literal word 'default' for any static field to leave it as the real current value.
# NOTE: normal-with-values entries that WebUI writes as 13 fields are applied via the static path because the file format has no mode flag.
if [[ -e "${PERSISTENT_DIR}/custom_sus_kstat.txt" ]]; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                {
                        echo ""
                        echo "########################"
                        echo "Custom KSTAT"
                        echo "########################"
                } >> "${PERSISTENT_DIR}/logs.txt"
        fi
        set -f
        while IFS= read -r i || [[ -n "${i}" ]]; do
                # Strip CR; skip empty/whitespace-only lines or comments (leading space or TAB allowed)
                i="${i%$'\r'}"
                trimmed="$(printf '%s' "${i}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
                [[ -z "${trimmed}" || "${trimmed}" == "#"* ]] && continue

                OLDIFS="${IFS}"
                IFS=$'\t'
                set -- ${i}
                IFS="${OLDIFS}"

                if [[ "$#" -eq 1 ]]; then
                        case "$1" in
                                fullclone:/*)
                                        _kstat_path="${1#fullclone:}"
                                        if [[ ! -e "${_kstat_path}" ]]; then
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (not found): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                continue
                                        fi
                                        if kstat_err="$(${SUSFS_BIN} add_sus_kstat "${_kstat_path}" 2>&1)"; then
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:fullclone]: OK: ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                        else
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:fullclone] FAILED (${kstat_err:-exit $?}): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                        fi ;;
                                /*)
                                        # Legacy fallback: old hand-edited static lines used spaces, not TABs.
                                        # If the single TAB-field splits into 13 whitespace parts with an
                                        # absolute path first, treat it as static (matches WebUI loader).
                                        _ws_count=$(set -f; set -- $1; echo "$#")
                                        if [[ "${_ws_count}" -eq 13 ]]; then
                                                set -f; set -- $1
                                                if [[ ! -e "$1" ]]; then
                                                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (not found): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                        continue
                                                fi
                                                if kstat_err="$(${SUSFS_BIN} add_sus_kstat_statically "$@" 2>&1)"; then
                                                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:static]: OK (legacy space-separated): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                else
                                                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:static] FAILED (${kstat_err:-exit $?}): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                fi
                                        else
                                                if [[ ! -e "$1" ]]; then
                                                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (not found): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                        continue
                                                fi
                                                if kstat_err="$(${SUSFS_BIN} add_sus_kstat "$1" 2>&1)"; then
                                                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:normal]: OK: ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                else
                                                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:normal] FAILED (${kstat_err:-exit $?}): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                fi
                                        fi ;;
                                *) [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (not absolute path): ${i}" >> "${PERSISTENT_DIR}/logs.txt" ;;
                        esac
                elif [[ "$#" -eq 13 ]]; then
                        case "$1" in
                                /*)
                                        if [[ ! -e "$1" ]]; then
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (not found): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                                continue
                                        fi
                                        if kstat_err="$(${SUSFS_BIN} add_sus_kstat_statically "$@" 2>&1)"; then
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:static]: OK: ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                        else
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:static] FAILED (${kstat_err:-exit $?}): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                        fi ;;
                                *) [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (not absolute path): ${i}" >> "${PERSISTENT_DIR}/logs.txt" ;;
                        esac
                else
                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat] SKIPPED (expected 1 or 13 fields, got $#): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                fi
        done < "${PERSISTENT_DIR}/custom_sus_kstat.txt"
        set +f

fi

# Load custom_open_redirect.txt
# Format per line (TAB-separated): <src><TAB><dst><TAB><uid_scheme>
# Example: /system/etc/hosts<TAB>/data/adb/brene/fake_files/hosts<TAB>3
# uid_scheme: 0 non-app (uid<10000), 1 non-su uid 0, 2 non-su,
#             3 umounted uid>=10000 (default), 4 umounted
# NOTE: dst is NOT auto-created and SELinux is NOT auto-fixed here;
# both paths must already exist (see brene_open_redirect in utils.sh).
if [[ -e "${PERSISTENT_DIR}/custom_open_redirect.txt" ]]; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                {
                        echo ""
                        echo "########################"
                        echo "Custom OPEN REDIRECT"
                        echo "########################"
                } >> "${PERSISTENT_DIR}/logs.txt"
        fi
        set -f
        while IFS= read -r i || [[ -n "${i}" ]]; do
                # Strip CR; skip empty/whitespace-only lines or comments (leading space or TAB allowed)
                i="${i%$'\r'}"
                trimmed="$(printf '%s' "${i}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
                [[ -z "${trimmed}" || "${trimmed}" == "#"* ]] && continue

                OLDIFS="${IFS}"
                IFS=$'\t'
                set -- ${i}
                IFS="${OLDIFS}"

                if [[ "$#" -eq 3 ]]; then
                        # brene_open_redirect logs FAILED itself; log success here like the kstat loader.
                        if brene_open_redirect "$1" "$2" "$3"; then
                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_open_redirect]: ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                        fi
                else
                        [[ "${config_brene_logs}" == "1" ]] && echo "[custom_open_redirect] SKIPPED (expected 3 TAB-separated fields, got $#): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                fi
        done < "${PERSISTENT_DIR}/custom_open_redirect.txt"
        set +f

fi

# Hide LineageOS Strings in RC files
if [[ "${config_hide_lineage_strings}" == "1" ]]; then
        find /system /system_ext /vendor /product -iname "*.rc" -print0 2>/dev/null | while IFS= read -r -d '' path; do
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

                        brene_clone_perm "${fake_file_path}" "${path}"
                        ${SUSFS_BIN} add_open_redirect "${path}" "${fake_file_path}" '3'
                fi
        done
fi

# Spoof /system/etc/hosts
if [[ "${config_spoof_hosts}" == "1" ]]; then
    path=/system/etc/hosts
    ${SUSFS_BIN} add_sus_kstat_statically "${path}" '100' 'default' 'default' '64' 'default' 'default' 'default' 'default' 'default' 'default' '1' '4096'
fi

# Spoof Android System Properties
if [[ "${config_spoof_system_properties}" == "1" ]]; then
   spoof_android_system_properties
fi

# Hide Suspicious PTYs
if [[ "${config_hide_suspicious_ptys}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "####################"
			echo "Hide Suspicious PTYs"
			echo "####################"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	for i in $(seq 0 9); do
		brene_sus_path_loop "/dev/pts/${i}"
	done
fi

if [[ "${config_brene_logs}" == "1" ]]; then
	echo "post-fs-data.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi
