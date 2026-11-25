# GL.iNet GL-AXT1800 (Slate AX)

The router these packages were made for, and the one they have been used on.

| | |
|---|---|
| OpenWrt target | `qualcommax/ipq60xx` (profile `glinet_gl-axt1800`) |
| Package architecture | `aarch64_cortex-a53` |
| Tested on | OpenWrt 25.12.6 (r33311-981c978eff) |
| SoC | Qualcomm IPQ6000, 4 × Cortex-A53 |
| RAM / flash | 512 MB / 128 MB NAND |
| Wi-Fi | 2.4 GHz and 5 GHz, Wi-Fi 6, `ath11k` driver |
| Storage | microSD slot, USB port |

The GL-AX1800 (Flint) is on the same target and architecture; it has not been
tested.

## Status

| Feature | Status |
|---|---|
| Install with apk | ✅ works |
| Wi-Fi capture (monitor mode, channel hopping) | ✅ works |
| Kismet server and web UI on the router | ✅ works |
| Remote capture to a PC | tested in an emulator; same capture tool as above |
| Logging to microSD | tested in an emulator only |
| RTL-SDR dongle in the USB port | not tested on this router |

## Stock GL.iNet firmware

The packages are for **upstream OpenWrt 25.12**. GL.iNet's own firmware is
based on an older OpenWrt with opkg and a different Wi-Fi driver, and the
packages won't install there. Flash upstream OpenWrt first (see the OpenWrt
wiki page for the device).

## Radios

Upstream OpenWrt names the radios `radio0` / `radio1`; which one is 2.4 GHz
depends on the build. Check before disabling one:

```sh
uci show wireless | grep -E "radio[0-9]=|\.band="
iw dev
```

A typical setup keeps one radio as your access point and gives the other to
Kismet, with the router managed over Ethernet or the remaining radio.

## Notes

* **Monitor mode on ath11k.** With an access point and a monitor interface on
  the same radio, ath11k only captures the router's own traffic. Disable the
  access point on the radio you capture with.
* **Signal strength and rates** reported by ath11k in monitor mode can be
  inexact, and very busy channels may drop frames.
* **Memory.** With 512 MB of RAM the default limits in `kismet_site.conf` leave
  plenty of headroom (Kismet used about 33 MB in testing with one network in
  range).
* **microSD.** A card is mounted under `/mnt/` once `block-mount` and the
  file-system package for the card (for example `kmod-fs-ext4` or
  `kmod-fs-exfat`) are installed. Point `log_prefix` there.
