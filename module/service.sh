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
# Load config
[[ -e "${PERSISTENT_DIR}/config.sh" ]] && source "${PERSISTENT_DIR}/config.sh"

# Load custom_sus_kstat.txt
# Format per line: <path> <ino> <dev> <nlink> <size> <atime> <atime_nsec> <mtime> <mtime_nsec> <ctime> <ctime_nsec> <blocks> <blksize>
# Use the literal word 'default' for any field to leave it as the real current value.
# Run in service.sh (late boot stage) instead of boot-completed.sh, since paths need to be
# fully stable/mounted before their stat can be reliably overridden.
if [[ -e "${PERSISTENT_DIR}/custom_sus_kstat.txt" ]]; then
        while IFS= read -r i; do
                # Skip empty lines or comments
                [[ -z "${i// /}" || "${i// /}" == "#"* ]] && continue

                IFS=$'\t' read -ra kstat_args <<< "${i}"
                if [[ "${#kstat_args[@]}" -eq 13 ]]; then
                        ${SUSFS_BIN} add_sus_kstat_statically "${kstat_args[@]}"
                        if [[ "${config_brene_logs}" == "1" ]]; then
                                echo "[custom_sus_kstat]: ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                        fi
                elif [[ "${config_brene_logs}" == "1" ]]; then
                        echo "[custom_sus_kstat] SKIPPED (expected 13 fields, got ${#kstat_args[@]}): ${i}" >> "${PERSISTENT_DIR}/logs.txt"
                fi
        done < "${PERSISTENT_DIR}/custom_sus_kstat.txt"
fi

if [[ "${config_brene_logs}" == "1" ]]; then
        echo "service.sh ✅" >> "${PERSISTENT_DIR}/log.txt"
fi
