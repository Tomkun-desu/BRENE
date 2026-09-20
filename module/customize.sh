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
${KSU_BIN} module config set override.description "[Module Status: ⏱️ | Kernel: ${kernel_version} | SuSFS Patches: ⏱️] A SuSFS/KernelSU module for SuSFS patched kernels"

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

		if awk -F= -v k="${key}" '$1==k{found=1; exit} END{exit !found}' "${PERSISTENT_DIR}/config.sh"; then
			:
		else
			echo "${key}=${value}" >> "${PERSISTENT_DIR}/config.sh"
			echo "[➕] Added missing key=value: ${key}=${value}"
		fi

	done < "${MODPATH}/config.sh"
fi

# Remove fake_files folder
[[ -d "${PERSISTENT_DIR}/fake_files" ]] && rm -rf "${PERSISTENT_DIR}/fake_files"
