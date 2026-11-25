# Kismet on the router

`kismet-server` runs the full Kismet server on the router as an OpenWrt
service. You open its web UI from any browser on your LAN; no PC software is
needed.

## Enable

```sh
uci set kismet.main.enabled=1
uci add_list kismet.main.source='wlan1:name=router-2g'
uci commit kismet
/etc/init.d/kismet enable     # start at boot
/etc/init.d/kismet start
```

`source` takes one capture source per entry; add as many as you have free
radios or dongles. The source format is explained in
[Wi-Fi capture](/features/wifi-capture#source-options) and [SDR](/features/sdr).

The service is off after installation until you set `enabled` to `1`.

## Web UI

Open **`http://<router-ip>:2501`** (on a default OpenWrt install,
`http://192.168.1.1:2501`). On the first visit Kismet asks you to create a user
name and password. They are stored in `/root/.kismet/kismet_httpd.conf` (the
`homedir` option moves this).

Kismet takes a few seconds to start, mostly loading its aircraft database.

::: tip Reset the login
Stop the service, delete `/root/.kismet/kismet_httpd.conf`, start it again and
open the web UI to create a new login.
:::

The web UI is reachable from your LAN only: OpenWrt's default firewall blocks
incoming connections on the WAN side. See [Security](/reference/security).

## Service commands

| Command | Does |
|---|---|
| `/etc/init.d/kismet start` | start (if `enabled` is `1`) |
| `/etc/init.d/kismet stop` | stop, and remove the monitor interfaces it created |
| `/etc/init.d/kismet restart` | apply changes to the config |
| `/etc/init.d/kismet enable` / `disable` | start at boot, or not |

procd restarts Kismet if it crashes. A `uci commit kismet` followed by
`reload_config` also restarts it.

## Remote sources

The server on the router also accepts remote capture sources, so another
router or a Linux machine can feed it:

```sh
# on the other machine
kismet_cap_linux_wifi --connect <router-ip>:2501 --user <user> --password <password> \
  --source=wlan0:name=second-sensor
```

## Memory

In testing with one network in range, Kismet used about 33 MB of RAM and the
capture tool 3 MB. Memory grows with the number of devices Kismet tracks, so
the package sets limits suited to a router in `/etc/kismet/kismet_site.conf`:

| Setting | Default here | Effect |
|---|---|---|
| `tracker_device_timeout` | `1800` | forget devices not seen for 30 minutes |
| `tracker_max_devices` | `3000` | track at most 3000 devices at once |
| `track_device_rrds` | `false` | no per-device history graphs |
| `keep_per_datasource_stats` | `false` | no per-source statistics per device |

In a crowded place (a city centre, a conference), lower `tracker_max_devices`
on a router with 256 MB of RAM. See [Configuration](/reference/configuration).

## CPU

One radio hopping channels is light work. Several sources on busy channels,
or logging every packet, use noticeably more CPU on a small router.
