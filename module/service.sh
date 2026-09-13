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
if [[ -e "${PERSISTENT_DIR}/config.sh" ]]; then
  while IFS='=' read -r k v || [[ -n "$k" ]]; do
    k="${k%$'\r'}"; v="${v%$'\r'}"
    case "$v" in \'*\'|\"*\") v="${v:1:-1}" ;; esac
    case "$k" in config_[A-Za-z0-9_]*) printf -v "$k" '%s' "$v" ;; esac
  done < "${PERSISTENT_DIR}/config.sh"
fi
mkdir -p "${PERSISTENT_DIR}"

if [[ "${config_brene_logs}" == "1" ]]; then
        echo "service.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi
