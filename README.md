# .BRENE - Custom AI

> An unofficial, community-driven fork of [BRENE](https://github.com/rrr333nnn333/BRENE) by rrr333nnn333 — a SuSFS/KernelSU module for SuSFS-patched kernels.

**Not affiliated with or endorsed by the original author.**

## About

This is an ongoing fork of BRENE. It tracks upstream and layers on
community-requested toggles and fixes over time, with changes made using
AI assistance (Claude). It is not tied to a single upstream version — it
evolves alongside BRENE itself.

For the full list of what's changed at any given point, see
[CHANGELOG.md](./CHANGELOG.md).

The complete original feature set (Path Hiding, Mounts Hiding, AVC Log
Spoofing, AVB Hash Spoofing, Uname Spoofing, ROM Prop Hiding, and more)
is preserved as-is unless a change is explicitly noted in the changelog.

## Requirements

- A SuSFS-patched kernel (KernelSU-Next / KernelSU / APatch)
- A SuSFS version compatible with the current module release

## Installation

1. Download the latest release zip from this repo's [Releases](../../releases) page.
2. Flash it via your KernelSU/APatch manager's module installer.
3. Reboot.
4. Configure toggles from the module's WebUI.

## Credits

- [rrr333nnn333](https://github.com/rrr333nnn333), simonpunk & KOWX712 — original BRENE authors
- Community — fork maintenance and additional toggles

## License

This project is licensed under **AGPL-3.0**, same as the original upstream
project. See [LICENSE](./LICENSE) for details. Source code for this fork,
including all local modifications, is published in this repository in
compliance with the AGPL-3.0 source-availability requirement.
