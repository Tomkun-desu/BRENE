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
# susfs_clone_perm "$MODDIR/hosts" /system/etc/hosts

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
# susfs_clone_perm '/data/local/tmp/my_hosts' '/system/etc/hosts'
## Now add the target path and redirected path with pre-defined uid scheme to kernel ##
## *Run 'ksu_susfs add_open_redirect' for more details of <uid_scheme> ##
# ${SUSFS_BIN} add_open_redirect '/system/etc/hosts' '/data/local/tmp/my_hosts' '0'

# Spoof /system/lib64/libstagefright.so
if [[ "${config_spoof_libstagefright}" == "1" ]]; then
	path=/system/lib64/libstagefright.so
	file_name=$(basename "${path}")
	fake_file_path="${PERSISTENT_DIR}/fake_files/${file_name}"

	[[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
	[[ ! -f "${fake_file_path}" ]] && {
		touch "${fake_file_path}"
	}

	susfs_clone_perm "${fake_file_path}" "${path}"
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

# Spoof /proc/cmdline or /proc/bootconfig
if [[ "${config_spoof_cmdline_or_bootconfig}" == "1" ]]; then
	susfs_variant=$(${SUSFS_BIN} show variant)

	if [[ "${susfs_variant}" == "GKI" ]]; then
		FAKE_BOOTCONFIG="${PERSISTENT_DIR}/fake_bootconfig"

		cat /proc/bootconfig > "${FAKE_BOOTCONFIG}"
		sed -i 's/androidboot.warranty_bit = "1"/androidboot.warranty_bit = "0"/' "${FAKE_BOOTCONFIG}"
		sed -i 's/androidboot.verifiedbootstate = "orange"/androidboot.verifiedbootstate = "green"/' "${FAKE_BOOTCONFIG}"
		${SUSFS_BIN} set_cmdline_or_bootconfig "${FAKE_BOOTCONFIG}"
	else
		FAKE_CMDLINE="${PERSISTENT_DIR}/fake_cmdline"

		cat /proc/cmdline > "${FAKE_CMDLINE}"
		sed -i 's/androidboot.warranty_bit=1/androidboot.warranty_bit=0/' "${FAKE_CMDLINE}"
		sed -i 's/androidboot.verifiedbootstate=orange/androidboot.verifiedbootstate=green/' "${FAKE_CMDLINE}"
		${SUSFS_BIN} set_cmdline_or_bootconfig "${FAKE_CMDLINE}"
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
elif [[ "${config_enable_avc_log_spoofing}" == "0" ]]; then
	${SUSFS_BIN} enable_avc_log_spoofing 0
fi

#### Hide all sus mounts for NON-SU processes in this stage just to prevent zygote from caching them in memory ####
## This should be mainly applied if you have ReZygisk enabled but without TreatWheel module ##
## Or it is up to you to keep it enabled since su process can still see the mounts ##
if [[ "${config_hide_sus_mnts_for_non_su_procs}" == "1" ]]; then
	${SUSFS_BIN} hide_sus_mnts_for_non_su_procs 1
elif [[ "${config_hide_sus_mnts_for_non_su_procs}" == "0" ]]; then
	${SUSFS_BIN} hide_sus_mnts_for_non_su_procs 0
fi

# Spoof Uname
#### Spoof the uname, effective for all processes ####
# you can get your uname args by running 'uname {-r|-v}' on your stock ROM #
# pass 'default' to tell susfs to use the default value by uname #
# ${SUSFS_BIN} set_uname 'default' 'default'
if [[ "${config_spoof_uname}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "###########"
			echo "Spoof Uname"
			echo "###########"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	kernel_version=$(cat /proc/version | awk '{print $3}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
	kmi=$(${KSU_BIN} boot-info current-kmi | cut -d'-' -f1)
	uname_kernel_release="${kernel_version}-${kmi}"
	uname_kernel_version="#1 SMP PREEMPT $(resetprop ro.build.date | tr -s ' ')"

	brene_set_uname "${uname_kernel_release}" "${uname_kernel_version}"
fi

# Custom Spoof Uname
if [[ "${config_custom_spoof_uname}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "##################"
			echo "Custom Spoof Uname"
			echo "##################"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	uname_kernel_version="#1 SMP PREEMPT $(resetprop ro.build.date | tr -s ' ')"
	brene_set_uname "${config_custom_uname_kernel_release}" "${uname_kernel_version}"
fi

## Disable susfs kernel log ##
if [[ "${config_enable_log}" == "1" ]]; then
	${SUSFS_BIN} enable_log 1
elif [[ "${config_enable_log}" == "0" ]]; then
	${SUSFS_BIN} enable_log 0
fi

# Hide /system/addon.d Path
if [[ "${config_hide_addon_d}" == "1" ]]; then
	brene_sus_path "/system/addon.d"
fi

# Hide Custom ROM Paths
if [[ "${config_hide_custom_rom_paths}" == "1" ]]; then
	for i in ${CUSTOM_ROM_NAMES//|/ }; do
		find /system /system_ext /vendor /product -iname "*${i}*" | while read -r path; do
			brene_sus_map "${path}"
			brene_sus_path "${path}"
		done

		find /data -maxdepth 1 -iname "*${i}*" | while read -r path; do
			brene_sus_path_loop "${path}"
		done
	done
fi

# Hide LineageOS Strings
if [[ "${config_hide_lineage_strings}" == "1" ]]; then
	find /system /system_ext /vendor /product \( -iname "*sepolicy.cil" -o -iname "*file_contexts" \) | while read -r path; do
		file_name=$(basename "${path}")
		fake_file_path="${PERSISTENT_DIR}/fake_files/${file_name}"

		[[ ! -d "${PERSISTENT_DIR}/fake_files" ]] && mkdir -p "${PERSISTENT_DIR}/fake_files"
		[[ ! -f "${fake_file_path}" ]] && {
			touch "${fake_file_path}"
		}

		susfs_clone_perm "${fake_file_path}" "${path}"
		${SUSFS_BIN} add_open_redirect "${path}" "${fake_file_path}" '3'
	done
fi

# Hide Suspicious PTYs
if [[ "${config_hide_suspicious_pty}" == "1" ]]; then
	if [[ "${config_brene_logs}" == "1" ]]; then
		{
			echo ""
			echo "####################"
			echo "Hide Suspicious PTYs"
			echo "####################"
		} >> "${PERSISTENT_DIR}/logs.txt"
	fi

	for i in $(seq 0 5); do
		brene_sus_path_loop "/dev/pts/${i}"
	done
fi

# Spoof Android System Properties
if [[ "${config_spoof_system_properties}" == "1" ]]; then
	spoof_android_system_properties
fi

if [[ "${config_brene_logs}" == "1" ]]; then
	echo "post-fs-data.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi
