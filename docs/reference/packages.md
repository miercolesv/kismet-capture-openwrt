# Packages

All packages are built from Kismet **2026-10-R1** (upstream commit
`361328d9`) for OpenWrt **25.12** and the `aarch64_cortex-a53` package
architecture. Sizes are installed (uncompressed) sizes; the router's flash file
system compresses them.

## `kismet-capture-linux-wifi`

Wi-Fi capture tool for local or remote capture. About 240 KB.

| Installs | |
|---|---|
| `/usr/bin/kismet_cap_linux_wifi` | the capture tool |

**Depends on:** `libpcap1`, `libnl-tiny1`, `libwebsockets-mbedtls`, `libpthread`

## `kismet-server`

The Kismet server, web UI and service. About 16.8 MB.

| Installs | |
|---|---|
| `/usr/bin/kismet` | the server |
| `/usr/bin/kismetdb_to_pcap` | convert a log to pcap |
| `/usr/bin/kismetdb_strip_packets` | blank packet contents in a log |
| `/etc/init.d/kismet` | procd service |
| `/etc/config/kismet` | service configuration (kept on upgrade) |
| `/etc/kismet/kismet_site.conf` | router settings for Kismet (kept on upgrade) |
| `/etc/kismet/kismet*.conf` | Kismet's stock configuration |
| `/usr/share/kismet/httpd/` | the web UI |
| `/usr/share/kismet/kismet_manuf.txt.gz` | Wi-Fi vendor names (from MAC addresses) |
| `/usr/share/kismet/kismet_bluetooth_*.txt.gz` | Bluetooth vendor names |

**Depends on:** `kismet-capture-linux-wifi`, `libopenssl3`, `libsqlite3-0`,
`libpcre2`, `libstdcpp6`, `libatomic1`, `libpcap1`, `libnl-tiny1`, `zlib`,
`libpthread`

## `kismet-capture-sdr`

RTL-SDR capture tools and the aircraft database. About 7.5 MB, mostly the
database.

| Installs | |
|---|---|
| `/usr/bin/kismet_cap_sdr_rtladsb` | ADS-B (aircraft) |
| `/usr/bin/kismet_cap_sdr_rtl433` | rtl_433 sensors |
| `/usr/bin/kismet_cap_sdr_rtlais` | AIS (ships) |
| `/usr/share/kismet/kismet_adsb_icao.txt.gz` | ICAO aircraft database (registration, type) |

**Depends on:** `librtlsdr`, `libusb-1.0-0`, `rtl_433`, `zlib`, `libpthread`

## Release names

Releases are tagged
`v<kismet version>-r<capture release>.<server release>-openwrt<OpenWrt release>`,
for example `v2026.10.1-r1.2-openwrt25.12.6`. Each release includes
`SHA256SUMS` for its files.

## Source code

Kismet is free software under the GPL-2.0. These packages contain unmodified
Kismet built from upstream commit
`361328d9702457e7ba27b2be796a196180e765e8` (tag `kismet-2026-10-R1`) of
<https://github.com/kismetwireless/kismet>; the build recipes are in
[`net/`](https://github.com/miercolesv/kismet-capture-openwrt/tree/main/net) of
this repository.
