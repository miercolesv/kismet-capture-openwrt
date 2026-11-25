# kismet-capture-openwrt

OpenWrt package for Kismet's remote capture tool, `kismet_cap_linux_wifi`, built for
OpenWrt 25.12 on qualcommax/ipq60xx (aarch64_cortex-a53) — GL.iNet GL-AXT1800 (Slate AX)
and GL-AX1800 (Flint). The official OpenWrt feeds no longer ship a usable Kismet.

The router puts a radio in monitor mode, hops channels and streams frames to a full
Kismet server on another machine.

## Install

Download the `.apk` from the latest release, then on the router:

```sh
apk add --allow-untrusted ./kismet-capture-linux-wifi-*.apk
```

Dependencies (`libpcap`, `libnl-tiny`, `libwebsockets-mbedtls`) come from the official feed.
The package must match the router's release series (`cat /etc/openwrt_release`).

## Use

Start Kismet on the PC, then on the router:

```sh
# websockets (default), Kismet web port 2501
kismet_cap_linux_wifi --connect <server-ip>:2501 --user <user> --password <pass> --source=wlan1

# legacy TCP protocol, needs remote_capture_enabled=true on the server
kismet_cap_linux_wifi --tcp --connect <server-ip>:3501 --source=wlan1
```

Free the radio first (disable its AP/client interface); with an AP and a monitor
interface on the same radio, ath11k only captures the router's own traffic.

## Build

CI builds on every push and publishes a release from `main`. To build locally
(Linux x86_64, not as root):

```sh
RELEASE=25.12.6 ./scripts/build.sh      # output in dist/
```

A different release: run the workflow manually with the `release` input, or set `RELEASE`.
To publish a new build of the same Kismet version, bump `PKG_RELEASE` in
`net/kismet-capture/Makefile`.
