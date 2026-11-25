# Changelog

All notable changes are listed here. The format follows "Keep a Changelog".
Releases are named `v<kismet version>-r<capture release>.<server release>-openwrt<OpenWrt release>`.

## [v2026.10.1-r1.2-openwrt25.12.6] - 2026-11-25

### Fixed

- The service refuses to log when `log_prefix` is not on a mounted external
  drive, so a missing microSD card no longer means logging to flash. New option
  `log_to_flash` to allow it anyway.
- Stopping the service removes the monitor interfaces Kismet created, so the
  radio can go back to normal use.

## [v2026.10.1-r1.1-openwrt25.12.6] - 2026-11-25

### Added

- `kismet-server`: the Kismet server and web UI on the router, with a procd
  service configured in `/etc/config/kismet` and router memory limits in
  `/etc/kismet/kismet_site.conf`. Includes `kismetdb_to_pcap` and
  `kismetdb_strip_packets`.
- `kismet-capture-sdr`: RTL-SDR capture tools for ADS-B (with the ICAO aircraft
  database), rtl_433 and AIS.

## [v2026.10.1-r1-openwrt25.12.6] - 2026-11-25

First release.

### Added

- `kismet-capture-linux-wifi`: Kismet's Wi-Fi capture tool for OpenWrt 25.12,
  `aarch64_cortex-a53`, with websockets and legacy TCP remote capture.
- CI that builds with the official OpenWrt SDK, smoke-tests on an ARM emulator
  and publishes releases with `SHA256SUMS`.
