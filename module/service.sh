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

if [[ "${config_brene_logs}" == "1" ]]; then
        echo "service.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi

# Best-effort update for custom kstat entries at a later stage.
# Mapping (see brene_kstat_update_line in utils.sh):
#   normal (bare path) -> update_sus_kstat
#   full_clone (fullclone:/path) -> update_sus_kstat_full_clone
#   static (13-field line) -> update_sus_kstat (completes the static add
#     after mounts are up, per susfs docs; same as brene_sus_kstat_static)
# Every outcome is logged as [custom_sus_kstat:update*]: OK / FAILED rc=N.
if [[ -e "${PERSISTENT_DIR}/custom_sus_kstat.txt" ]]; then
        while IFS= read -r i || [[ -n "${i}" ]]; do
                brene_kstat_update_line "${i}"
        done < "${PERSISTENT_DIR}/custom_sus_kstat.txt"
fi
