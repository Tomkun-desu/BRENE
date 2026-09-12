#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin
CUSTOM_ROM_NAMES="lineage|infinity|evolution|crdroid|mistos|axion|pixelos|rising|lunaris|halcyon|havoc|alphadroid|bliss|calyx|derpfest|graphene|lmodroid|lumine|matrixx|clover|yaap|aospa"

# Load utils
[[ -e "${MODDIR}/utils.sh" ]] && source "${MODDIR}/utils.sh"
# Load config
[[ -e "${PERSISTENT_DIR}/config.sh" ]] && source "${PERSISTENT_DIR}/config.sh"

# Update Description
susfs_ver=$(${SUSFS_BIN} show version)
description="A SuSFS/KernelSU module for SuSFS patched kernels"
if [[ -n "${susfs_ver}" ]]; then
	${KSU_BIN} module config set override.description "[Module Status: ✅ | SuSFS Patches: ✅ ${susfs_ver}] ${description}"
else
	${KSU_BIN} module config set override.description "[Module Status: ❌ | SuSFS Patches: ❌] ${description}"
fi

# SU Compat
if [[ "${config_su_compat}" == "1" ]]; then
	${KSU_BIN} feature set su_compat 1
elif [[ "${config_su_compat}" == "0" ]]; then
	${KSU_BIN} feature set su_compat 0
fi

# Kernel Umount
if [[ "${config_kernel_umount}" == "1" ]]; then
	${KSU_BIN} feature set kernel_umount 1
elif [[ "${config_kernel_umount}" == "0" ]]; then
	${KSU_BIN} feature set kernel_umount 0
fi

# Hide SELinux modification
if [[ "${config_selinux_hide}" == "1" ]]; then
	${KSU_BIN} feature set selinux_hide 1
elif [[ "${config_selinux_hide}" == "0" ]]; then
	${KSU_BIN} feature set selinux_hide 0
fi

${KSU_BIN} feature save

# Developer Options
if [[ "${config_developer_options}" == "1" ]]; then
	settings put global development_settings_enabled 1
elif [[ "${config_developer_options}" == "0" ]]; then
	settings put global development_settings_enabled 0
fi

# USB Debugging
if [[ "${config_usb_debugging}" == "1" ]]; then
	settings put global adb_enabled 1
elif [[ "${config_usb_debugging}" == "0" ]]; then
	settings put global adb_enabled 0
fi

# Wireless Debugging
if [[ "${config_wireless_debugging}" == "1" ]]; then
	settings put global adb_wifi_enabled 1
elif [[ "${config_wireless_debugging}" == "0" ]]; then
	settings put global adb_wifi_enabled 0
fi

# Disable Child Process Restrictions
if [[ "${config_disable_child_process_restrictions}" == "1" ]]; then
        resetprop_n persist.sys.fflag.override.settings_enable_monitor_phantom_procs false
fi

# SELinux Enforcing
if [[ "${config_selinux}" == "1" ]]; then
	[[ "$(getenforce)" != "Enforcing" ]] && setenforce 1
fi

# Remove Custom ROM Properties
if [[ "${config_rom_props}" == "1" ]]; then
	resetprop | grep -iE "${CUSTOM_ROM_NAMES}" | awk -F'[][]' '{print $2}' | while read -r prop; do
		resetprop -d "${prop}"
	done

	resetprop -d "ro.modversion"
fi

# Remove Play Integrity Fix Properties
if [[ "${config_pif_props}" == "1" ]]; then
	resetprop | grep -iE "pihook|pixelprops|spoof" | awk -F'[][]' '{print $2}' | while read -r prop; do
		resetprop -d -p "${prop}"
	done
fi

# Max Saturation
if [[ "${config_saturation}" == "1" ]]; then
	service call SurfaceFlinger 1022 f 2.0
fi
# Show Refresh Rate
if [[ "${config_show_refresh_rate}" == "1" ]]; then
    service call SurfaceFlinger 1034 i32 1
fi

#### Hide some sus paths, effective only for processes that are marked umounted with uid >= 10000 ####
# Spoof Android System Properties
if [[ "${config_spoof_system_properties}" == "1" ]]; then
   spoof_android_system_properties
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
# Spoof Android System Properties
if [[ "${config_spoof_system_properties}" == "1" ]]; then
   spoof_android_system_properties
fi

# Spoof Android System Properties Every Minute
if [[ "${config_spoof_system_properties_repeat}" == "1" ]]; then
   while true; do
           sleep 60
           spoof_android_system_properties
   done &
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
inotifyd "${MODDIR}/inotify.sh" /sdcard:n &

## For paths that are frequently modified, we can add them via 'add_sus_path_loop' ##
## Be reminded that without HMA's vold app data enabled, added sus_paths are still vulnerable to zwc exploit, so in this case users also have to add its underlying path as well ##

# Suspicious Paths Hiding

# Non-standard /sdcard
__brene_hide_nonstandard_sdcard_once() {
	if [[ -z "$(resetprop ro.miui.ui.version.name)" ]]; then
		standard_paths="Alarms Android Audiobooks DCIM Documents Download Movies Music Notifications Pictures Podcasts Recordings Ringtones"
	else
		standard_paths="Alarms Android Audiobooks DCIM Documents Download Movies Music Notifications Pictures Podcasts Recordings Ringtones MIUI"
	fi

	_hide_n=0
	shopt -s nullglob; _entries=(/sdcard/*); shopt -u nullglob
	for i in "${_entries[@]}"; do
		[[ -e "${i}" ]] || { [[ "${config_brene_logs}" == "1" ]] && echo "[skip] vanished/denied: ${i}" >> "${PERSISTENT_DIR}/logs.txt"; continue; }
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
	if [[ "${_hide_n}" -eq 0 && "${config_brene_logs}" == "1" ]]; then
		echo "[skip] /sdcard pass added 0 entries (empty listing or all standard), entries_seen=${#_entries[@]}" >> "${PERSISTENT_DIR}/logs.txt"
	fi
}
if [[ "${config_paths_hiding__non_standard_sdcard}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "####################"
			echo "Non-standard /sdcard"
			echo "####################"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	if ! brene_wait_for_nonempty_listing "/sdcard" 15 && [[ "${config_brene_logs}" == "1" ]]; then
		echo "[wait] /sdcard listing still empty after ~30s, attempting once anyway" >> "${PERSISTENT_DIR}/logs.txt"
	fi
	__brene_hide_nonstandard_sdcard_once
fi

# Non-standard /sdcard/Android
__brene_hide_nonstandard_sdcard_android_once() {
	standard_paths="data media obb"
	_hide_n=0
	shopt -s nullglob; _entries=(/sdcard/Android/*); shopt -u nullglob
	for i in "${_entries[@]}"; do
		[[ -e "${i}" ]] || { [[ "${config_brene_logs}" == "1" ]] && echo "[skip] vanished/denied: ${i}" >> "${PERSISTENT_DIR}/logs.txt"; continue; }
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
	if [[ "${_hide_n}" -eq 0 && "${config_brene_logs}" == "1" ]]; then
		echo "[skip] /sdcard/Android pass added 0 entries, entries_seen=${#_entries[@]}" >> "${PERSISTENT_DIR}/logs.txt"
	fi
}
if [[ "${config_paths_hiding__non_standard_sdcard_android}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "############################"
			echo "Non-standard /sdcard/Android"
			echo "############################"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	if ! brene_wait_for_nonempty_listing "/sdcard/Android" 15 && [[ "${config_brene_logs}" == "1" ]]; then
		echo "[wait] /sdcard/Android listing still empty after ~30s, attempting once anyway" >> "${PERSISTENT_DIR}/logs.txt"
	fi
	__brene_hide_nonstandard_sdcard_android_once
fi

# Late second pass: storage often populates after boot-completed. Same functions,
# same allowlists — idempotent retry only. Backgrounded so boot is never blocked.
( sleep 60
  [[ "${config_paths_hiding__non_standard_sdcard}" == "1" ]] && __brene_hide_nonstandard_sdcard_once
  [[ "${config_paths_hiding__non_standard_sdcard_android}" == "1" ]] && __brene_hide_nonstandard_sdcard_android_once
  [[ "${config_brene_logs}" == "1" ]] && echo "[retry] late sdcard hide pass done" >> "${PERSISTENT_DIR}/logs.txt"
) &

# Hide Custom Recovery Paths
if [[ "${config_hide_custom_recovery}" == "1" ]]; then
        if [[ "${config_brene_logs}" == "1" ]]; then
                {
                        echo ""
                        echo "########################"
                        echo "Hide Custom Recovery Paths"
                        echo "########################"
                } >> "${PERSISTENT_DIR}/logs.txt"
        fi

        [[ -e "/storage/emulated/0/Fox" ]] && brene_sus_path_loop "/storage/emulated/0/Fox"
        [[ -e "/storage/emulated/0/TWRP" ]] && brene_sus_path_loop "/storage/emulated/0/TWRP"
        [[ -e "/data/recovery" ]] && brene_sus_path_loop "/data/recovery"
        [[ -e "/cache/recovery" ]] && brene_sus_path_loop "/cache/recovery"
        [[ -e "/data/cache/recovery" ]] && brene_sus_path_loop "/data/cache/recovery"
        [[ -e "/vendor/bin/install-recovery.sh" ]] && brene_sus_path_loop "/vendor/bin/install-recovery.sh"
        [[ -e "/system/bin/install-recovery.sh" ]] && brene_sus_path_loop "/system/bin/install-recovery.sh"
fi

# /data/local/tmp
if [[ "${config_paths_hiding__data_local_tmp}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "###############"
			echo "/data/local/tmp"
			echo "###############"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	for i in /data/local/tmp/*; do
		[[ -e "${i}" ]] || continue
		brene_sus_path_loop "${i}"
	done
fi

# Fix /data/local/tmp Inconsistencies
if [[ "${config_fix_data_local_tmp_inconsistencies}" == "1" ]]; then
        target_folder="/data/local/tmp"

        mkdir -p "${target_folder}"
        chmod 0771 "${target_folder}"
        chown shell:shell "${target_folder}"
        chcon u:object_r:shell_data_file:s0 "${target_folder}"
        # add_sus_kstat_statically </path/of/file_or_directory> <ino> <dev> <nlink> <size> <atime> <atime_nsec> <mtime> <mtime_nsec> <ctime> <ctime_nsec> <blocks> <blksize>
        # ino -> %i, dev -> %d, nlink -> %h, atime -> %X, mtime -> %Y, ctime -> %Z, size -> %s, blocks -> %b, blksize -> %B
        # Example: stat -c %i <path>
        ${SUSFS_BIN} add_sus_kstat_statically "${target_folder}" '100' 'default' 'default' '4096' 'default' 'default' 'default' 'default' 'default' 'default' '8' '4096'
fi

# Manually-installed User CA Certificates
if [[ "${config_paths_hiding__user_ca_certs}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "###############################"
			echo "User CA Certificates"
			echo "###############################"
		} >> "${PERSISTENT_DIR}/logs.txt"
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
		{
			echo ""
			echo "####################################"
			echo "/sdcard/Android/[data | media | obb]"
			echo "####################################"
		} >> "${PERSISTENT_DIR}/logs.txt"
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
	{
		echo ""
		echo "#############################"
		echo "Other Suspicious Paths Hiding"
		echo "#############################"
	} >> "${PERSISTENT_DIR}/logs.txt"
fi
# brene_sus_path "/sys/block/loop0"

# Load custom_sus_map.txt
if [[ -e "${PERSISTENT_DIR}/custom_sus_map.txt" ]]; then
	while IFS= read -r i; do
		# Skip empty lines or comments
		[[ -z "${i// /}" || "${i// /}" == "#"* ]] && continue

		brene_sus_map "${i}"
	done < "${PERSISTENT_DIR}/custom_sus_map.txt"
fi

# Load custom_sus_path.txt
if [[ -e "${PERSISTENT_DIR}/custom_sus_path.txt" ]]; then
	while IFS= read -r i; do
		# Skip empty lines or comments
		[[ -z "${i// /}" || "${i// /}" == "#"* ]] && continue

		brene_sus_path "${i}"
	done < "${PERSISTENT_DIR}/custom_sus_path.txt"
fi

# Load custom_sus_path_loop.txt
if [[ -e "${PERSISTENT_DIR}/custom_sus_path_loop.txt" ]]; then
	while IFS= read -r i; do
		# Skip empty lines or comments
		[[ -z "${i// /}" || "${i// /}" == "#"* ]] && continue

		brene_sus_path_loop "${i}"
	done < "${PERSISTENT_DIR}/custom_sus_path_loop.txt"
fi

# Load custom_sus_mount.txt
if [[ -e "${PERSISTENT_DIR}/custom_sus_mount.txt" ]]; then
	while IFS= read -r i; do
		# Skip empty lines or comments
		[[ -z "${i// /}" || "${i// /}" == "#"* ]] && continue

		brene_sus_mount "${i}"
	done < "${PERSISTENT_DIR}/custom_sus_mount.txt"
fi

# Load custom_kernel_umount.txt
if [[ -e "${PERSISTENT_DIR}/custom_kernel_umount.txt" ]]; then
        while IFS= read -r i; do
                # Skip empty lines or comments
                [[ -z "${i// /}" || "${i// /}" == "#"* ]] && continue

                brene_kernel_umount "${i}"
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
                {
                        echo ""
                        echo "#################"
                        echo "Injections Hiding"
                        echo "#################"
                } >> "${PERSISTENT_DIR}/logs.txt"
        fi

        overlayfs="/data/adb/modules/meta-overlayfs/mnt"
        magic_mount="/data/adb/modules"
        [[ -e "${overlayfs}" ]] && path="${overlayfs}" || path="${magic_mount}"

        for module in "${path}"/*; do
                if [[ -e "${module}/system" ]]; then
                        find "${module}/system" -type f | while read -r file; do
                                brene_sus_map "${file}"
                        done
                fi
        done

        find /data/adb/modules -name "*.so" | while read -r file; do
                brene_sus_map "${file}"
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
	${KSU_BIN} kernel notify-module-mounted

	cat /proc/1/mountinfo | grep -E "^2[0-9]{9,} .*$|KSU" | awk '{print $5}' | while read -r mount; do
		${KSU_BIN} kernel umount add -f 2 "${mount}" 2> /dev/null
	done
fi

# Hide framework-res.apk
if [[ "${config_hide_framework_res_apk}" == "1" ]]; then
	find /system -iname "*framework-res.apk" | while read -r path; do
		brene_sus_map "${path}"
	done
fi



# Android Verified Boot Hash Spoofing
if [[ "${config_verified_boot_hash}" != '' ]]; then
	resetprop_n "ro.boot.vbmeta.digest" "${config_verified_boot_hash}"
fi

resetprop -c --force

if [[ "${config_brene_logs}" == "1" ]]; then
	echo "boot-completed.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi
