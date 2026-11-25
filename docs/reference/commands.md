# Commands

## Service

```text
/etc/init.d/kismet start        start (needs enabled=1 in /etc/config/kismet)
/etc/init.d/kismet stop         stop and remove the monitor interfaces it created
/etc/init.d/kismet restart      apply configuration changes
/etc/init.d/kismet enable       start at boot
/etc/init.d/kismet disable      don't start at boot
logread -e kismet               show Kismet's log
```

## `kismet`

The server. The service starts it as:

```text
kismet --no-ncurses --homedir <homedir> -c <source> [-c <source>…] (-n | -p <log_prefix>)
```

| Option | Meaning |
|---|---|
| `-c <source>` | add a capture source |
| `-n` | no logging |
| `-p <folder>` | log into this folder |
| `--homedir <folder>` | where `.kismet/` (login, state) is kept |
| `--no-ncurses` | no terminal UI |
| `--version` | print the version |

## `kismet_cap_linux_wifi`

The Wi-Fi capture tool. Kismet starts it by itself for local sources; you run
it by hand only for [remote capture](/features/remote-capture).

```text
kismet_cap_linux_wifi --connect <host>:<port> [options] --source=<source>
```

| Option | Meaning |
|---|---|
| `--connect <host>:<port>` | send to the Kismet server at this address (websockets on port 2501 by default) |
| `--user <name>` / `--password <pw>` | Kismet login (websockets mode) |
| `--apikey <key>` | API key with the *datasource* role, instead of user and password |
| `--tcp` | use the legacy TCP protocol (port 3501, no login) |
| `--source <source>` | the interface and its [options](/features/wifi-capture#source-options) |
| `--disable-retry` | exit on error instead of reconnecting |
| `--fixed-gps <lat,lon[,alt]>` | attach a fixed location to everything this source sees |
| `--daemonize` | run in the background |
| `--list` | list interfaces that can be used |
| `--version` | print the version |

`--ssl` and `--ssl-certificate` (for a Kismet server behind TLS) are available
but have not been tested with these packages.

## SDR capture tools

`kismet_cap_sdr_rtladsb`, `kismet_cap_sdr_rtl433` and `kismet_cap_sdr_rtlais`
take the same options as `kismet_cap_linux_wifi`. They are normally started by
Kismet from a `source` such as `rtladsb-0`. `--list` shows the dongles they can
use.

## Log tools

```text
kismetdb_to_pcap --in <log>.kismet --out <file>.pcap
kismetdb_strip_packets --in <log>.kismet --out <smaller>.kismet
```

See [Logging](/features/logging).
