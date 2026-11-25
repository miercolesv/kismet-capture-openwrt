# Configuration

Kismet on the router is configured in two places:

| File | Holds | Edit with |
|---|---|---|
| `/etc/config/kismet` | what the service starts: sources, logging, login location | `uci` or any editor |
| `/etc/kismet/kismet_site.conf` | Kismet's own settings (memory limits, web server, alerts …) | any editor |

Both are kept when you upgrade the package. Restart after a change:

```sh
/etc/init.d/kismet restart
```

## `/etc/config/kismet`

```text
config kismet 'main'
	option enabled '0'
	list source 'wlan1:name=router-2g'
	option logging '0'
	option log_prefix '/mnt/sda1/kismet'
	option log_to_flash '0'
	option homedir '/root'
```

| Option | Default | Meaning |
|---|---|---|
| `enabled` | `0` | `1` lets the service start. |
| `source` | (none) | A capture source, one per `list source` line. See [Wi-Fi capture](/features/wifi-capture#source-options) and [SDR](/features/sdr#source-options). Remote sources can connect without being listed. |
| `logging` | `0` | `1` writes a `.kismet` log to `log_prefix`. See [Logging](/features/logging). |
| `log_prefix` | `/mnt/sda1/kismet` | Folder for log files. Must be on external storage unless `log_to_flash` is `1`. |
| `log_to_flash` | `0` | `1` allows logging to flash or RAM. |
| `homedir` | `/root` | Kismet's home folder; the web UI login is stored in `<homedir>/.kismet/kismet_httpd.conf`. |

### With uci

```sh
uci set kismet.main.enabled=1
uci add_list kismet.main.source='wlan1:name=router-2g'
uci del_list kismet.main.source='wlan1:name=router-2g'
uci show kismet
uci commit kismet
```

## `/etc/kismet/kismet_site.conf` {#kismet-site-conf}

Settings in this file override Kismet's stock configuration
(`/etc/kismet/kismet.conf` and the files it includes). The package ships it
with limits suited to a router:

```ini
tracker_device_timeout=1800
tracker_max_devices=3000
track_device_rrds=false
keep_per_datasource_stats=false
alertbacklog=25
log_prefix=/tmp/
```

| Setting | Meaning |
|---|---|
| `tracker_device_timeout` | Seconds after which a device that hasn't been seen is forgotten. |
| `tracker_max_devices` | Maximum number of devices tracked at once; the oldest are dropped. |
| `track_device_rrds` | Per-device activity graphs. Costs memory per device. |
| `keep_per_datasource_stats` | Per-source statistics for every device. |
| `alertbacklog` | Number of alerts kept in memory. |
| `log_prefix` | Fallback log folder; the service passes `log_prefix` from `/etc/config/kismet` instead. |

Any other Kismet setting can go here too, for example:

```ini
httpd_bind_address=192.168.1.1   # web UI only on this address
httpd_port=2501
```

The stock files in `/etc/kismet/` (`kismet.conf`, `kismet_memory.conf`,
`kismet_alerts.conf`, `kismet_logging.conf` …) are replaced on upgrade: change
settings in `kismet_site.conf`, not there.
