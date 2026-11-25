# Troubleshooting

## Where are the logs?

| What | Command |
|---|---|
| Kismet service on the router | `logread -e kismet` |
| Follow it live | `logread -f -e kismet` |
| Is the service running? | `ubus call service list '{"name":"kismet"}'` |
| Remote capture tool | printed to the terminal you started it in |

Restart after changing the config:

```sh
/etc/init.d/kismet restart
```

## The service doesn't start

**`kismet: disabled in /etc/config/kismet`**: set `enabled` to `1`:

```sh
uci set kismet.main.enabled=1 && uci commit kismet && /etc/init.d/kismet start
```

**The web UI doesn't open.** Kismet takes a few seconds to start while it loads
its aircraft database. Check that it is listening:

```sh
netstat -ltn | grep 2501
```

## No networks appear

| What you see | Fix |
|---|---|
| The source isn't listed in the web UI | The interface in `source` doesn't exist. Create it with `iw phy phyN interface add wlan1 type managed` and restart. |
| The source is listed but has an error | Read `logread -e kismet`. The radio may still be in use as an access point. |
| Source running, 0 packets | Disable the radio's access point (see [Wi-Fi capture](/features/wifi-capture#free-a-radio)). |
| Only the router's own traffic | Same: the access point and the monitor interface share one radio. |
| Signal or data rates look wrong | A known limit of some Wi-Fi drivers in monitor mode, not a fault in the package. |

## Remote capture doesn't connect

| Message | Fix |
|---|---|
| `401` / `unauthorized` | Wrong user name, password or API key. |
| `could not connect` / timeout | Wrong PC address, the PC firewall blocks TCP 2501, or Kismet on the PC only listens on localhost (`httpd_bind_address=0.0.0.0`). |
| Connects with `--tcp`, but nothing arrives | `remote_capture_enabled=true` is missing on the server. |

## Logging doesn't start

```text
kismet: /mnt/sda1/kismet is not on external storage (mount: /), not logging
```

That's the flash protection: the card or drive in `log_prefix` isn't mounted.
Check with `df -h`, fix the mount, then restart. See [Logging](/features/logging).

## The SDR dongle isn't found

```sh
kismet_cap_sdr_rtladsb --list
```

- **`No supported data sources found`**: the router doesn't see the dongle. Check
  that it is in the USB port, try another port or a powered USB hub.
- **The dongle is found but Kismet doesn't use it**: the source name must be
  `rtladsb-0` (or `rtl433-0`, `rtlais-0`); the number picks the dongle.
- One dongle can serve only one source at a time.

## The radio stays in monitor mode

Stopping the service removes the monitor interfaces it created. If Kismet
crashed, remove them by hand:

```sh
iw dev | grep mon          # e.g. wlan1mon
iw dev wlan1mon del
```

## Low memory

Kismet's memory use grows with the number of devices it tracks. Lower the
limits in `/etc/kismet/kismet_site.conf` (see
[Configuration](/reference/configuration#kismet-site-conf)), and check:

```sh
grep VmRSS /proc/$(pidof kismet)/status
free -m
```
