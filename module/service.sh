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

# Best-effort update for normal (bare-path) kstat entries at a later stage.
# If another module already mounted over the path, update_sus_kstat refreshes
# to the current stat and the flow completes; if a module mounts after
# service.sh, ordering cannot be guaranteed here.
if [[ -e "${PERSISTENT_DIR}/custom_sus_kstat.txt" ]]; then
        set -f
        while IFS= read -r i || [[ -n "${i}" ]]; do
                i="${i%$'\r'}"
                trimmed="$(printf '%s' "${i}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
                [[ -z "${trimmed}" || "${trimmed}" == "#"* ]] && continue

                OLDIFS="${IFS}"
                IFS=$'\t'
                set -- ${i}
                IFS="${OLDIFS}"

                if [[ "$#" -eq 1 ]]; then
                        case "$1" in
                                /*)
                                        _ws_count=$(set -f; set -- $1; echo "$#")
                                        if [[ "${_ws_count}" -eq 13 ]]; then
                                                continue
                                        fi
                                        if kstat_err="$(${SUSFS_BIN} update_sus_kstat "$1" 2>&1)"; then
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:update]: OK: ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                        else
                                                [[ "${config_brene_logs}" == "1" ]] && echo "[custom_sus_kstat:update] FAILED (${kstat_err:-exit $?}): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                                        fi ;;
                        esac
                fi
        done < "${PERSISTENT_DIR}/custom_sus_kstat.txt"
        set +f
fi
