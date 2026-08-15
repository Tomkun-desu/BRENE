# Changelog

# BRENE v0.0.60 - Supports SuSFS 2.2.0+

- fix: use the new module id of TEESimulator
- fix: extract base kernel version by matching X.Y.Z pattern
- fix: use ro.product.device instead of ro.build.product
- fix: Device Model Status in other brands like Xiaomi
- improve: move "Hide Suspicious PTYs" to post-fs-data stage
- drop: Android Verified Boot Hash Spoofing
- improve: run "Spoof Android System Properties" before and after the files are accessible in /sdcard
- add: incompatible module "ROD-Manager"
- add: new toggle "Hide Custom Recovery Paths"
- improve: flatten conditional in "Spoof Uname"
- change: disable "Spoof /proc/cmdline or /proc/bootconfig" by default
- add: new toggle "Show Refresh Rate"
- improve: remove some custom rom strings in fingerprint props
- add: new toggle "Fix /data/local/tmp Inconsistencies"
- improve: try to fix some issues with "Spoof libstagefright.so" and "Hide LineageOS Strings"
- bump: version to v0.0.60
