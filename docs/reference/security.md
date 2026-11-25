# Security

## Web UI and API

* Kismet asks for a login on first use and requires it for the web UI and the
  API. Unauthenticated API requests get `401`.
* The web UI uses plain HTTP on port 2501. Your login and everything Kismet
  shows travel unencrypted on your LAN.
* Kismet listens on all of the router's addresses. OpenWrt's default firewall
  rejects incoming connections on the WAN side, so the web UI is reachable from
  your LAN only. **Don't open port 2501 on the WAN.** To restrict it further,
  set `httpd_bind_address` in [`kismet_site.conf`](/reference/configuration#kismet-site-conf).
* The login is stored in `<homedir>/.kismet/kismet_httpd.conf` (`/root` by
  default), readable by root only.

## Remote capture

* The default websockets mode requires a Kismet login or an API key. Use an API
  key with the *datasource* role rather than an admin password where you can.
* The legacy TCP mode (`--tcp`, port 3501) has **no authentication**: anyone who
  can reach the port can feed data to Kismet. Enable it only on a trusted LAN.

## Packages

* The packages are not signed with an apk key, so they are installed with
  `--allow-untrusted`. Each release has a `SHA256SUMS` file to check the
  downloads against.
* Packages are built by GitHub Actions from this repository and the pinned
  upstream Kismet commit; nothing is built on a personal machine.
* Dependencies come from the official OpenWrt feed and are verified by apk as
  usual.

## What Kismet does on the router

* It runs as root, like most OpenWrt services, because monitor mode and raw
  capture need it.
* It only listens: Kismet doesn't transmit on the monitored radio or send
  frames to other devices.
* It makes no outgoing connections. Remote capture connects only to the server
  you name.

## Legal

Capturing traffic on networks you don't own or have permission to test may be
illegal where you live. Receiving ADS-B and AIS is legal in most countries;
check your local rules.
