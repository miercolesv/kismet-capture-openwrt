# Kismet for OpenWrt

[Kismet](https://www.kismetwireless.net/) 2026-10-R1 packaged for **OpenWrt 25.12**
(apk): monitor-mode Wi-Fi capture, the full Kismet server and web UI running on
the router, and RTL-SDR tools for aircraft, sensors and ships.

The official OpenWrt feeds no longer ship a usable Kismet. These packages are
built with the official OpenWrt SDK, tested on an ARM emulator in CI and
published as GitHub releases.

## Features

| Feature | Package | Status |
|---|---|---|
| Wi-Fi capture: monitor mode, channel hopping | `kismet-capture-linux-wifi` | ✅ |
| Kismet server and web UI on the router, as a procd service | `kismet-server` | ✅ |
| Remote capture: the router as a sensor for Kismet on a PC | `kismet-capture-linux-wifi` | ✅ ¹ |
| Logging to microSD/USB, with flash protection; pcap export | `kismet-server` | ✅ ¹ |
| ADS-B aircraft, rtl_433 sensors, AIS ships with an RTL-SDR dongle | `kismet-capture-sdr` | ✅ ² |

¹ Tested in an OpenWrt emulator. ² Tested in an emulator without a dongle; not yet tested with real reception.

### Supported routers

Any router on OpenWrt 25.12.x with the package architecture `aarch64_cortex-a53`:

| Router | Target | Notes |
|---|---|---|
| GL.iNet GL-AXT1800 | `qualcommax/ipq60xx` | tested; [hardware notes](docs/hardware/gl-axt1800.md) |
| Cudy TR3000, other Filogic routers | `mediatek/filogic` | same architecture, not tested |
| Other `qualcommax`, `mediatek/mt7622`, `mvebu/cortexa53` … | | [full list](docs/hardware/other-routers.md) |

Check yours with `grep DISTRIB_ARCH /etc/openwrt_release`.

**Documentation:** <https://miercolesv.github.io/kismet-capture-openwrt/>

## Quick start

Download the packages from the
[latest release](https://github.com/miercolesv/kismet-capture-openwrt/releases/latest)
(its notes list the exact commands), then on the router:

```sh
apk add --allow-untrusted ./kismet-*.apk

# give one radio to Kismet (example: radio1 / phy1)
uci set wireless.radio1.disabled=1 && uci commit wireless && wifi reload
iw phy phy1 interface add wlan1 type managed

uci set kismet.main.enabled=1
uci add_list kismet.main.source='wlan1:name=router-2g'
uci commit kismet
/etc/init.d/kismet enable && /etc/init.d/kismet start
```

Open `http://192.168.1.1:2501` and create a login.

Or keep Kismet on your PC and stream from the router:

```sh
kismet_cap_linux_wifi --connect <pc-ip>:2501 --user <user> --password <pass> --source=wlan1
```

## Documentation

The full guide is at **<https://miercolesv.github.io/kismet-capture-openwrt/>**
(sources in [`docs/`](docs/)):

* [Getting started](docs/guide/getting-started.md) · [Installation](docs/guide/installation.md) · [Troubleshooting](docs/guide/troubleshooting.md)
* Features: [Kismet on the router](docs/features/server.md), [Wi-Fi capture](docs/features/wifi-capture.md), [remote capture](docs/features/remote-capture.md), [SDR](docs/features/sdr.md), [logging](docs/features/logging.md)
* Reference: [configuration](docs/reference/configuration.md), [commands](docs/reference/commands.md), [packages](docs/reference/packages.md), [security](docs/reference/security.md), [building](docs/reference/building.md)
* [Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md)

## Packages

| Package | Size | What |
|---|---|---|
| `kismet-capture-linux-wifi` | 240 KB | Wi-Fi capture tool |
| `kismet-server` | 16.8 MB | Kismet server, web UI, service, log tools |
| `kismet-capture-sdr` | 7.5 MB | RTL-SDR tools and the aircraft database |

Sizes are installed, uncompressed; dependencies come from the official feed.

## Limitations

* A radio can't serve your Wi-Fi network and capture at the same time: give
  Kismet a radio of its own.
* Built for OpenWrt 25.12 and `aarch64_cortex-a53` only. Other releases or
  architectures need a build of their own.
* The packages are not signed with an apk key: install with `--allow-untrusted`
  and check `SHA256SUMS`.
* GL.iNet's stock firmware is not supported; it needs upstream OpenWrt.

## License

Kismet is released under the GPL-2.0, and so are these build recipes. See
[LICENSE](LICENSE). The packages contain unmodified Kismet built from upstream
commit `361328d9` (tag `kismet-2026-10-R1`).

This is an independent project, not affiliated with or endorsed by the Kismet
project, OpenWrt or any router manufacturer. Product names are used only to say
which hardware is supported.
