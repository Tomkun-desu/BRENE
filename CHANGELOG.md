## v0.0.66-custom.1 - 2026-09-04

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in simple bullet points:

* Added support for hot install.
* Added new config options: `config_paths_hiding__sdcard_android_data_media_obb`, `config_paths_hiding__user_ca_certs`, `config_paths_hiding__sdcard_android_data_media_obb`, `config_uname_spoofing`, `config_hide_suspicious_ptys`, `config_umount_suspicious_mounts`, `config_spoof_hosts`, `config_hide_custom_recovery`, `config_fix_data_local_tmp_inconsistencies`, `config_show_refresh_rate`, `config_disable_child_process_restrictions`, `config_hide_custom_rom_paths_2`, `config_spoof_libstagefright`, `config_verified_boot_hash`, `config_spoof_cmdline_or_bootconfig`, `config_sync_device_props`, `config_custom_uname_spoofing`.
* Changed the behavior of some config options: `config_spoof_uname`, `config_spoof_hosts`, `config_hide_custom_rom_paths`, `config_hide_custom_rom_paths_2`, `config_hide_lineage_strings`.
* Removed some code related to old Integrity-Box based Play Integrity Fix.
* Removed some code related to outdated modules.
* Changed the

## v0.0.65-custom.8 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in plain, simple bullet points:

* Added a new config option: `config_paths_hiding__sdcard_android_data_media_obb`
* Added a new config option: `config_paths_hiding__user_ca_certs`
* Added a new config option: `config_paths_hiding__sdcard_android_data_media_obb`
* Added a new config option: `config_umount_suspicious_mounts`
* Added a new config option: `config_spoof_hosts`
* Added a new config option: `config_hide_custom_recovery`
* Added a new config option: `config_fix_data_local_tmp_inconsistencies`
* Added a new config option: `config_show_refresh_rate`
* Added a new config option: `config_disable_child_process_restrictions`
* Added a new config option: `config_hide_custom_rom_paths_2`
* Added a new config option: `config_custom_uname_spoofing`
* Added a new config option: `config_spoof_libstagefright`
* Added a new config option: `config_verified_boot_hash`
* Added a new config option: `config_sync_device_props`
* Added a new config option: `config_hide_injections`
* Added a

## v0.0.65-custom.7 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes summarized in simple bullet points:

* Added new config options: `config_paths_hiding__sdcard_android_data_media_obb`, `config_paths_hiding__user_ca_certs`, `config_umount_suspicious_mounts`, `config_spoof_hosts`, `config_hide_suspicious_ptys`, `config_spoof_cmdline_or_bootconfig`, `config_sync_device_props`, `config_uname_spoofing`, `config_custom_uname_spoofing`, `config_spoof_libstagefright`, and `config_verified_boot_hash`.
* Removed `config_spoof_uname` and `config_spoof_hosts`.
* Renamed `config_spoof_uname` to `config_uname_spoofing`.
* Renamed `config_spoof_hosts` to `config_spoof_hosts` (but it's now enabled by default).
* Renamed `config_fix_data_local_tmp_inconsistencies` to `config_fix_data_local_tmp_inconsistencies` (no change).
* Renamed `config_spoof_libstagefright` to `config_spoof_libstagefright` (no change).
* Renamed `config_disable_child_process_restrictions` to

## v0.0.65-custom.6 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the code diffs in plain, simple bullet points:

* The customized KernelSU/SuSFS module fork has added the following features:
	+ Paths hiding for /sdcard/Android/[data | media | obb]
	+ User CA certificates hiding
	+ Fix /data/local/tmp inconsistencies
	+ Android Verified Boot Hash spoofing
	+ Injections hiding
	+ Uname spoofing with custom kernel version and release
	+ Build props spoofing across all partitions
* The customized KernelSU/SuSFS module fork has changed the following settings:
	+ Added config_paths_hiding__sdcard_android_data_media_obb=1
	+ Added config_paths_hiding__user_ca_certs=1
	+ Added config_paths_hiding__sdcard_android_data_media_obb=1
	+ Changed config_paths_hiding__non_standard_sdcard_android=1
	+ Changed config_paths_hiding__data_local_tmp=1
	+ Changed config_fix_data_local_tmp_inconsistencies=1
	+ Changed config_hide_injections=1
	+ Changed config_umount_suspicious_mounts=1
	+ Changed config_spoof_hosts=1
	+ Changed config

## v0.0.65-custom.5 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here's a summary of the code diffs in plain, simple bullet points for non-technical readers:

* The module's description and version have been updated.
* The module now supports spoofing the Android Verified Boot Hash property.
* The module's configuration options have been updated to include new features such as hiding custom recovery paths and spoofing the Uname.
* The module now includes a new feature to hide suspicious injections.
* The module's log output has been updated to include more information about the actions being taken.
* The module now includes a new feature to sync device properties across all partitions.
* The module's configuration options have been updated to include new features such as hiding user CA certificates and spoofing the Uname.
* The module's post-fs-data script has been updated to include new features such as spoofing the Uname and hiding custom ROM paths.
* The module's configuration options have been updated to include new features such as hiding custom recovery paths and spoofing the Uname.
* The module's customize script has been updated to include new features such as dropping useless modules and removing old Integrity-Box based Play Integrity Fix.
* The module's module.prop file has been updated to include new information about the module's author and description.
* The module's config

## v0.0.65-custom.4 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes in simple bullet points:

* Added support for hiding suspicious injections.
* Added support for hiding user CA certificates.
* Added support for hiding /sdcard/Android/[data | media | obb] paths.
* Added support for fixing /data/local/tmp inconsistencies.
* Added support for spoofing Android verified boot hash property.
* Added support for custom uname spoofing.
* Added support for syncing device props across all partitions.
* Updated the configuration to include new features and options.
* Updated the module description and name.
* Updated the update JSON URL.
* Removed the outdated modules.
* Removed the old Integrity-Box based Play Integrity Fix.
* Updated the custom_sus_map.txt, custom_sus_mount.txt, and custom_sus_kstat.txt files.
* Updated the post-fs-data.sh script to include new features and options.
* Updated the resetprop command to use the correct path.
* Updated the brene_set_uname function to handle custom uname spoofing.
* Updated the brene_clone_perm function to handle fake files.
* Updated the brene_sus_map and brene_sus_path_loop functions to handle new paths.
* Updated the brene_sus_path function to handle new paths.
* Updated the brene_kernel_um

## v0.0.65-custom.3 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in plain, simple bullet points:

* The module's name has been changed to ".BRENE - Custom AI".
* The module's version has been updated to v0.0.65-custom.2.
* The module's author has been updated to include "simonpunk & KOWX712 + Community".
* The module's update JSON URL has been updated to a new GitHub repository.
* The `config_spoof_uname` and `config_spoof_hosts` options have been removed.
* The `config_spoof_verified_boot_hash` option has been added.
* The `config_fix_data_local_tmp_inconsistencies` option has been added.
* The `config_show_refresh_rate` option has been added.
* The `config_disable_child_process_restrictions` option has been added.
* The `config_hide_custom_rom_paths_2` option has been added.
* The `config_custom_uname_spoofing` option has been added.
* The `config_uname_spoofing` option has been added.
* The `config_spoof_hosts` option has been restored.
* The `config_hide_custom_recovery` option has been restored.
* The `config_sync_device_props

## v0.0.65-custom.2 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in plain, simple bullet points:

* The module has been renamed from ".BRENE - SuSFS" to ".BRENE - Custom AI".
* The version code has been reset to 1.
* The author list has been updated to include "simonpunk & KOWX712 + Community".
* The update JSON URL has been updated to a new repository.
* The module description now includes "[Module Status: ⏱️ | SuSFS Patches: ⏱️]".
* The config file has been updated with new options:
	+ `config_paths_hiding__sdcard_android_data_media_obb=1`
	+ `config_paths_hiding__user_ca_certs=1`
	+ `config_uname_spoofing=1`
	+ `config_hide_suspicious_ptys=1`
	+ `config_umount_suspicious_mounts=1`
	+ `config_spoof_cmdline_or_bootconfig=1`
	+ `config_sync_device_props=0`
	+ `config_custom_uname_spoofing=0`
	+ `config_spoof_libstagefright=0`
	+ `config_verified_boot_hash=''

## v0.0.65-custom.1 - 2026-09-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here's a summary of the changes in plain, simple bullet points:

* Added support for customizing the SuSFS/KernelSU module for SuSFS patched kernels.
* Changed the way the module's status is displayed in the description.
* Added support for spoofing the Android Verified Boot Hash property.
* Added support for fixing inconsistencies in /data/local/tmp.
* Added support for hiding suspicious injections.
* Added support for hiding custom recovery paths.
* Added support for hiding non-standard /sdcard paths.
* Added support for hiding user CA certificates.
* Added support for hiding /sdcard/Android/[data | media | obb] paths.
* Added support for manually-installed user CA certificates.
* Added support for fully synchronizing build-related props across all partitions.
* Added support for customizing the uname spoofing.
* Added support for customizing the uname kernel release and version.
* Changed the way the uname spoofing is handled.
* Added support for hiding lineage strings.
* Added support for hiding custom ROM paths (extreme).
* Added support for hiding custom ROM paths (extreme) in /data/misc, /data/dalvik-cache, and /data/resource-cache.
* Changed the way the module's logs are handled.
* Added support

## v0.0.58-custom.10 - 2026-08-10

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added code to hide custom recovery (TWRP/OrangeFox) leftover folders.
* Added code to hide manually-installed User CA Certificates.
* Added code to sync all build-related props (fingerprint + sub-fields) across all partitions.
* Added code to load custom KSTAT entries from a file.
* Added code to display custom KSTAT entries in the UI.
* Added code to create and remove custom KSTAT entries in the UI.
* Added code to serialize and deserialize custom KSTAT entries.
* Added code to load custom KSTAT entries from the file into the UI.
* Added code to display the custom KSTAT log in the UI.
* Added code to refresh the logs panel when a live action is performed.
* Added code to display a live log message when a live action is performed.
* Added code to compute the auto uname values when the custom uname fields are set to 'default'.
* Added code to apply the custom uname values to the system.
* Added code to reset the custom uname fields to their default values.
* Added code to apply the custom uname values when the apply button is clicked.
* Added code to update the custom uname fields when the custom uname values are changed.
* Added code to display the custom uname fields in the

## v0.0.58-custom.9 - 2026-08-09

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in simple bullet points:

* Added a new feature to hide manually-installed (user) CA certificates from detection.
* Added a new feature to sync product brand, device, manufacturer, model, and name across partitions.
* Added a new feature to spoof uname for all processes.
* Added a new feature to customize kernel release and version.
* Added a new feature to load custom kstat entries.
* Added a new tab to the web interface for managing custom kstat entries.
* Modified the web interface to display logs in real-time.
* Modified the web interface to add a live log feature.
* Modified the web interface to add a button to refresh the log panel.
* Modified the web interface to add a feature to set custom kstat entries.
* Modified the web interface to add a feature to remove custom kstat entries.
* Modified the web interface to add a feature to serialize custom kstat entries.
* Modified the web interface to load custom kstat entries from a file.
* Modified the web interface to display custom kstat entries in a table.
* Modified the web interface to add a feature to save custom kstat entries to a file.
* Modified the web interface to add a feature to load custom kstat entries from a

## v0.0.58-custom.8 - 2026-08-08

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added new feature to hide manually-installed User CA certificates.
* Added new feature to sync device identity across all partitions.
* Added new feature to spoof uname for all processes.
* Added new feature to load custom sus kstat entries from a text file.
* Added new UI elements to support these features.
* Improved the waiting mechanism for /sdcard/Android to become accessible.
* Improved the removal of leftover sus files.
* Removed the need to resetprop the fingerprint and date fields individually.
* Added a new script to sync all build-related props across all partitions.
* Added a new feature to handle custom sus kstat entries.
* Added a new feature to load custom sus kstat entries from a text file.
* Improved the logging mechanism for the module.
* Improved the handling of various errors and exceptions.
* Improved the overall code quality and organization.
* Added new comments and documentation to explain the code.
* Improved the formatting and consistency of the code.
* Added new tests to ensure the code works correctly.

## v0.0.58-custom.7 - 2026-08-07

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added a new configuration option to hide manually-installed user CA certificates from detection.
* Modified the wait loop in boot-completed.sh to retry up to 10 times before giving up.
* Added a new feature to manually-installed user CA certificates.
* Added a new feature to sync device identity across partitions.
* Modified the custom uname spoofing feature to use a more robust method of determining the kernel version.
* Added a new feature to load custom kstat entries from a text file.
* Modified the web interface to include a new tab for kstat entries and a button to add new entries.
* Modified the web interface to include a new feature to serialize and deserialize kstat entries.
* Modified the web interface to include a new feature to load and display kstat log entries.
* Modified the web interface to include a new feature to refresh the log panel.
* Added a new feature to log live actions and refresh the log panel.
* Modified the web interface to include a new feature to compute and display auto uname values.
* Modified the web interface to include a new feature to update the uname values in real-time.
* Modified the web interface to include a new feature to reset the uname values to their default state.
* Modified the web interface to include a new feature

## v0.0.58-custom.6 - 2026-08-07

### Synced from upstream BRENE
- Merge remote-tracking branch 'upstream/main'
- change: disable "Max Saturation" by default

### Local customizations
* Added a new feature to hide manually-installed User CA certificates.
* Modified the custom uname spoofing feature to allow setting custom kernel release and version.
* Added a new feature to sync device identity across partitions.
* Added a new feature to load custom kstat entries from a file.
* Added a new button to add custom kstat entries.
* Modified the web interface to include a new tab for custom kstat entries.
* Modified the web interface to include a new button to remove custom kstat entries.
* Modified the web interface to include a new field to display kstat log entries.
* Added a new function to serialize custom kstat entries.
* Added a new function to load custom kstat entries from a file.
* Modified the web interface to include a new button to apply custom kstat entries.
* Modified the web interface to include a new button to reset custom kstat entries.
* Modified the web interface to include a new button to save custom kstat entries to a file.
* Modified the web interface to include a new button to load custom kstat entries from a file.
* Modified the web interface to include a new button to remove custom kstat entries from the file.
* Modified the web interface to include a new button to update the kstat

## v0.0.58-custom.5 - 2026-08-07

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* The code has added a new feature to hide manually-installed User CA Certificates from detection.
* The code has added a new feature to sync all build-related props (fingerprint + sub-fields) across all partitions.
* The code has added a new feature to add custom entries to the SuSFS KSTAT table.
* The code has added a new feature to load custom SuSFS KSTAT entries from a file.
* The code has updated the web interface to include a new section for customizing User CA Certificates.
* The code has updated the web interface to include a new section for syncing build-related props.
* The code has updated the web interface to include a new section for adding custom SuSFS KSTAT entries.
* The code has updated the web interface to include a new section for loading custom SuSFS KSTAT entries.
* The code has updated the `post-fs-data.sh` script to handle custom Uname spoofing.
* The code has updated the `post-fs-data.sh` script to handle syncing build-related props.
* The code has updated the `service.sh` script to include a new feature to log the SuSFS KSTAT table.
* The code has updated the `utils.sh` script to include a

## v0.0.58-custom.4 - 2026-08-07

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes in simple bullet points:

* The module now hides manually-installed user CA certificates from detection.
* The module now syncs device identity (product brand, device, manufacturer, model, and name) across partitions.
* The module now has a new feature called "Custom Uname Spoofing" which allows users to spoof the uname for all processes.
* The module now has a new feature called "KSTAT" which allows users to add custom kernel statistics.
* The module's config file now has a new option called "config_paths_hiding__user_ca_certs" which controls the new CA certificate hiding feature.
* The module's config file now has a new option called "config_sync_device_props" which controls the new device identity syncing feature.
* The module's config file now has a new option called "config_custom_uname_kernel_release" and "config_custom_uname_kernel_version" which control the new custom uname spoofing feature.
* The module's config file now has a new option called "config_brene_logs" which controls the logging feature.
* The module's post-fs-data script now syncs build-related props (fingerprint and sub-fields) across all partitions.
* The module's web interface now has a new tab

## v0.0.58-custom.3 - 2026-08-07

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* The custom module has added a new feature to hide manually-installed User CA Certificates.
* The custom module has added a new feature to sync device identity across all partitions.
* The custom module has added a new feature to customize the uname string for all processes.
* The custom module has added a new option to the config file to enable the User CA Certificates feature.
* The custom module has added a new option to the config file to enable the device identity sync feature.
* The custom module has added a new option to the config file to customize the uname string.
* The custom module has added a new feature to load custom kstat entries from a file.
* The custom module has added a new feature to save custom kstat entries to a file.
* The custom module has updated the web interface to include options for the new features.
* The custom module has updated the web interface to display the custom kstat entries.
* The custom module has updated the resetprop command to sync device identity across all partitions.
* The custom module has updated the brene_sus_kstat_static function to add custom kstat entries statically.
* The custom module has updated the brene_set_uname function to customize the uname string.
* The custom module has updated the post

## v0.0.58-custom.2 - 2026-08-07

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added a new feature to hide manually-installed User CA Certificates.
* Added a new feature to load custom sus kstat entries from a file.
* Added a new feature to sync device identity props across partitions.
* Added a new feature to spoof kernel version.
* Added a new feature to spoof kernel release.
* Added a new feature to sync build fingerprint props across partitions.
* Added a new feature to sync sub-fields of build fingerprint props across partitions.
* Added a new feature to sync product brand, device, manufacturer, model and name across partitions.
* Added a new feature to sync product sub-fields across partitions.
* Updated the UI to include a new tab for custom sus kstat entries.
* Updated the UI to include a new feature to add and remove custom sus kstat entries.
* Updated the UI to include a new feature to load and save custom sus kstat entries from a file.
* Updated the UI to include a new feature to toggle the sync device identity props feature.
* Updated the UI to include a new feature to toggle the sync product sub-fields feature.
* Updated the UI to include a new feature to toggle the sync build fingerprint props feature.
* Updated the UI to include a new feature to toggle the sync sub-fields of build fingerprint props

## v0.0.58-custom.1 - 2026-08-07

### Synced from upstream BRENE
- Merge remote-tracking branch 'upstream/main'
- bump: version to v0.0.58
- add: new toggle "Max Saturation"

### Local customizations
Here is a summary of the changes in plain, simple bullet points:

* In `boot-completed.sh`, a new wait loop was added to check for the existence of `/sdcard/Android` before proceeding.
* A new section was added to load custom `sus_kstat.txt` files, which contain information about kernel statistics.
* A new section was added to manually install user CA certificates and hide them from detection.
* In `config.sh`, a new option was added to enable hiding of user CA certificates.
* In `customize.sh`, a new file was added to the list of custom files to be created.
* In `module.prop`, the module name and version were updated.
* In `post-fs-data.sh`, a new section was added to fully sync all build-related props across all partitions.
* In `service.sh`, the path to the `resetprop` binary was updated.
* In `utils.sh`, a new function was added to update kernel statistics statically.
* In `webroot/index.html`, a new card was added to display the user CA certificates option and a new tab was added to display the kernel statistics option.
* In `webroot/script.js`, new functions were added to create and serialize kernel statistics entries, and to load kernel

## v0.0.57-custom.12 - 2026-08-07

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added a new feature to hide manually-installed User CA Certificates.
* Modified the wait loop for accessing /sdcard/Android to have a timeout of 10 seconds.
* Added a new feature to sync all build-related props (fingerprint and sub-fields) across all partitions.
* Added a new feature to manually sync device identity (product brand, device, manufacturer, model, and name) across partitions.
* Added a new feature to manually override the kstat (kernel statistics) for specific paths.
* Modified the service.sh script to load custom_sus_kstat.txt and apply the kstat overrides.
* Modified the utils.sh script to include a new function brene_sus_kstat_static to add kstat overrides statically.
* Modified the webroot/index.html file to include a new card for User CA Certificates and a new card for Device Identity Sync.
* Modified the webroot/script.js file to include new actions for User CA Certificates and Device Identity Sync.
* Modified the webroot/styles.css file to include new styles for the new cards.

## v0.0.57-custom.11 - 2026-08-07

### Synced from upstream BRENE
- Merge remote-tracking branch 'upstream/main'
- webui: improve "Device Model" indicator
- refactor: Custom Uname Spoofing

### Local customizations
* Added a new feature to hide manually-installed user CA certificates from detection.
* Modified the wait loop in `boot-completed.sh` to use a counter to prevent infinite waiting.
* Added a new feature to manually install User CA Certificates.
* Added a new feature to sync device identity props across partitions.
* Modified `post-fs-data.sh` to sync device identity props across partitions.
* Added a new feature to allow users to customize kstat entries in `service.sh`.
* Modified `utils.sh` to include a new function `brene_sus_kstat_static` to add kstat entries statically.
* Modified `webroot/index.html` to include a new card for User CA Certificates and a new tab for kstat entries.
* Modified `webroot/script.js` to include new functionality for kstat entries, including creating, serializing, and applying commands.
* Modified `webroot/styles.css` to fix toggle alignment on cards with long multi-line descriptions and to force long unbroken paths to wrap instead of overflowing past the toggle.
* Updated the module's version and author in `module/module.prop`.
* Updated the module's config in `module/config.sh` to include a new option for syncing device identity props.
* Updated the module's

## v0.0.57-custom.10 - 2026-08-07

### Synced from upstream BRENE
- Merge remote-tracking branch 'upstream/main'
- add: new toggle "Hide LineageOS Strings"
- improve: delete more props
- improve: spoof more props
- webui: add "Device Model" indicator

### Local customizations
- Added a new configuration option `config_paths_hiding__user_ca_certs` to hide manually-installed user CA certificates.
- Added a new configuration option `config_sync_device_props` to sync device identity properties across partitions.
- Modified the `boot-completed.sh` script to wait for the `/sdcard/Android` directory to be accessible before proceeding.
- Added a new feature to the `post-fs-data.sh` script to sync device identity properties across partitions.
- Added a new feature to the `utils.sh` script to add a static kernel stat entry for a given path.
- Modified the `webroot/index.html` file to add a new card for user CA certificates and a new tab for kernel stat entries.
- Modified the `webroot/script.js` file to add a new feature to load and apply kernel stat entries from a file.
- Modified the `webroot/styles.css` file to fix toggle alignment on cards with long multi-line descriptions and to force long unbroken paths to wrap instead of overflowing past the toggle.

## v0.0.57-custom.9 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here's a summary of the changes in plain, simple bullet points:

* Added a new feature to hide manually-installed user CA certificates from detection.
* Added a new feature to sync product brand, device, manufacturer, model, and name across partitions.
* Added a new tab in the web interface for managing user CA certificates.
* Added a new tab in the web interface for syncing device identity.
* Modified the `boot-completed.sh` script to wait up to 10 seconds for the `/sdcard/Android` directory to become accessible.
* Modified the `boot-completed.sh` script to add a new feature for manually-installed user CA certificates.
* Modified the `boot-completed.sh` script to add a new feature for syncing custom kstat entries.
* Modified the `post-fs-data.sh` script to sync build-related props across all partitions.
* Modified the `config.sh` script to add a new configuration option for user CA certificates.
* Modified the `config.sh` script to add a new configuration option for syncing device identity.
* Modified the `customize.sh` script to add a new file for custom kstat entries.
* Modified the `module.prop` file to update the module name and version.
* Modified the `webroot/index.html

## v0.0.57-custom.9 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* The local fork added a new feature to hide manually-installed User CA Certificates in the /data/misc/user/* directory.
* The local fork added a new feature to spoof build fingerprint fields across all partitions to match the main ro.build.fingerprint.
* The local fork added a new feature to load custom stat entries statically from a file.
* The local fork added a new option to the config to enable or disable syncing device props.
* The local fork added a new option to the config to enable or disable hiding user CA certificates.
* The local fork added a new option to the config to enable or disable syncing device props.
* The local fork updated the module's name, version, and author in the module.prop file.
* The local fork updated the module's update URL in the module.prop file.
* The local fork updated the module's description in the module.prop file.
* The local fork updated the webroot/index.html file to include a new card for User CA Certificates and a new card for device identity sync.
* The local fork updated the webroot/script.js file to include new functions for loading and serializing custom stat entries.
* The local fork updated the webroot/styles.css file to fix toggle alignment on cards with long multi-line descriptions and to

## v0.0.57-custom.8 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes in simple bullet points:

* The module now hides manually-installed User CA Certificates from detection.
* A new feature was added to sync build-related props (fingerprint and sub-fields) across all partitions.
* The module now logs when build props are spoofed.
* The module's name has been changed to ".BRENE - Custom AI".
* The module's version has been updated to "v0.0.57-custom.8".
* The author of the module has been updated to include the community.
* The update URL has been updated.
* The module's description has been updated.
* The module now logs when User CA Certificates are hidden.
* The module's configuration has been updated to include a new option to hide User CA Certificates.
* The module's configuration has been updated to include a new option to sync build props.
* A new tab has been added to the module's web interface to manage custom kernel stat entries.
* A new field has been added to the module's configuration to manage custom kernel stat entries.
* The module's web interface has been updated to display custom kernel stat entries.
* The module's web interface has been updated to allow users to add and remove custom kernel stat entries.
* The module

## v0.0.57-custom.8 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in plain, simple bullet points:

* Added a new feature to hide manually-installed user CA certificates.
* Added a new feature to sync build props across all partitions.
* Added a new tab to the web interface to manage custom kstat entries.
* Added a new option to the config file to enable syncing build props.
* Updated the boot-completed script to wait for the /sdcard/Android directory to be accessible.
* Updated the post-fs-data script to sync build props across all partitions.
* Updated the web interface to display the new features and options.
* Updated the styles.css file to fix toggle alignment on cards with long multi-line descriptions.
* Updated the script.js file to add functionality for creating, editing, and removing custom kstat entries.
* Updated the module.prop file to change the module name and version.
* Updated the config.sh file to add a new option to enable syncing build props.
* Updated the customize.sh file to add a new file to the list of customizable files.
* Removed the "..5.u.S" leftover file.
* Updated the webroot/index.html file to add a new card row for user CA certificates and build props spoofing.
* Updated the webroot/script.js file to add functionality

## v0.0.57-custom.8 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes in simple bullet points:

* Added a new feature to hide manually-installed (user) CA certificates from detection.
* Added a new feature to sync build fingerprint fields across all partitions to match the main ro.build.fingerprint.
* Added a new tab in the web interface to manage custom kstat entries.
* Added a new option to the config file to enable syncing build props.
* Modified the boot-completed script to add custom kstat entries statically.
* Modified the post-fs-data script to sync build props across all partitions.
* Modified the web interface to display the new features and options.
* Modified the script.js file to add functionality for the new features.
* Modified the styles.css file to fix alignment issues on cards with long multi-line descriptions.
* Modified the module.prop file to update the module's name and version.
* Modified the customize.sh file to add the new custom_sus_kstat.txt file to the list of customizable files.
* Modified the config.sh file to add the new config_paths_hiding__user_ca_certs option.

## v0.0.57-custom.7 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added a new feature to hide manually-installed user CA certificates from detection.
* Added a new feature to sync build fingerprint fields across all partitions to match the main ro.build.fingerprint.
* Added a new feature to load custom kstat entries statically from a file.
* Modified the wait loop in boot-completed.sh to limit the number of attempts.
* Modified the path hiding in boot-completed.sh to handle the '..5.u.S' leftover file.
* Modified the custom kstat entries handling in post-fs-data.sh to handle empty lines and comments.
* Modified the custom kstat entries handling in post-fs-data.sh to handle fields with default values.
* Modified the custom kstat entries handling in post-fs-data.sh to handle fields with non-default values.
* Modified the custom kstat entries handling in post-fs-data.sh to handle fields with default values.
* Modified the custom kstat entries handling in post-fs-data.sh to handle fields with non-default values.
* Modified the custom kstat entries handling in post-fs-data.sh to handle fields with default values.
* Modified the custom kstat entries handling in post-fs-data.sh to handle fields with non-default values.
* Modified the custom kstat entries handling in post-fs-data.sh

## v0.0.57-custom.6 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes in plain, simple bullet points:

* Added a new feature to hide manually-installed User CA Certificates.
* Added a new feature to load custom kstat values from a file named `custom_sus_kstat.txt`.
* Added a new config option to hide User CA Certificates.
* Added a new config option to sync build props across all partitions.
* Added a new option to the web interface to sync build props.
* Added a new option to the web interface to spoof uname for all processes.
* Updated the `boot-completed.sh` script to wait for the `/sdcard/Android` directory to be accessible before proceeding.
* Updated the `post-fs-data.sh` script to sync build props across all partitions.
* Updated the `module.prop` file to reflect the new features and changes.
* Updated the `webroot/index.html` file to include a new card row for build prop spoofing.
* Updated the `webroot/script.js` file to include a new option for build prop spoofing.
* Removed the `updateJson` field from the `module.prop` file, as it is no longer used.
* Updated the `module/customize.sh` script to include a new file named `custom_sus_kstat

## v0.0.57-custom.6 - 2026-08-06

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here is a summary of the changes in plain, simple bullet points:

* Added a new feature to hide manually-installed User CA Certificates from detection.
* Added a new feature to sync build-related props (fingerprint and sub-fields) across all partitions.
* Added a new tab to the web interface for managing custom inodes (KSTAT).
* Added a new field to the configuration file to enable syncing build props.
* Added a new field to the configuration file to enable hiding User CA Certificates.
* Modified the boot-completed script to wait for a maximum of 10 seconds for /sdcard/Android to be accessible.
* Modified the post-fs-data script to sync build props only during the first 2 minutes after boot.
* Added a new entry to the web interface for managing custom inodes (KSTAT).
* Modified the web interface to display the custom inodes (KSTAT) feature.
* Modified the script.js file to handle the custom inodes (KSTAT) feature.
* Added a new feature to load custom inodes (KSTAT) from a file.
* Added a new feature to save custom inodes (KSTAT) to a file.
* Modified the configuration file to include a new option for enabling custom inodes (K

## v0.0.57-custom.5 - 2026-08-05

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here are the changes in simple bullet points:

* Added code to hide manually-installed user CA certificates from detection in boot-completed.sh.
* Added new configuration option `config_paths_hiding__user_ca_certs` to enable hiding user CA certificates in config.sh.
* Added new file `custom_sus_kstat.txt` to store custom kernel statistics in customize.sh.
* Added new tab "KSTAT" to the settings page in webroot/index.html to manage custom kernel statistics.
* Added new option to sync build props across all partitions in post-fs-data.sh.
* Updated module metadata in module.prop to reflect changes.
* Added new feature to hide manually-installed user CA certificates in the settings page in webroot/index.html.
* Added new option to sync build props in the settings page in webroot/index.html.
* Updated the settings page in webroot/index.html to include new options and features.
* Added new code to handle custom kernel statistics in boot-completed.sh.
* Updated the code to handle custom kernel statistics in post-fs-data.sh.

## v0.0.57-custom.4 - 2026-08-05

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
Here's a summary of the changes in simple bullet points:

* A new feature was added to hide manually-installed User CA Certificates from detection.
* A new config option was added to hide User CA Certificates.
* A new config option was added to sync build props across all partitions.
* A new feature was added to load custom kstat entries from a file.
* A new config option was added to enable loading custom kstat entries.
* A new tab was added to the web interface to manage custom kstat entries.
* A new button was added to the web interface to add new custom kstat entries.
* A new section was added to the web interface to manage build prop spoofing.
* The module name, version, and author were updated in the module.prop file.
* The update JSON URL was updated in the module.prop file.
* A new feature was added to fully sync all build-related props across all partitions.
* A new feature was added to resetprop build fingerprint fields across all partitions.
* A new section was added to the post-fs-data.sh script to sync build props.
* A new feature was added to log sync prop operations in the logs.txt file.
* A new section was added to the webroot/index.html file to display

## v0.0.57-custom.3 - 2026-08-04

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added a feature to manually hide user-installed CA certificates from detection.
* Added an option to sync build props (fingerprint and sub-fields) across all partitions to match the main ro.build.fingerprint.
* Added a new setting to the web interface for user CA certificates.
* Added a new setting to the web interface for build props spoofing.
* Updated the module's name, version, and author information in the module.prop file.
* Updated the update JSON URL in the module.prop file.
* Updated the module's description in the module.prop file.
* Added a new script to the post-fs-data.sh file to sync build props.
* Updated the script.js file to include new settings for user CA certificates and build props spoofing.

## v0.0.57-custom.2 - 2026-08-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* Added a new configuration option `config_sync_build_props` to enable syncing of build props across partitions.
* Added a new feature to fully sync all build-related props (fingerprint + sub-fields) across all partitions when `config_sync_build_props` is enabled.
* Modified the `post-fs-data.sh` script to include the new build prop syncing feature.
* Added a new UI element to the `index.html` file to display the build prop syncing feature.
* Added a new UI element to the `index.html` file to display a card for build prop syncing.
* Added a new UI element to the `script.js` file to handle the build prop syncing feature.
* Changed the `module.prop` file to include a new author and updated version information.
* Changed the `module.prop` file to include a new name and updated version code.
* Removed the `MODULE_HOT_INSTALL_REQUEST` export from the `customize.sh` file.
* Changed the `customize.sh` file to remove the hot install support check.
* Changed the `module.prop` file to update the update JSON URL.

## v0.0.57-custom.1 - 2026-08-03

### Synced from upstream BRENE
- (manual rebuild, no new upstream commits)

### Local customizations
* The module's name and version were changed to include 'Custom AI' and 'v0.0.57-custom.1' respectively.
* The author's name was updated to include 'Community' in addition to the original authors.
* The update JSON URL was changed from 'rrr333nnn333' to 'Tomkun-desu'.
* A new feature was added to fully sync build-related props across all partitions.
* A new setting was added to the web interface to control the build prop syncing feature.
* A new setting was added to the web interface to control custom uname spoofing.
* The list of settings in the web interface was updated to include the new settings.

