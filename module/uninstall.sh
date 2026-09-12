#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

[ -e "${PERSISTENT_DIR}" ] && mv "${PERSISTENT_DIR}" "/data/adb/brene.uninstalled.$(date +%s)"
rm -f "${SUSFS_BIN}"
rm -f "${DEST_BIN_DIR}/sus"
rm -f "${DEST_BIN_DIR}/ksu_susfs"
