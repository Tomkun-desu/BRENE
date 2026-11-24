#!/system/bin/sh
# shellcheck disable=SC2154
# shellcheck disable=SC2148
sleep 1
PERSISTENT_DIR=/data/adb/brene

remove_directory() {
	if [[ -z "$1" ]]; then
		return 1
	fi

	# Package name only: no '/', no '..' — a line like '../..' would rm -rf
	# outside the app dirs.
	case "$1" in
		*[!A-Za-z0-9_.-]*|.|..) return 1 ;;
	esac

	local TARGET1="/storage/emulated/0/Android/data/$1"
	local TARGET2="/storage/emulated/0/Android/media/$1"
	local TARGET3="/storage/emulated/0/Android/obb/$1"
	rm -rf "${TARGET1}" "${TARGET2}" "${TARGET3}"
}

# Load remove_sus_dir_sdcard_android_data_media_obb.txt
if [[ -e "${PERSISTENT_DIR}/remove_sus_dir_sdcard_android_data_media_obb.txt" ]]; then
	while IFS= read -r line || [[ -n "${line}" ]]; do
		line=${line%$'\r'}
		line=${line#"${line%%[![:space:]]*}"}; line=${line%"${line##*[![:space:]]}"}
		# Skip empty lines or comments
		[[ -z "${line}" || "${line}" == "#"* ]] && continue

		remove_directory "${line}"
	done < "${PERSISTENT_DIR}/remove_sus_dir_sdcard_android_data_media_obb.txt"
fi
