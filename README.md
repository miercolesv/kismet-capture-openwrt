# kismet-capture-openwrt

Kismet 2026-10-R1 for OpenWrt 25.12 (apk), architecture `aarch64_cortex-a53`. The
official OpenWrt feeds no longer ship a usable Kismet.

Works on any OpenWrt 25.12 router with that package architecture, for example
GL.iNet GL-AXT1800 / GL-AX1800 (qualcommax/ipq60xx) and Cudy TR3000 and other
MT7981/MT7986 routers (mediatek/filogic). Check with `cat /etc/openwrt_release`
(`DISTRIB_ARCH='aarch64_cortex-a53'`, `DISTRIB_RELEASE='25.12.x'`).

| Package | What |
|---|---|
| `kismet-capture-linux-wifi` | Wi-Fi capture tool: monitor mode + channel hopping, sends to a local or remote Kismet server |
| `kismet-server` | Kismet server with the web UI on port 2501, procd service, router-friendly defaults |
| `kismet-capture-sdr` | RTL-SDR USB dongle tools: ADS-B aircraft (with ICAO database), rtl_433 sensors, AIS ships |

## Install

Download the `.apk` files you want from the latest release, then on the router:

```sh
apk add --allow-untrusted ./kismet-*.apk
```

Dependencies come from the official feed.

## Kismet on the router itself

```sh
# free a radio from AP duty and give it an interface (example: radio1 = phy1)
uci set wireless.radio1.disabled=1 && uci commit wireless && wifi reload
iw phy phy1 interface add wlan1 type managed

uci set kismet.main.enabled=1
uci add_list kismet.main.source='wlan1:name=router-2g'
uci commit kismet
/etc/init.d/kismet enable
/etc/init.d/kismet start
```

Open `http://<router-ip>:2501` and create the login on first visit.

Logging is off by default: a `.kismet` database grows continuously and must not go
to the router's flash. The service refuses to log when `log_prefix` is not on a
mounted external drive (e.g. the card is not inserted), unless `log_to_flash` is set.
With a microSD card or USB drive mounted:

```sh
uci set kismet.main.logging=1
uci set kismet.main.log_prefix=/mnt/sda1/kismet
uci commit kismet && /etc/init.d/kismet restart
```

Convert a log for Wireshark: `kismetdb_to_pcap --in <file>.kismet --out capture.pcap`.
Stopping the service removes the monitor interfaces it created.

Memory limits for small routers are in `/etc/kismet/kismet_site.conf`
(devices are forgotten after 30 minutes, at most 3000 tracked).

### RTL-SDR (ADS-B, rtl_433, AIS)

Plug an RTL-SDR dongle into the USB port, install `kismet-capture-sdr`, then add a source:

```sh
uci add_list kismet.main.source='rtladsb-0:name=adsb'     # aircraft, 1090 MHz
# or: 'rtl433-0:name=sensors'   433 MHz sensors (weather stations, TPMS, ...)
# or: 'rtlais-0:name=ships'     AIS ship transponders
uci commit kismet && /etc/init.d/kismet restart
```

One dongle serves one of these at a time.

## Capture on the router, Kismet on a PC

```sh
kismet_cap_linux_wifi --connect <pc-ip>:2501 --user <user> --password <pass> --source=wlan1:name=router
# legacy protocol (needs remote_capture_enabled=true on the server):
kismet_cap_linux_wifi --tcp --connect <pc-ip>:3501 --source=wlan1:name=router
```

Free the radio first (disable its AP); with an AP and a monitor interface on the same
radio, the driver may only capture the router's own traffic.

## Build

CI builds on every push and publishes a release from `main`. To build locally
(Linux x86_64, not as root, ~3 GB RAM per compile job for the server):

```sh
RELEASE=25.12.6 ./scripts/build.sh      # output in dist/
```

To publish a new build of the same Kismet version, bump `PKG_RELEASE` in
`net/kismet-capture/Makefile` or `net/kismet/Makefile`.
