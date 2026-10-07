# Changelog

# Supports SuSFS 2.2.0 and 2.3.0+

- improve: simplify module status
- improve: Spoof Uname: now it is more like a stock kernel release
- improve: WebUI without reboot: reduce waiting time to 1s
- fix: webui: only show default kernel release if spoofing is disabled
- fix: Spoof OS/Vendor Security Patch Level Property: follow TEESimulator behavior
- drop: webui: ROD-Manager module, it is dead
- improve: add brene_open_redirect function
- improve: move "Hide LineageOS Strings" and "Spoof /system/lib64/libstagefright.so" to boot-completed stage to hide detections consistently
- improve: hide LineageOS strings in /system_ext/etc/permissions/Updater.xml
- add: OPEN_REDIRECT support
