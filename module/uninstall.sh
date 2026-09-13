#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

[ -e "${PERSISTENT_DIR}" ] && mv "${PERSISTENT_DIR}" "/data/adb/brene.uninstalled.$(date +%s)"
: # kept shared susfs binary (other modules may need it)
rm -f "${DEST_BIN_DIR}/sus"
rm -f "${DEST_BIN_DIR}/ksu_susfs"
rm -f "${KSU_MODULES_DIR}/susfs4ksu/disable"
rm -f "${KSU_MODULES_DIR}/susfs_manager/disable"
if ls -d /data/adb/brene.uninstalled.* >/dev/null 2>&1; then
	ls -dt -- /data/adb/brene.uninstalled.* 2>/dev/null | tail -n +4 | while IFS= read -r old_backup; do
		rm -rf -- "$old_backup"
	done
fi
