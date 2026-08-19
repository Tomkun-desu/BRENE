# Changelog

# BRENE v0.0.61 - Supports SuSFS 2.2.0+

- improve: avoids overheat in "Hide Custom ROM Paths" the paths are read-only, use sus path instead of sus path loop
- add: re-implement "Spoof Android Verified Boot Hash"
- drop: selinux props
- drop: ro.kernel.qemu prop
- improve: run "Spoof Android System Properties" in post-fs-data stage
- improve: replace all brene_sus_path calls with brene_sus_path_loop calls
- improve: SuSFS version checks
- add: new toggle "Fix /debug_ramdisk Inconsistencies"
- fix: use 4096 not 512 in the <blksize> field
- refactor: clone_perm function
- improve: brene_clone_perm function
- improve: try to fix some issues in "Fix /data/local/tmp Inconsistencies" and "Fix /debug_ramdisk Inconsistencies"
- improve: add more custom rom paths to "Hide Custom ROM Paths"
- improve: spoof date props
- bump: version to v0.0.61
