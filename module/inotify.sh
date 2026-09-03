# shellcheck disable=SC2154
# shellcheck disable=SC2148
# Remove "..5.u.S"
TARGET="..5.u.S"
TARGET1="/storage/emulated/0/${TARGET}"
TARGET2="/storage/emulated/0/Android/data/${TARGET}"
TARGET3="/storage/emulated/0/Android/media/${TARGET}"
TARGET4="/storage/emulated/0/Android/obb/${TARGET}"
rm -rf "${TARGET1}" "${TARGET2}" "${TARGET3}" "${TARGET4}"
