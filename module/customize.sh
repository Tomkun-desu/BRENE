#!/bin/bash
# shellcheck disable=SC2154
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

# Load utils
[[ -e "${MODPATH}/utils.sh" ]] && source "${MODPATH}/utils.sh"

echo ""
echo "██████╗ ██████╗ ███████╗███╗   ██╗███████╗"
echo "██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝"
echo "██████╔╝██████╔╝█████╗  ██╔██╗ ██║█████╗  "
echo "██╔══██╗██╔══██╗██╔══╝  ██║╚██╗██║██╔══╝  "
echo "██████╔╝██║  ██║███████╗██║ ╚████║███████╗"
echo "╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝"
echo ""

# Hot Install Support
export MODULE_HOT_INSTALL_REQUEST="true"

# Check Compatibility
if [[ -z "${KSU}" ]]; then
	abort '[❌] SuSFS is only for KernelSU or forks!'
fi

if [[ "${ARCH}" != "arm64" ]]; then
	abort '[❌] Only arm64 is supported!'
fi

[[ -z "${KSU_KERNEL_VER_CODE}" ]] && abort '[x] KSU_KERNEL_VER_CODE unset!'
case "${KSU_KERNEL_VER_CODE}" in ''|*[!0-9]*) abort "[❌] Unsupported KernelSU kernel version: ${KSU_KERNEL_VER_CODE}!";; esac
if [[ "${KSU_KERNEL_VER_CODE}" -ge 32336 ]]; then
	echo "[✅] Detected KernelSU kernel version: ${KSU_KERNEL_VER_CODE}"
else
	abort "[❌] Unsupported KernelSU kernel version: ${KSU_KERNEL_VER_CODE}!"
fi

if [[ ! -d "${DEST_BIN_DIR}" ]]; then
	abort "[❌] '${DEST_BIN_DIR}' not existed, installation aborted!"
fi

chmod +x "${MODPATH}/tools/susfs" 2>/dev/null || true
# pinned known-good susfs hash
SUSFS_PINNED_SHA256="13cb301afa5f4e9b512ec6efd79d19f2bf21d67c8375b83c06ba77caa4275064"
if command -v sha256sum >/dev/null 2>&1; then
  SUSFS_ACTUAL_SHA256="$(sha256sum "${MODPATH}/tools/susfs" 2>/dev/null | awk '{print $1}' || true)"
  if [ "${SUSFS_ACTUAL_SHA256}" != "${SUSFS_PINNED_SHA256}" ]; then
    abort "[❌] SuSFS hash mismatch! هش susfs نامعتبر است!"
  fi
fi
src_susfs_ver=$("${MODPATH}/tools/susfs" show version 2>/dev/null)
if [[ "${src_susfs_ver}" == "v2"* ]]; then
        echo "[✅] Bundled SuSFS version: ${src_susfs_ver}"
else
        abort "[❌] Not supported SuSFS version ${src_susfs_ver}!"
fi

cp -f "${MODPATH}/tools/susfs" "${DEST_BIN_DIR}" || abort "[❌] Failed to copy susfs binary!"
chmod +x "${MODPATH}/inotify.sh"
chmod +x "${MODPATH}/post-fs-data.sh" "${MODPATH}/service.sh" "${MODPATH}/boot-completed.sh" "${MODPATH}/action.sh" 2>/dev/null || true
chmod 755 "${DEST_BIN_DIR}/susfs" || abort "[❌] Failed to chmod susfs binary!"
ln -f -s "${DEST_BIN_DIR}/susfs" "${DEST_BIN_DIR}/sus" 2> /dev/null || true       # For development
ln -f -s "${DEST_BIN_DIR}/susfs" "${DEST_BIN_DIR}/ksu_susfs" 2> /dev/null || true # For compatibility

susfs_ver=$(${SUSFS_BIN} show version 2>/dev/null)
if [[ "${susfs_ver}" == "v2"* ]]; then
        echo "[✅] Installed SuSFS version: ${susfs_ver}"
else
        abort "[❌] Not supported SuSFS version ${susfs_ver}!"
fi

# Reset module description
kernel_version=$(cat /proc/version 2>/dev/null | awk '{print $3}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
kernel_version=${kernel_version:-unknown}
susfs_variant=$(${SUSFS_BIN} show variant 2>/dev/null)
susfs_features_number=$(${SUSFS_BIN} show enabled_features 2>/dev/null | wc -l)
susfs_total_features=9
${KSU_BIN} module config set override.description "[Module Status: ⏱️ | Kernel: ${kernel_version} | SuSFS Patches: ⏱️ ${susfs_ver} (${susfs_variant}) | SuSFS Features: ${susfs_features_number}/${susfs_total_features}] A SuSFS/KernelSU module for SuSFS patched kernels"

# Disable other SuSFS modules
[[ -e "${KSU_MODULES_DIR}/susfs4ksu" ]] && {
	touch "${KSU_MODULES_DIR}/susfs4ksu/disable" && echo '[✅] Disabling other SuSFS module'
}
[[ -e "${KSU_MODULES_DIR}/susfs_manager" ]] && {
	touch "${KSU_MODULES_DIR}/susfs_manager/disable" && echo '[✅] Disabling other SuSFS module'
}

echo '[✅] Preparing brene persistent directory (/data/adb/brene)'
mkdir -p "${PERSISTENT_DIR}"
chmod 700 "${PERSISTENT_DIR}" || true

files="
custom_sus_map.txt
custom_sus_mount.txt
custom_sus_path.txt
custom_sus_path_loop.txt
custom_sus_kstat.txt
custom_kernel_umount.txt
custom_open_redirect.txt
"
for file in ${files}; do
	if [[ ! -f "${PERSISTENT_DIR}/${file}" ]]; then
		touch "${PERSISTENT_DIR}/${file}" && echo "[✅] Added ${file}"
	fi
done

if [[ ! -f "${PERSISTENT_DIR}/config.sh" ]]; then
	cp "${MODPATH}/config.sh" "${PERSISTENT_DIR}" && echo '[✅] Added config.sh'
else
	while IFS='=' read -r key value || [[ -n "${key}" ]]; do
		key="${key%$'\r'}"; value="${value%$'\r'}"

		# Skip empty lines or comments
		[[ -z "${key// /}" || "${key// /}" == "#"* ]] && continue

		# Renamed keys: handled by the migration blocks below (old value wins over defaults).
		case "${key}" in
			config_spoof_os_security_patch_level_property|config_spoof_uname|config_custom_spoof_uname|config_hide_suspicious_pty|config_spoof_verified_boot_hash) continue ;;
		esac

		if awk -F= -v k="${key}" '$1==k{found=1; exit} END{exit !found}' "${PERSISTENT_DIR}/config.sh"; then
			:
		else
			echo "${key}=${value}" >> "${PERSISTENT_DIR}/config.sh"
			echo "[➕] Added missing key=value: ${key}=${value}"
		fi

	done < "${MODPATH}/config.sh"

	# Migrate renamed OS patch key, respecting explicit user opt-out (old=0 -> new=0).
	# Vendor key goes through the normal generic loop above (=1). Old key is kept (dead keys are repo norm).
	if ! tr -d '\r' < "${PERSISTENT_DIR}/config.sh" 2>/dev/null | grep -q '^config_spoof_os_security_patch_level_property='; then
		_brene_old_patch_val=""
		while IFS='=' read -r _mk _mv || [ -n "$_mk" ]; do
			_mk=$(printf '%s' "$_mk" | tr -d '\r')
			_mv=$(printf '%s' "$_mv" | tr -d '\r')
			case "$_mv" in
				\'*\'|\"*\")
					_mv=${_mv#?}
					_mv=${_mv%?}
					;;
			esac
			if [ "${_mk}" = "config_spoof_os_patch_level_property" ]; then
				_brene_old_patch_val="${_mv}"
			fi
		done < "${PERSISTENT_DIR}/config.sh"
		if [ "${_brene_old_patch_val}" = "0" ]; then
			echo "config_spoof_os_security_patch_level_property=0" >> "${PERSISTENT_DIR}/config.sh"
			echo "[➕] Migrated config_spoof_os_patch_level_property=0 -> config_spoof_os_security_patch_level_property=0"
		else
			echo "config_spoof_os_security_patch_level_property=1" >> "${PERSISTENT_DIR}/config.sh"
			echo "[➕] Added missing key=value: config_spoof_os_security_patch_level_property=1"
		fi
		_brene_old_patch_val=""; _mk=""; _mv=""
	fi

	# Migrate renamed keys to upstream names (old value wins over shipped defaults).
	# Old keys are kept (dead keys are repo norm). The generic loop above skips
	# new keys, so defaults are handled here when no old value exists.
	for _brene_pair in \
		"config_uname_spoofing config_spoof_uname" \
		"config_custom_uname_spoofing config_custom_spoof_uname" \
		"config_hide_suspicious_ptys config_hide_suspicious_pty" \
		"config_verified_boot_hash config_spoof_verified_boot_hash"; do
		_brene_old_key="${_brene_pair%% *}"
		_brene_new_key="${_brene_pair##* }"
		if tr -d '\r' < "${PERSISTENT_DIR}/config.sh" 2>/dev/null | grep -q "^${_brene_new_key}="; then
			continue
		fi
		_brene_old_val=""
		while IFS='=' read -r _mk _mv || [ -n "$_mk" ]; do
			_mk=$(printf '%s' "$_mk" | tr -d '\r')
			_mv=$(printf '%s' "$_mv" | tr -d '\r')
			case "$_mv" in
				\'*\'|\"*\")
					_mv=${_mv#?}
					_mv=${_mv%?}
					;;
			esac
			if [ "${_mk}" = "${_brene_old_key}" ]; then
				_brene_old_val="${_mv}"
			fi
		done < "${PERSISTENT_DIR}/config.sh"
		if [ -n "${_brene_old_val}" ]; then
			echo "${_brene_new_key}=${_brene_old_val}" >> "${PERSISTENT_DIR}/config.sh"
			echo "[➕] Migrated ${_brene_old_key}=${_brene_old_val} -> ${_brene_new_key}=${_brene_old_val}"
		else
			_brene_def_val=$(grep -E "^${_brene_new_key}=" "${MODPATH}/config.sh" 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r')
			if [ -n "${_brene_def_val}" ]; then
				echo "${_brene_new_key}=${_brene_def_val}" >> "${PERSISTENT_DIR}/config.sh"
				echo "[➕] Added missing key=value: ${_brene_new_key}=${_brene_def_val}"
			fi
		fi
	done
	_brene_pair=""; _brene_old_key=""; _brene_new_key=""; _brene_old_val=""; _brene_def_val=""
fi

# Remove fake_files folder
[[ -d "${PERSISTENT_DIR}/fake_files" ]] && rm -rf "${PERSISTENT_DIR}/fake_files"

# Enable WebUI without reboot (keep id in sync with module.prop)
MODDIR="/data/adb/modules/brene"
MODULES_PATH="/data/adb/modules"

# Copy first, drop the old install only on success (never rm before a verified copy)
if [ -n "${MODPATH}" ] && [ -d "${MODPATH}" ]; then
	rm -rf "${MODDIR}.bak"
	[ -d "${MODDIR}" ] && mv "${MODDIR}" "${MODDIR}.bak"
	if cp -rp "${MODPATH}" "${MODULES_PATH}"; then
		rm -rf "${MODDIR}.bak"
		(
			sleep 1
			rm -rf "${MODPATH}"
			rm -f "${MODDIR}/update"
		) & # fork in background
		echo '[✅] WebUI is ready!'
	else
		[ -d "${MODDIR}.bak" ] && mv "${MODDIR}.bak" "${MODDIR}"
		echo '[⚠️] WebUI copy failed, reboot to apply'
	fi
else
	echo '[⚠️] MODPATH missing, reboot to apply'
fi
