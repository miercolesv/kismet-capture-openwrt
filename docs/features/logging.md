# Logging and pcap export

Kismet can keep everything it sees in a `.kismet` log: a SQLite database with
devices, packets, alerts and data-source details. It grows continuously, and
constant writes wear out a router's flash, so logging is **off by default** and
the service only logs to external storage.

## Enable

Mount a microSD card or USB drive first (for example with the `block-mount`
package, or LuCI → System → Mount Points), then:

```sh
uci set kismet.main.logging=1
uci set kismet.main.log_prefix=/mnt/sda1/kismet
uci commit kismet && /etc/init.d/kismet restart
```

Log files are named after the date and time Kismet started, for example
`Kismet-20261125-11-22-57-1.kismet`.

## Flash protection

Before it starts, the service checks which file system `log_prefix` is on. If
that is the router's root (flash), overlay, `/rom` or `/tmp` (RAM), it logs a
warning and starts Kismet **without** logging:

```text
kismet: /mnt/sda1/kismet is not on external storage (mount: /), not logging
```

This also catches the common case where the card isn't inserted or mounted and
`/mnt/sda1` would otherwise be created on flash.

To log to flash or RAM anyway (for a short test, for example):

```sh
uci set kismet.main.log_to_flash=1 && uci commit kismet
```

## Convert to pcap for Wireshark

```sh
kismetdb_to_pcap --in /mnt/sda1/kismet/Kismet-<date>.kismet --out /mnt/sda1/capture.pcap
```

Copy `capture.pcap` to your computer and open it in Wireshark. Frames keep their
radio header (channel, signal strength, data rate).

## Make a log smaller

`kismetdb_strip_packets` blanks the stored packet contents in a copy of the log
and keeps everything else (devices, alerts, and each packet's metadata such as
time, channel and signal):

```sh
kismetdb_strip_packets --in big.kismet --out small.kismet
```

## Logs from remote capture

With [remote capture](/features/remote-capture), logging happens on the PC
running Kismet, so none of this applies to the router.
