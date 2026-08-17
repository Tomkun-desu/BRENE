#!/bin/bash
# shellcheck disable=SC2154
PATH=/data/adb/ksu/bin:$PATH
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

## susfs_clone_perm <file/or/dir/perm/to/be/changed> <file/or/dir/to/clone/from>
susfs_clone_perm() {
	TO=$1
	FROM=$2
	if [ -z "${TO}" -o -z "${FROM}" ]; then
		return
	fi
	## stat https://github.com/backslashxx/bindhosts/commit/427f18fe0b212ef2754e79c8aaaa72cb59ad253d#diff-8cb0da3b1680ce3a9f3263622042aa6f0250431fa5069513664650a17c48fdabR15
	CLONED_PERM_STRING=$(stat -c "%a %U %G" ${FROM})
	set ${CLONED_PERM_STRING}
	chmod $1 ${TO}
	chown $2:$3 ${TO}
	busybox chcon --reference=${FROM} ${TO}
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
	resetprop -n "$1" "$2"
}

if_prop_value_exits_resetprop_n() {
	local PROP_NAME=$1
	local EXPECTED_VALUE=$2
	local CURRENT_VALUE
	CURRENT_VALUE=$(resetprop "${PROP_NAME}")

	[[ -z "${CURRENT_VALUE}" ]] || [[ "${CURRENT_VALUE}" == "${EXPECTED_VALUE}" ]] || resetprop -n "${PROP_NAME}" "${EXPECTED_VALUE}"
}

# if_contains_resetprop_n() {
# 	local PROP_NAME=$1
#   local CONTAINS_VALUE=$2
#   local NEW_VALUE=$3

#   [[ "$(resetprop ${PROP_NAME})" = *"${CONTAINS_VALUE}"* ]] && resetprop -n "${PROP_NAME}" "${NEW_VALUE}"
# }

spoof_android_system_properties() {
	resetprop_n "init.svc.adbd" "stopped"
	resetprop_n "init.svc_debug_pid.adbd" ""
	resetprop_n "persist.sys.usb.config" "mtp"
	resetprop_n "ro.adb.secure" "1"
	resetprop_n "ro.crypto.state" "encrypted"
	resetprop_n "ro.debuggable" "0"
	resetprop_n "ro.force.debuggable" "0"
	resetprop_n "ro.kernel.qemu" ""
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

	resetprop_n "ro.boot.vbmeta.size" "4096"
	resetprop_n "ro.boot.vbmeta.hash_alg" "sha256"
	resetprop_n "ro.boot.vbmeta.avb_version" "1.3"
	resetprop_n "ro.boot.vbmeta.device_state" "locked"
	resetprop_n "ro.boot.vbmeta.invalidate_on_error" "yes"

	if_prop_value_exits_resetprop_n "ro.warranty_bit" "0"
	if_prop_value_exits_resetprop_n "ro.vendor.boot.warranty_bit" "0"
	if_prop_value_exits_resetprop_n "ro.vendor.warranty_bit" "0"
	if_prop_value_exits_resetprop_n "ro.boot.warranty_bit" "0"

	fingerprint_value=$(resetprop ro.build.fingerprint)
	new_fingerprint_value="${fingerprint_value//userdebug/user}"
	new_fingerprint_value="${new_fingerprint_value//evolution/}"
	new_fingerprint_value="${new_fingerprint_value//crdroid/}"
	new_fingerprint_value="${new_fingerprint_value//lineage/}"
	resetprop_n "ro.bootimage.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.odm.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.odm_dlkm.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.product.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.system.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.system_dlkm.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.system_ext.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.vendor.build.fingerprint" "${new_fingerprint_value}"
	resetprop_n "ro.vendor_dlkm.build.fingerprint" "${new_fingerprint_value}"

	new_utc_value=$(resetprop ro.build.date.utc)
	resetprop_n "ro.bootimage.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.odm.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.odm_dlkm.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.product.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.system.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.system_dlkm.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.system_ext.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.vendor.build.date.utc" "${new_utc_value}"
	resetprop_n "ro.vendor_dlkm.build.date.utc" "${new_utc_value}"

	## Delete some prop names for newer pixel device ##
	resetprop -d "ro.boot.verifiedbooterror"
	resetprop -d "ro.boot.verifyerrorpart"
	resetprop -d "crashrecovery.rescue_boot_count"

	resetprop -d service.adb.root
	resetprop -d service.adb.tcp.port

	if [[ "$(resetprop ro.build.version.sdk)" -ge "36" ]]; then
		resetprop -d sys.oem_unlock_allowed
	else
		resetprop_n "sys.oem_unlock_allowed" "0"
	fi

	resetprop -c --force
}

brene_sus_path() {
	if ${SUSFS_BIN} add_sus_path "$1" && [[ "${config_brene_logs}" == "1" ]]; then
		echo "[sus_path]: $1" >> "${PERSISTENT_DIR}/logs.txt"
	fi
}
brene_sus_path_loop() {
	if ${SUSFS_BIN} add_sus_path_loop "$1" && [[ "${config_brene_logs}" == "1" ]]; then
		echo "[sus_path_loop]: $1" >> "${PERSISTENT_DIR}/logs.txt"
	fi
}
brene_sus_map() {
	if ${SUSFS_BIN} add_sus_map "$1" && [[ "${config_brene_logs}" == "1" ]]; then
		echo "[sus_map]: $1" >> "${PERSISTENT_DIR}/logs.txt"
	fi
}
brene_set_uname() {
	if ${SUSFS_BIN} set_uname "$1" "$2" && [[ "${config_brene_logs}" == "1" ]]; then
		echo "[set_uname]: $1 $2" >> "${PERSISTENT_DIR}/logs.txt"
	fi
}
brene_sus_mount() {
	${KSU_BIN} kernel notify-module-mounted
	${KSU_BIN} kernel umount add -f 2 "$1" 2> /dev/null
}
