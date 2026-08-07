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

