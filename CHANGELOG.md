# Changelog

# Supports SuSFS 2.2.0 and 2.3.0+

- drop: service.sh and post-mount.sh
- improve: run spoof props after /storage/emulated/0/Android is accessible
- drop: dead feature "hide_modules_img"
- drop: Umount Suspicious Mounts, not needed with SUS_MOUNT
- drop: Hide Suspicious Injections, better use NoMount metamodule
- add: Kernel Version to module description
- drop: webui: Example of detections
- add: new toggle "Spoof OS Patch Level Property"
- add: webui: new section to see Suspicious Mounts
- add: new toggle "Spoof Vendor Security Patch Level Property"
- add: webui: Incompatible Modules again
