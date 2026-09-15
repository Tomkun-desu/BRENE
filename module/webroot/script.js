import { exec, toast } from './assets/kernelsu.js'
import './assets/mwc.js'

document.querySelector('div.preload-hidden').classList.remove('preload-hidden')

const MODDIR = '/data/adb/modules/brene'
const PERSISTENT_DIR = '/data/adb/brene'
const configs = [
	// { id: 'hide_modules_img' },
	{
		id: 'hide_sus_mnts_for_non_su_procs',
		action: (enabled) => setFeature(`susfs hide_sus_mnts_for_non_su_procs ${enabled ? 1 : 0}`),
	},
	{
		id: 'su_compat',
		action: (enabled) => setFeature(`ksud feature set su_compat ${enabled ? 1 : 0} && ksud feature save`),
	},
	{
		id: 'kernel_umount',
		action: (enabled) => setFeature(`ksud feature set kernel_umount ${enabled ? 1 : 0} && ksud feature save`),
	},
	{
		id: 'selinux_hide',
		action: (enabled) => setFeature(`ksud feature set selinux_hide ${enabled ? 1 : 0} && ksud feature save`),
	},
	{
		id: 'developer_options',
		action: (enabled) => setFeature(`settings put global development_settings_enabled ${enabled ? 1 : 0}`),
	},
	{
		id: 'usb_debugging',
		action: (enabled) => setFeature(`settings put global adb_enabled ${enabled ? 1 : 0}`),
	},
	{
		id: 'wireless_debugging',
		action: (enabled) => setFeature(`settings put global adb_wifi_enabled ${enabled ? 1 : 0}`),
	},
	{
		id: 'selinux',
		action: (enabled) => setFeature(`setenforce ${enabled ? 1 : 0}`),
	},
	{
		id: 'saturation',
		action: (enabled) => setFeature(`service call SurfaceFlinger 1022 f ${enabled ? 2.0 : 1.0}`),
	},
    {
            id: 'show_refresh_rate',
            action: (enabled) => setFeature(`service call SurfaceFlinger 1034 i32 ${enabled ? 1 : 0}`),
    },
     {
             id: 'disable_child_process_restrictions',
             action: (enabled) => setFeature(`resetprop -n persist.sys.fflag.override.settings_enable_monitor_phantom_procs ${enabled ? false : true}`),
     },
	{ id: 'pif_props' },
	{ id: 'rom_props' },
	{ id: 'brene_logs' },
	{ id: 'enable_log' },
	{ id: 'hide_addon_d' },
	{ id: 'uname_spoofing' },
	{ id: 'hide_injections' },
	{ id: 'hide_suspicious_ptys' },
	{ id: 'hide_lineage_strings' },
	{ id: 'hide_custom_rom_paths' },
	{ id: 'hide_custom_rom_paths_2' },
	{ id: 'custom_uname_spoofing' },
	{ id: 'hide_framework_res_apk' },
	{ id: 'spoof_libstagefright' },
	{ id: 'enable_avc_log_spoofing' },
	{ id: 'umount_suspicious_mounts' },
	{ id: 'spoof_cmdline_or_bootconfig' },
     { id: 'spoof_hosts' },
	{
		id: 'spoof_system_properties',
		action: (enabled) => {
			if (!enabled) return
			if (!confirm('Sync device properties now?')) return
			return setFeature(`RESETPROP="";for c in /data/adb/ksu/bin/resetprop /data/adb/magisk/resetprop /data/adb/ap/bin/resetprop;do [ -x "$c" ]&&RESETPROP="$c"&&break;done;[ -z "$RESETPROP" ]&&exit 1;MFP=$(getprop ro.build.fingerprint);MFP="\${MFP//userdebug/user}";MID=$(getprop ro.build.id);MREL=$(getprop ro.build.version.release);MSDK=$(getprop ro.build.version.sdk);MSDKF=$(getprop ro.build.version.sdk_full);MINC=$(getprop ro.build.version.incremental);MRC=$(getprop ro.build.version.release_or_codename);MDT=$(getprop ro.build.date);MDTU=$(getprop ro.build.date.utc);MSP=$(getprop ro.build.version.security_patch);MTG=$(getprop ro.build.tags);MTP=$(getprop ro.build.type);MBR=$(getprop ro.product.brand);MDEV=$(getprop ro.product.device);MMF=$(getprop ro.product.manufacturer);MMD=$(getprop ro.product.model);MNM=$(getprop ro.product.name);for part in $(getprop|grep -oE '^\\[ro\\.[a-z0-9_]+\\.build\\.fingerprint\\]'|sed -E 's/^\\[ro\\.([a-z0-9_]+)\\.build\\.fingerprint\\]$/\\1/');do [ "$part" = build ]&&continue;[ "$part" = bootimage ]&&continue;for f in fingerprint id version.release version.sdk version.incremental version.release_or_codename version.sdk_full date date.utc version.security_patch tags type;do pn="ro.\${part}.build.\${f}";cv=$(getprop "$pn");[ -z "$cv" ]&&continue;case "$f" in fingerprint)nv="$MFP";;id)nv="$MID";;version.release)nv="$MREL";;version.sdk)nv="$MSDK";;version.incremental)nv="$MINC";;version.release_or_codename)nv="$MRC";;version.sdk_full)nv="$MSDKF";;date)nv="$MDT";;date.utc)nv="$MDTU";;version.security_patch)nv="$MSP";;tags)nv="$MTG";;type)nv="$MTP";;esac;[ "$cv" != "$nv" ]&&timeout 3 "$RESETPROP" "$pn" "$nv" 2>/dev/null;done;for f in brand device manufacturer model name;do pn="ro.product.\${part}.\${f}";cv=$(getprop "$pn");[ -z "$cv" ]&&continue;case "$f" in brand)nv="$MBR";;device)nv="$MDEV";;manufacturer)nv="$MMF";;model)nv="$MMD";;name)nv="$MNM";;esac;[ "$cv" != "$nv" ]&&timeout 3 "$RESETPROP" "$pn" "$nv" 2>/dev/null;done;done;echo done`)
		},
	},
	{ id: 'spoof_system_properties_repeat' },

	{ id: 'paths_hiding__non_standard_sdcard' },
	{ id: 'paths_hiding__non_standard_sdcard_android' },
	{ id: 'hide_custom_recovery' },
	{ id: 'paths_hiding__data_local_tmp' },
     { id: 'fix_data_local_tmp_inconsistencies' },
	{
		id: 'paths_hiding__user_ca_certs',
		action: (enabled) => {
			if (!enabled) return
			setFeature(`for i in /data/misc/user/*/cacerts-added/*; do [ -e "$i" ] && /data/adb/ksu/bin/susfs add_sus_path_loop "$i"; done; for d in /data/misc/user/*/cacerts-added; do [ -d "$d" ] || continue; s=$(stat -c "%i %d %h %s %b %B" "$d" 2>/dev/null); [ -z "$s" ] && continue; set -- $s; /data/adb/ksu/bin/susfs add_sus_kstat_statically "$d" "$1" "$2" "$3" "$4" default default default default default default "$5" "$6"; /data/adb/ksu/bin/susfs update_sus_kstat "$d"; done; echo done`)
		},
	},
	{ id: 'paths_hiding__sdcard_android_data_media_obb' },
]

// Open URLs
document.querySelectorAll('a[href]').forEach((element) => {
	element.addEventListener('click', (event) => {
		event.preventDefault()
		const url = element.href
		if (!/^https:\/\/(github\.com|gitlab\.com|raw\.githubusercontent\.com)\//.test(url)) return
		const safeUrl = `'${url.replace(/'/g, "'\\''")}'`
		exec(`am start -a android.intent.action.VIEW -d ${safeUrl}`)
	})
})

// Load Android Version
exec('resetprop ro.build.version.release && resetprop ro.build.version.sdk').then((result) => {
	const container = document.querySelector('#android-version .card-row__sub')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load'
		return
	}
	const results = result.stdout.replaceAll('\n', ' ')
	const splits = results.split(' ')
	container.innerText = `${splits[0]} (API ${splits[1]}) | SDK ${splits[1]}`
})

// Load SuSFS Variant
exec('susfs show variant').then((result) => {
	const container = document.querySelector('#susfs-variant .card-row__sub')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load'
		return
	}
	container.innerText = result.stdout
})

// Load Kernel Version
exec("cat /proc/version | awk '{print $3}' && uname -r").then((result) => {
	const container = document.querySelector('#kernel-version .card-row__sub')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load'
		return
	}
	container.innerText = `Default: ${result.stdout.replace('\n', '\nSpoofed: ')}`
})

// Load Device Model Status
exec('resetprop ro.product.manufacturer && resetprop ro.product.model && resetprop ro.product.device').then((result) => {
	const container = document.querySelector('#device-model .card-row__sub')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load'
		return
	}
	let model
const splits = result.stdout.split('\n')

exec('resetprop ro.product.marketname')
        .then((result) => {
                if (result.errno !== 0) { return }
                model = result.stdout
        })
        .then(() => {
                model = model || splits[1]
                container.innerText = `${splits[0]} ${model} | ${splits[2]}`
        })
})

// Load Custom ROM Status
exec('[[ -n "$(find /system -iname "*lineage*")" ]] && echo "Yes" || echo "No"').then((result) => {
	const container = document.querySelector('#custom-rom .card-row__sub')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load'
		return
	}
	container.innerText = result.stdout
})

// Load ..5.u.S Status
exec('[[ -e /sdcard/..5.u.S || -e /sdcard/Android/data/..5.u.S || -e /sdcard/Android/media/..5.u.S || -e /sdcard/Android/obb/..5.u.S ]] && echo "Abnormal" || echo "Normal"').then((result) => {
	const container = document.querySelector('#sus-status .card-row__sub')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load'
		return
	}
	container.innerText = result.stdout
})

// Recommended Modules
exec('ksud module list').then((result) => {
	if (result.errno !== 0) { return }

	const container = document.querySelector('#recommended-modules')
	let modules
	try {
		modules = JSON.parse(result.stdout)
	} catch (e) { return }
	if (!Array.isArray(modules)) return
	const moduleIds = modules.map((mod) => mod.id)
	const cardRows = container.querySelectorAll('.card-row')

	cardRows.forEach((row) => {
		const moduleKey = row.getAttribute('data-module')
		const statusSpan = row.querySelector('.status-text')

		if (moduleIds.includes(moduleKey)) {
			statusSpan.innerText = 'Status: Installed'
			statusSpan.style.color = '#4CAF50'
		}
	})

	exec('[[ -e /data/adb/modules/TA_utl ]]').then((result) => {
		if (result.errno !== 0) { const _se = String(result.stderr||''); if (_se === '' || /No such file/i.test(_se)) return; toast('load failed: '+_se.slice(0,120)); return }

		const card = document.querySelector('[data-module="tricky_addon"]')
		const statusSpan = card.querySelector('.status-text')
		statusSpan.innerText = 'Status: Installed'
		statusSpan.style.color = '#4CAF50'
	})
})

// Load enabled features
exec('susfs show enabled_features').then((result) => {
	const container = document.getElementById('kernel-features-container')

	if (result.errno !== 0) {
		container.innerText = 'Failed to load enabled features'
		return
	}
	container.innerText = result.stdout.replaceAll('CONFIG_KSU_SUSFS_', '')
})

// Display-only truncation: keep last full lines (drop partial first line)
function cutToLastFullLines(s, max) {
	s = String(s ?? '')
	if (s.length <= max) return s
	let cut = s.slice(-max)
	const nl = cut.indexOf('\n')
	if (nl !== -1) cut = cut.slice(nl + 1)
	try {
		if (cut.length > 0) {
			const c = cut.charCodeAt(0)
			if (c >= 0xDC00 && c <= 0xDFFF) {
				cut = cut.slice(1)
			} else if (c >= 0xD800 && c <= 0xDBFF) {
				const c2 = cut.length > 1 ? cut.charCodeAt(1) : NaN
				if (!(c2 >= 0xDC00 && c2 <= 0xDFFF)) cut = cut.slice(1)
			}
		}
	} catch (e) {}
	return cut + '\n…(truncated, showing last full lines)'
}

// Load logs once
;(async () => {
        const container = document.getElementById('logs')
        container.textContent = ''
        const MAX = 65536

        const r1 = await exec(`cat ${PERSISTENT_DIR}/log.txt`)
        if (r1.errno !== 0) {
                container.textContent += 'Failed to load logs'
                return
        }
        let out1 = r1.stdout || ''
        if (out1.length > MAX) out1 = cutToLastFullLines(out1, MAX)
        container.textContent += '=== log.txt ===\n'
        container.textContent += out1
        container.textContent += '\n=== logs.txt ===\n'

        const r2 = await exec(`cat ${PERSISTENT_DIR}/logs.txt`)
        if (r2.errno !== 0) {
                container.textContent += 'Failed to load logs'
                return
        }
	let out2 = r2.stdout || ''
	if (out2.length > MAX) out2 = cutToLastFullLines(out2, MAX)
	container.textContent += out2
})().catch(() => {})

// Load brene version
exec(`grep "^version=" ${MODDIR}/module.prop | cut -d'=' -f2`).then((result) => {
	const element = document.getElementById('brene-version')
	element.innerText = result.errno === 0 ? result.stdout : 'unknown'
})

// Load susfs version
exec('susfs show version').then((result) => {
	const element = document.getElementById('susfs-version')
	element.innerText = result.errno === 0 ? `${result.stdout}+` : 'unknown'
})

// Helper function to update config
function sedReplacementEscape(s) {
	return String(s).replace(/\\/g, '\\\\').replace(/\//g, '\\/').replace(/&/g, '\\&').replace(/"/g, '\\"').replace(/\$/g, '\\$').replace(/`/g, '\\`').replace(/!/g, '\\!').replace(/[\r\n]+/g, ' ').replace(/'/g, "'\\''")
}
const norm=p=>p.replace(/\/+/g,'/').replace(/\/$/,'')||'/'
function findInvalidSusPath(content) {
	let bad = null
	String(content ?? '').split('\n').forEach((raw) => {
		if (bad !== null) return
		const line = String(raw).trim()
		if (line === '' || line.startsWith('#')) return
		if (/[\t\r\n]/.test(raw)) { bad = line || raw; return }
		if (!line.startsWith('/')) { bad = line; return }
		if (/\.\.(\/|$)/.test(line)) { bad = line; return }
		const n = norm(line)
		if (n === '/' || n === '/system' || n === '/data' || n === '/vendor') { bad = line; return }
	})
	return bad
}
function isValidUnameRelease(v) {
	if (v === 'default') return true
	return /^[A-Za-z0-9][A-Za-z0-9._+~\-]{0,127}$/.test(v)
}
function isValidUnameVersion(v) {
	if (v === 'default') return true
	return /^[A-Za-z0-9#][A-Za-z0-9 #(),.:+_~@\-]{0,255}$/.test(v)
}
function isValidConfigValue(config, value) {
	const v = String(value)
	if (config === 'config_custom_uname_kernel_release') return isValidUnameRelease(v)
	if (config === 'config_custom_uname_kernel_version') return isValidUnameVersion(v)
	if (config.indexOf('verified_boot_hash') !== -1) {
		return /^[0-9a-fA-F]{64}$/.test(v.trim())
	}
	return true
}
function updateConfig(config, value) {
	if (!isValidConfigValue(config, value)) {
		toast('Invalid config value')
		return
	}
	const safeValue = sedReplacementEscape(value)
	exec(`sed -i "s/^${config}=.*/${config}=${safeValue}/" ${PERSISTENT_DIR}/config.sh`).then((result) => {
		exec(`grep -q "^${config}=" ${PERSISTENT_DIR}/config.sh || echo "${config}='${safeValue}'" >> ${PERSISTENT_DIR}/config.sh`)
		if (result.errno !== 0) toast('Failed to update config')
	})
}

// quoted config writer
// Helper function to update config
function updateConfig2(config, value) {
	if (!isValidConfigValue(config, value)) {
		toast('Invalid config value')
		return
	}
	const safeValue = sedReplacementEscape(value)
	exec(`sed -i "s/^${config}=.*/${config}='${safeValue}'/" ${PERSISTENT_DIR}/config.sh`).then((result) => {
		exec(`grep -q "^${config}=" ${PERSISTENT_DIR}/config.sh || echo "${config}='${safeValue}'" >> ${PERSISTENT_DIR}/config.sh`)
		if (result.errno !== 0) toast('Failed to update config')
	})
}

// Helper function to set config immedialtely that no need to reboot
function setFeature(cmd) {
	return exec(cmd).then((result) => {
		toast(result.errno === 0 ? 'No need to reboot' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
		return result
	})
}

// Load config and add toggle event
document.querySelectorAll('md-switch').forEach((el) => { el.disabled = true })
exec(`cat ${PERSISTENT_DIR}/config.sh`).then((result) => {
	if (result.errno !== 0) {
		toast('Failed to load config')
		document.querySelectorAll('md-switch').forEach((el) => { el.disabled = false })
		return
	}

	const configValues = Object.fromEntries(
		result.stdout
			.split('\n')
			.filter((line) => line.includes('='))
			.map((line) => {
				const [key, ...val] = line.split('=')
				return [
					key.trim(),
					val
						.join('=')
						.trim()
						.replace(/^['"](.*)['"]$/, '$1'),
				]
			}),
	)

	// custom uname
	document.getElementById('custom_uname_release').value = configValues['config_custom_uname_kernel_release'] ?? ''
	document.getElementById('custom_uname_version').value = configValues['config_custom_uname_kernel_version'] ?? ''

	// Verified Boot Hash
	document.getElementById('verified_boot_hash_text_field').value = configValues['config_verified_boot_hash'] ?? ''

	// toggle
	configs.forEach((config) => {
		const configId = `config_${config.id}`
		const element = document.getElementById(config.id)
		if (!element) return

		const value = configValues[configId]
		if (value !== undefined) {
			element.selected = parseInt(value) === 1
		}

		element.addEventListener('change', async () => {
			const enabled = element.selected
			const newConfigValue = +enabled
			updateConfig(configId, newConfigValue)
			if (config.action) {
				await config.action(enabled)
			}
		})
	})
	document.querySelectorAll('md-switch').forEach((el) => { el.disabled = false })
}).catch(() => { document.querySelectorAll('md-switch').forEach((el) => { el.disabled = false }) })

// Manual Kernel Umount
;(async () => {
	const mountField = document.getElementById('custom_kernel_umount_text_field')
	const applyButton = document.getElementById('kernel_umount_apply_button')
	applyButton.disabled = true
	let truncated = false

	// Load all content
	exec(`cat ${PERSISTENT_DIR}/custom_kernel_umount.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated = true; out = out.slice(-MAX) + '\n…(truncated)' }
		mountField.value = result.errno === 0 ? `${out}` : ''
	}).finally(() => { applyButton.disabled = false })

	applyButton.onclick = () => {
		if (truncated) { toast('File too large, not saved'); return }
		let file = 'custom_kernel_umount.txt'
		let content = mountField.value
		const MAX = 65536
		if (content.length > MAX) { toast('File too large, not saved'); return }
		const badPath = findInvalidSusPath(content)
		if (badPath !== null) { toast('Invalid path: '+String(badPath).slice(0,80)); return }

		if (file) {
			if (content === '') {
				exec(`printf '' > ${PERSISTENT_DIR}/${file}`).then((result) => {
					toast(result.errno === 0 ? 'Success' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
				})
			} else {
				const eofRand = window.crypto && window.crypto.getRandomValues ? crypto.getRandomValues(new Uint32Array(1))[0] : Math.floor(Math.random() * 4294967295)
				const eof = 'EOF_' + Date.now().toString(36) + Math.floor(eofRand / 1000).toString(36)
				if (content.split('\n').some((line) => line === eof)) {
					toast('Refusing to write: content contains delimiter')
					return
				}
				exec(`
cat <<'${eof}' > ${PERSISTENT_DIR}/${file}
${content}
${eof}
				`).then((result) => {
					toast(result.errno === 0 ? 'Success' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
				})
			}
		}
	}
})()

// Reset Settings
const resetDialog = document.getElementById('reset_settings_dialog')
const resetButton = document.getElementById('reset_settings')

if (resetDialog && resetButton) {
        resetButton.addEventListener('click', () => {
                resetDialog.show()
        })

        resetDialog.addEventListener('close', () => {
                if (resetDialog.returnValue !== 'confirm') return

                exec(`cp -f ${MODDIR}/config.sh ${PERSISTENT_DIR}`).then((result) => {
                        if (result.errno !== 0) {
                                toast(result.stderr)
                                return
                        }

                        exec(`cat ${PERSISTENT_DIR}/config.sh`).then((configResult) => {
                                if (configResult.errno !== 0) {
                                        toast('Failed to reload config')
                                        return
                                }

                                const freshConfigValues = Object.fromEntries(
                                        configResult.stdout
                                                .split('\n')
                                                .filter((line) => line.includes('='))
                                                .map((line) => {
                                                        const [key, ...val] = line.split('=')
                                                        return [
                                                                key.trim(),
                                                                val
                                                                        .join('=')
                                                                        .trim()
                                                                        .replace(/^['"](.*)['"]$/, '$1'),
                                                        ]
                                                }),
                                )

                                configs.forEach((config) => {
                                        const configId = `config_${config.id}`
                                        const element = document.getElementById(config.id)
                                        if (!element) return

                                        const value = freshConfigValues[configId]
                                        if (value !== undefined) {
                                                element.selected = parseInt(value) === 1
                                        }
                                })

                                document.getElementById('custom_uname_release').value =
                                        freshConfigValues['config_custom_uname_kernel_release'] ?? ''
                                document.getElementById('custom_uname_version').value =
                                        freshConfigValues['config_custom_uname_kernel_version'] ?? ''
                                document.getElementById('verified_boot_hash_text_field').value =
                                        freshConfigValues['config_verified_boot_hash'] ?? ''

                                toast('Success')
                        })
                })
        })
}

// KSU Module Control
;(async () => {
	const enableButton = document.getElementById('enable_ksu_modules')
	const disableButton = document.getElementById('disable_ksu_modules')

	const toggleAllModules = (enable) => {
		if (!confirm(enable ? 'Enable all KernelSU modules?' : 'Disable all KernelSU modules?')) return
		exec(`
			for i in /data/adb/modules/*; do
				[ "$i" = "${MODDIR}" ] && continue
				[ "$(basename "$i")" = "brene" ] && continue
				${enable ? 'rm -f' : 'touch'} "$i/disable"
			done
		`).then((result) => {
			toast(result.errno === 0 ? 'Success' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
		})
	}

	enableButton.addEventListener('click', () => toggleAllModules(true))
	disableButton.addEventListener('click', () => toggleAllModules(false))
})()
// Custom Uname buttons
;(async () => {
	const unameRelease = document.getElementById('custom_uname_release')
	const unameVersion = document.getElementById('custom_uname_version')

        const computeAutoUname = async () => {
                const kv = await exec("cat /proc/version | awk '{print \$3}' | grep -oE '^[0-9]+\\.[0-9]+\\.[0-9]+'")
                const variant = await exec("/data/adb/ksu/bin/susfs show variant")
                const bd = await exec("resetprop ro.build.date | tr -s ' '")

                const kernelVersion = (kv.stdout || '').trim()
                const susfsVariant = (variant.stdout || '').trim()
                const version = `#1 SMP PREEMPT ${(bd.stdout || '').trim()}`
                const randomGit = Math.floor(10000000 + Math.random() * 90000000)

                let release = 'default'

                if (kernelVersion) {
                        if (susfsVariant === 'GKI') {
                                const kmi = await exec("/data/adb/ksud boot-info current-kmi | cut -d'-' -f1")
                                release = `${kernelVersion}-${(kmi.stdout || '').trim()}-9-g${randomGit}`
                        } else {
                                release = `${kernelVersion}-g${randomGit}`
                        }
                }

                return { release, version }
        }

	const setUnameFields = (release, version) => {
		const r = String(release ?? '').trim() === '' ? 'default' : String(release).trim()
		const vRaw = String(version ?? '').trim()
		const finalVersion = vRaw === '' ? 'default' : vRaw
		if (!isValidUnameRelease(r)) {
			toast(('Invalid Kernel Release: ' + r).replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
			return null
		}
		if (!isValidUnameVersion(finalVersion)) {
			toast(('Invalid Kernel Version: ' + finalVersion).replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
			return null
		}
		updateConfig2('config_custom_uname_kernel_release', r)
		updateConfig2('config_custom_uname_kernel_version', finalVersion)
		unameRelease.value = r
		unameVersion.value = finalVersion
		return finalVersion
	}

	const updateUname = async (release, version) => {
		const r = String(release ?? '').trim() === '' ? 'default' : String(release).trim()
		const vRaw = String(version ?? '').trim()
		const vNorm = vRaw === '' ? 'default' : vRaw
		const finalVersion = setUnameFields(r, vNorm)
		if (finalVersion === null) return

		let liveRelease = r
		let liveVersion = finalVersion
		if (r === 'default' || finalVersion === 'default') {
			const auto = await computeAutoUname()
			if (r === 'default') liveRelease = auto.release
			if (finalVersion === 'default') liveVersion = auto.version
		}

		const esc = (s) => s.replace(/'/g, "'\\''")
		exec(`/data/adb/ksu/bin/susfs set_uname '${esc(liveRelease)}' '${esc(liveVersion)}'`).then((result) => {
			toast(result.errno === 0 ? 'Applied (no need to reboot)' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
		})
	}

	document.getElementById(`button_custom_uname_reset`).onclick = () => {
		updateUname('default', 'default')
	}
	document.getElementById(`button_custom_uname_apply`).onclick = () => {
		updateUname(unameRelease.value, unameVersion.value)
	}
})()

// Verified Boot Hash
;(async () => {
	const textField = document.getElementById('verified_boot_hash_text_field')
	const button = document.getElementById('verified_boot_hash_button')

	button.addEventListener('click', () => {
		const digest = textField.value.trim()

		if (digest === '') {
			toast('Missing verified boot hash')
			return
		}
		if (!/^[0-9a-fA-F]{64}$/.test(digest)) {
			toast('Invalid verified boot hash')
			return
		}
		updateConfig2('config_verified_boot_hash', digest)
		const safeDigest = `'${digest.replace(/'/g, "'\\''")}'`
		exec(`resetprop -n ro.boot.vbmeta.digest ${safeDigest}`).then((result) => {
                        if (result.errno === 0) {
                                toast('No need to reboot')
                        } else {
                                toast('Failed to update prop')
                        }
                })
	})
})()

//
;(async () => {
	const mapField = document.getElementById('custom_sus_map_text_field')
	const mountField = document.getElementById('custom_sus_mount_text_field')
	const pathField = document.getElementById('custom_sus_path_text_field')
	const loopField = document.getElementById('custom_sus_path_loop_text_field')
	const kstatContainer = document.getElementById('kstat_entries_container')
	const addKstatButton = document.getElementById('add_kstat_entry_button')
	const kstatFieldNames = ['ino', 'dev', 'nlink', 'size', 'atime', 'atime_nsec', 'mtime', 'mtime_nsec', 'ctime', 'ctime_nsec', 'blocks', 'blksize']
	const openRedirectContainer = document.getElementById('open_redirect_entries_container')
	const addOpenRedirectButton = document.getElementById('add_open_redirect_entry_button')

	function createKstatEntry(values, mode) {
		values = values || {}
		const initialMode = mode === 'normal' ? 'normal' : mode === 'fullclone' ? 'fullclone' : 'static'
		const entry = document.createElement('div')
		entry.className = 'kstat-entry'
		entry.dataset.mode = initialMode
		entry.style.cssText = 'border:1px solid var(--md-sys-color-outline, #79747E); border-radius:12px; padding:12px; display:flex; flex-direction:column; gap:8px; margin-bottom:12px;'

		// Normal/FullClone take no values — only Path is rendered (no value fields).
		const modeRow = document.createElement('div')
		modeRow.style.cssText = 'display:flex; gap:8px; align-items:center;'
		const modeLabel = document.createElement('span')
		modeLabel.textContent = 'Mode:'
		modeLabel.style.cssText = 'font-size:13px; opacity:.8;'
		modeRow.appendChild(modeLabel)
		const modeSelect = document.createElement('select')
		modeSelect.className = 'kstat-mode'
		modeSelect.style.cssText = 'flex:1; background:var(--md-sys-color-surface-container-high, #1d1b20); color:var(--md-sys-color-on-surface, #e6e0e9); border:1px solid var(--md-sys-color-outline, #79747E); border-radius:8px; padding:10px 12px; font-size:14px;'
		const optStatic = document.createElement('option')
		optStatic.value = 'static'
		optStatic.textContent = 'static (explicit values)'
		const optNormal = document.createElement('option')
		optNormal.value = 'normal'
		optNormal.textContent = 'normal (boot-time snapshot)'
		const optFullClone = document.createElement('option')
		optFullClone.value = 'fullclone'
		optFullClone.textContent = 'full clone (boot-time full snapshot)'
		modeSelect.appendChild(optStatic)
		modeSelect.appendChild(optNormal)
		modeSelect.appendChild(optFullClone)
		modeSelect.value = initialMode
		modeRow.appendChild(modeSelect)
		entry.appendChild(modeRow)

		const pathField = document.createElement('md-outlined-text-field')
		pathField.setAttribute('label', 'Path')
		pathField.className = 'kstat-path'
		pathField.value = values.path || ''
		entry.appendChild(pathField)

		const grid = document.createElement('div')
		grid.style.cssText = 'display:grid; grid-template-columns: repeat(3, 1fr); gap:8px;'
		grid.className = 'kstat-grid'
		kstatFieldNames.forEach((name) => {
			const field = document.createElement('md-outlined-text-field')
			field.setAttribute('label', name)
			field.className = `kstat-${name}`
			field.setAttribute('placeholder', 'default')
			if (values[name] !== undefined && values[name] !== 'default') {
				field.value = values[name]
			}
			grid.appendChild(field)
		})

		const removeBtn = document.createElement('md-filled-tonal-button')
		removeBtn.textContent = 'REMOVE ENTRY'
		removeBtn.onclick = () => entry.remove()
		modeSelect.onchange = () => {
			entry.dataset.mode = modeSelect.value
			if (modeSelect.value === 'static') {
				if (!grid.isConnected) entry.insertBefore(grid, removeBtn)
			} else {
				if (grid.isConnected) grid.remove()
			}
		}
		if (initialMode === 'static') entry.appendChild(grid)
		entry.appendChild(removeBtn)

		kstatContainer.appendChild(entry)
	}

	// normal: bare path, fullclone: fullclone:/path, static: 13-field TAB.
	function serializeKstatEntries() {
		const entries = kstatContainer.querySelectorAll('.kstat-entry')
		const outLines = []
		const numRe = /^(default|[0-9]+)$/
		entries.forEach((entry) => {
			const rawPath = entry.querySelector('.kstat-path').value
			if (/[\t\r\n]/.test(rawPath)) throw new Error('KSTAT path must not contain TAB/newline')
			const path = rawPath.trim()
			if (!path) return
			if (!path.startsWith('/')) throw new Error(`KSTAT path must be absolute: ${path}`)
			if (/(^|\/)\.\.(\/|$)/.test(path)) throw new Error(`KSTAT path must not contain ..: ${path}`)
			const mode = entry.dataset.mode === 'normal' ? 'normal' : entry.dataset.mode === 'fullclone' ? 'fullclone' : 'static'
			if (mode === 'normal') { outLines.push(path); return }
			if (mode === 'fullclone') { outLines.push('fullclone:' + path); return }
			const values = [path]
			kstatFieldNames.forEach((name) => {
				const v = entry.querySelector(`.kstat-${name}`).value.trim()
				const nv = v === '' ? 'default' : v
				if (!numRe.test(nv)) throw new Error(`KSTAT invalid ${name}: ${nv}`)
				if (nv !== 'default' && name.endsWith('_nsec') && Number(nv) > 999999999) throw new Error(`KSTAT ${name} out of range`)
				values.push(nv)
			})
			outLines.push(values.join('\t'))
		})
		return outLines.join('\n')
	}

	function loadKstatEntries(text) {
		kstatContainer.innerHTML = ''
		const rawLines = (text || '').split('\n').map((l) => l.replace(/\r$/, '').trim()).filter((l) => l && !l.startsWith('#'))
		let skipped = 0
		rawLines.forEach((line) => {
			// fullclone:/path = fullclone (boot-time full snapshot).
			// 1-field line (no TAB) = normal (boot-time snapshot, bare path).
			// 13-field TAB line = static (add_sus_kstat_statically).
			if (line.startsWith('fullclone:')) {
				const p = line.slice('fullclone:'.length).trim()
				if (p && p.startsWith('/')) { createKstatEntry({ path: p }, 'fullclone'); return }
				skipped++; return
			}
			if (!line.includes('\t')) {
				const p = line.trim()
				// Legacy fallback first: old hand-edited static lines used spaces instead of TABs.
				const ws = p.split(/\s+/)
				if (ws.length === 13 && ws[0].startsWith('/')) {
					const values = { path: ws[0] }
					kstatFieldNames.forEach((name, i) => { values[name] = ws[i + 1] })
					createKstatEntry(values, 'static'); return
				}
				if (p && p.startsWith('/')) { createKstatEntry({ path: p }, 'normal'); return }
				skipped++; return
			}
			// Canonical format is TAB-separated (serializeKstatEntries + post-fs-data.sh IFS=$'\t').
			// Whitespace split is only a fallback for legacy hand-edited lines with no spaces in path.
			const parts = line.split('\t').map((p) => p.trim())
			if (parts.length !== 13 || !parts[0] || !parts[0].startsWith('/')) { skipped++; return }
			const values = { path: parts[0] }
			kstatFieldNames.forEach((name, i) => {
				values[name] = parts[i + 1]
			})
			createKstatEntry(values, 'static')
		})
		if (kstatContainer.childElementCount > 2000) {
			while (kstatContainer.childElementCount > 2000) kstatContainer.lastChild.remove()
			toast('KSTAT: too many entries, truncated to 2000')
		}
		if (skipped) toast(`KSTAT: skipped ${skipped} malformed line(s), need 1 (normal), fullclone:/path (fullclone) or 13 TAB-separated (static) fields`)
	}

	addKstatButton.onclick = () => createKstatEntry({}, 'static')

	function createOpenRedirectEntry(values) {
		values = values || {}
		const entry = document.createElement('div')
		entry.className = 'open-redirect-entry'
		entry.style.cssText = 'border:1px solid var(--md-sys-color-outline, #79747E); border-radius:12px; padding:12px; display:flex; flex-direction:column; gap:8px; margin-bottom:12px;'

		const src = document.createElement('md-outlined-text-field')
		src.setAttribute('label', 'Source (target path)')
		src.className = 'or-src'
		src.value = values.src || ''
		entry.appendChild(src)

		const dst = document.createElement('md-outlined-text-field')
		dst.setAttribute('label', 'Target (redirected path)')
		dst.className = 'or-dst'
		dst.value = values.dst || ''
		entry.appendChild(dst)

		const uid = document.createElement('md-outlined-text-field')
		uid.setAttribute('label', 'uid_scheme (0-4, default 3)')
		uid.setAttribute('placeholder', '3')
		uid.className = 'or-uid'
		if (values.uid) uid.value = values.uid
		entry.appendChild(uid)

		const removeBtn = document.createElement('md-filled-tonal-button')
		removeBtn.textContent = 'REMOVE ENTRY'
		removeBtn.onclick = () => entry.remove()
		entry.appendChild(removeBtn)

		openRedirectContainer.appendChild(entry)
	}

	function serializeOpenRedirectEntries() {
		const entries = openRedirectContainer.querySelectorAll('.open-redirect-entry')
		const outLines = []
		for (const entry of entries) {
			const s = entry.querySelector('.or-src').value.trim()
			const d = entry.querySelector('.or-dst').value.trim()
			const u = entry.querySelector('.or-uid').value.trim() || '3'
			if (!s && !d) continue
			if (!s || !d) { toast('REDIRECT: both source and target are required'); return null }
			if (!s.startsWith('/') || !d.startsWith('/')) { toast('REDIRECT: paths must be absolute'); return null }
			if (/[\t\r\n]/.test(s) || /[\t\r\n]/.test(d)) { toast('REDIRECT: paths must not contain TAB/newline'); return null }
			if (!/^[0-4]$/.test(u)) { toast('REDIRECT: uid_scheme must be 0-4'); return null }
			if (/(^|\/)\.\.(\/|$)/.test(s) || /(^|\/)\.\.(\/|$)/.test(d)) { toast('REDIRECT: paths must not contain ..'); return null }
			if (norm(s) === norm(d)) { toast('REDIRECT: source and target must differ'); return null }
			outLines.push(`${s}\t${d}\t${u}`)
		}
		return outLines.join('\n')
	}

	function loadOpenRedirectEntries(text) {
		openRedirectContainer.innerHTML = ''
		const rawLines = (text || '').split('\n').map((l) => l.replace(/\r$/, '').trim()).filter((l) => l && !l.startsWith('#'))
		let skipped = 0
		rawLines.forEach((line) => {
			const parts = line.split('\t')
			if (parts.length !== 3 || !parts[0] || !parts[1]) { skipped++; return }
			createOpenRedirectEntry({ src: parts[0].trim(), dst: parts[1].trim(), uid: (parts[2] || '3').trim() })
		})
		if (openRedirectContainer.childElementCount > 2000) {
			while (openRedirectContainer.childElementCount > 2000) openRedirectContainer.lastChild.remove()
			toast('REDIRECT: too many entries, truncated to 2000')
		}
		if (skipped) toast(`REDIRECT: skipped ${skipped} malformed line(s), need 3 TAB-separated fields`)
	}

	addOpenRedirectButton.onclick = () => createOpenRedirectEntry()
	const applyButton = document.getElementById('unified_apply_button')
	const tabs = document.getElementById('sus_tabs')
	const scrollContainer = document.getElementById('horizontal_scroll_container')
	let truncated = { map: false, mount: false, path: false, loop: false, kstat: false, redirect: false }
	applyButton.disabled = true
	let susLoadsPending = 6
	let susLoadsDone = false
	const markSusLoaded = () => { if (--susLoadsPending <= 0) { susLoadsDone = true; applyButton.disabled = false } }

	// Load all contents
	exec(`cat ${PERSISTENT_DIR}/custom_sus_map.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated.map = true; out = cutToLastFullLines(out, MAX) }
		mapField.value = result.errno === 0 ? `${out}\n` : ''
	}).finally(markSusLoaded)
	exec(`cat ${PERSISTENT_DIR}/custom_sus_mount.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated.mount = true; out = cutToLastFullLines(out, MAX) }
		mountField.value = result.errno === 0 ? `${out}\n` : ''
	}).finally(markSusLoaded)
	exec(`cat ${PERSISTENT_DIR}/custom_sus_path.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated.path = true; out = cutToLastFullLines(out, MAX) }
		pathField.value = result.errno === 0 ? `${out}\n` : ''
	}).finally(markSusLoaded)
	exec(`cat ${PERSISTENT_DIR}/custom_sus_path_loop.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated.loop = true; out = cutToLastFullLines(out, MAX) }
		loopField.value = result.errno === 0 ? `${out}\n` : ''
	}).finally(markSusLoaded)
	exec(`cat ${PERSISTENT_DIR}/custom_sus_kstat.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated.kstat = true; out = cutToLastFullLines(out, MAX) }
		loadKstatEntries(result.errno === 0 ? out : '')
	}).finally(markSusLoaded)
	exec(`grep '^\\[custom_sus_kstat' ${PERSISTENT_DIR}/logs.txt`).then((result) => {
		const kstatLog = document.getElementById('kstat_log_display')
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) out = out.slice(-MAX) + '\n…(truncated)'
		kstatLog.value = result.errno === 0 && out ? out : '(no kstat log entries yet)'
	})
	exec(`cat ${PERSISTENT_DIR}/custom_open_redirect.txt`).then((result) => {
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) { truncated.redirect = true; out = cutToLastFullLines(out, MAX) }
		loadOpenRedirectEntries(result.errno === 0 ? out : '')
	}).finally(markSusLoaded)
	exec(`grep '^\\[custom_open_redirect\\]' ${PERSISTENT_DIR}/logs.txt`).then((result) => {
		const openRedirectLog = document.getElementById('open_redirect_log_display')
		const MAX = 65536; let out = result.stdout || ''; if (out.length > MAX) out = out.slice(-MAX) + '\n…(truncated)'
		openRedirectLog.value = result.errno === 0 && out ? out : '(no open redirect log entries yet)'
	})

	// Tabs and Scroll Sync
	tabs.addEventListener('change', () => {
		applyButton.disabled = true
		const index = tabs.activeTabIndex
		const width = scrollContainer.getBoundingClientRect().width
		scrollContainer.scrollTo({
			left: width * index,
			behavior: 'smooth',
		})
	})

	let scrollTimeout
	scrollContainer.addEventListener('scroll', () => {
		applyButton.disabled = true
		clearTimeout(scrollTimeout)
		scrollTimeout = setTimeout(() => {
			const width = scrollContainer.getBoundingClientRect().width
			const index = Math.round(scrollContainer.scrollLeft / width)
			if (tabs.activeTabIndex !== index) {
				tabs.activeTabIndex = index
			}
			if (susLoadsDone) applyButton.disabled = false
		}, 50)
	})

	applyButton.onclick = () => {
		const index = tabs.activeTabIndex
		let file = ''
		let content = ''
		let truncatedKey = ''

		switch (index) {
			case 0:
				file = 'custom_sus_map.txt'
				content = mapField.value
				truncatedKey = 'map'
				break
			case 1:
				file = 'custom_sus_mount.txt'
				content = mountField.value
				truncatedKey = 'mount'
				break
			case 2:
				file = 'custom_sus_path.txt'
				content = pathField.value
				truncatedKey = 'path'
				break
			case 3:
				file = 'custom_sus_path_loop.txt'
				content = loopField.value
				truncatedKey = 'loop'
				break
			case 4:
				file = 'custom_sus_kstat.txt'
				truncatedKey = 'kstat'
				try {
					content = serializeKstatEntries()
				} catch (e) {
					toast(e.message)
					return
				}
				break
			case 5:
				file = 'custom_open_redirect.txt'
				truncatedKey = 'redirect'
				content = serializeOpenRedirectEntries()
				if (content === null) return
				break
		}

		if (file === '') { toast('Select a tab first'); return }
		if (truncatedKey && truncated[truncatedKey]) { toast('File too large, not saved'); return }
		const MAX = 65536
		if (content.length > MAX) { toast('File too large, not saved'); return }

		if (index >= 0 && index <= 3) {
			const bad = findInvalidSusPath(content)
			if (bad !== null) { toast('Invalid path: '+String(bad).slice(0,80)); return }
		}

		if (file) {
		        if (content === '') {
		                exec(`printf '' > ${PERSISTENT_DIR}/${file}`).then((result) => {
		                        toast(result.errno === 0 ? 'Success' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
		                })
		        } else {
		                const eofRand = window.crypto && window.crypto.getRandomValues ? crypto.getRandomValues(new Uint32Array(1))[0] : Math.floor(Math.random() * 4294967295)
		                const eof = 'EOF_' + Date.now().toString(36) + Math.floor(eofRand / 1000).toString(36)
		                if (content.split('\n').some((line) => line === eof)) {
		                        toast('Refusing to write: content contains delimiter')
		                        return
		                }
		                exec(`
cat <<'${eof}' > ${PERSISTENT_DIR}/${file}
${content}
${eof}
                `).then((result) => {
		                        toast(result.errno === 0 ? 'Success' : String(result.stderr||'').replace(/[\x00-\x1F\x7F]/g,' ').slice(0,200))
		                })
		        }

		}
	}
})()

// tabs.js — tab switching
;(async () => {
	var btns = document.querySelectorAll('.tab-btn')
	var panels = document.querySelectorAll('.tab-panel')

	function activate(id) {
		btns.forEach(function (b) {
			b.classList.toggle('active', b.dataset.tab === id)
		})
		panels.forEach(function (p) {
			p.classList.toggle('active', p.dataset.panel === id)
		})
	}

	btns.forEach(function (btn) {
		btn.addEventListener('click', function () {
			activate(btn.dataset.tab)
			try {
				sessionStorage.setItem('brene_tab', btn.dataset.tab)
			} catch (e) {}
		})
	})

	try {
		var saved = sessionStorage.getItem('brene_tab')
		const ids = Array.from(btns).map((b) => b.dataset.tab)
		if (saved && ids.includes(saved)) activate(saved)
	} catch (e) {}
})()

// Swipe
;(async () => {
	const tabBar = document.getElementById('tab-bar')
	const bodyContent = document
	const buttons = Array.from(tabBar.querySelectorAll('button.tab-btn'))
	const SWIPE_THRESHOLD = 10
	let fi = buttons.findIndex((btn) => btn.classList.contains('active'))
	let currentIndex = fi === -1 ? 0 : fi
	let touchStartX = 0
	let touchStartY = 0

        const updateUI = (index) => {
                buttons[index].click()

                buttons[index].scrollIntoView({
                        behavior: 'auto',
                        block: 'nearest',
                        inline: 'center',
                })
        }

	const changeTab = (index) => {
		if (index >= 0 && index < buttons.length) {
			currentIndex = index
			updateUI(index)
		}
	}

	bodyContent.addEventListener(
		'touchstart',
		(e) => {
			touchStartX = e.touches[0].clientX
			touchStartY = e.touches[0].clientY
		},
		{ passive: true },
	)

	bodyContent.addEventListener(
		'touchend',
		(e) => {
			if (e.target.closest('.tab-bar') === null && e.target.closest('md-filled-text-field,md-outlined-text-field,textarea,input,md-select,md-dialog,[contenteditable],#horizontal_scroll_container') === null) {
				const touchEndX = e.changedTouches[0].clientX
				const touchEndY = e.changedTouches[0].clientY

				const diffX = touchStartX - touchEndX
				const diffY = touchStartY - touchEndY

				const isHorizontalSwipe = Math.abs(diffX) > SWIPE_THRESHOLD
                                const isDominantX = Math.abs(diffX) > Math.abs(diffY) * 3

                                if (isHorizontalSwipe && isDominantX) {
					if (diffX > 0) {
						changeTab(currentIndex + 1)
					} else {
						changeTab(currentIndex - 1)
					}
				}
			}
		},
		{ passive: true },
	)

	tabBar.addEventListener('click', (e) => {
		const btn = e.target.closest('.tab-btn')
		if (btn) {
			currentIndex = buttons.indexOf(btn)
		}
	})
})()
