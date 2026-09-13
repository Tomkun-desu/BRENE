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

echo "██████╗ ██████╗ ███████╗███╗   ██╗███████╗"
echo "██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝"
echo "██████╔╝██████╔╝█████╗  ██╔██╗ ██║█████╗  "
echo "██╔══██╗██╔══██╗██╔══╝  ██║╚██╗██║██╔══╝  "
echo "██████╔╝██║  ██║███████╗██║ ╚████║███████╗"
echo "╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝"
echo ""

echo "Soon"

# echo "- BRENE Version: $(grep "^version=" "${MODDIR}/module.prop" | cut -d'=' -f2)"
# echo "- SuSFS Version: $(${SUSFS_BIN} show version)"
# echo "- Device Model: $(resetprop ro.product.manufacturer) $(resetprop ro.product.model) $(resetprop ro.product.device)"
# echo "- Android Version: $(resetprop ro.build.version.release) (API $(resetprop ro.build.version.sdk)) | SDK $(resetprop ro.build.version.sdk)"
# echo "- Kernel Version: $(cat /proc/version | awk '{print $3}') | $(uname -r)"
# echo "- Custom ROM: $([[ -n "$(find /system -iname "*lineage*")" ]] && echo "Yes" || echo "No")"
# echo "- SuSFS Variant: $(${SUSFS_BIN} show variant)"
# echo "- ..5.u.S Status: $([[ -e /storage/emulated/0/..5.u.S ]] && echo "Abnormal" || echo "Normal")"
