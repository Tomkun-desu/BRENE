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

