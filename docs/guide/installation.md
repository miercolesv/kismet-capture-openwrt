# Installation

## Packages

| Package | Install it for |
|---|---|
| `kismet-capture-linux-wifi` | Wi-Fi capture. Needed by everything else; on its own it is all you need for [remote capture](/features/remote-capture). |
| `kismet-server` | Kismet and its web UI on the router. Pulls in `kismet-capture-linux-wifi`. |
| `kismet-capture-sdr` | RTL-SDR dongles: aircraft, sensors, ships. |

[Packages](/reference/packages) lists what each one installs and depends on.

## Download and install

Release files are on the
[releases page](https://github.com/miercolesv/kismet-capture-openwrt/releases).
Each release lists its install commands; the pattern is:

```sh
cd /tmp
U=https://github.com/miercolesv/kismet-capture-openwrt/releases/download/<tag>
wget $U/kismet-capture-linux-wifi-<version>.apk \
     $U/kismet-server-<version>.apk \
     $U/kismet-capture-sdr-<version>.apk \
     $U/SHA256SUMS
sha256sum -c SHA256SUMS
apk add --allow-untrusted ./kismet-*.apk
```

`apk` installs the dependencies (libpcap, OpenSSL, sqlite, the C++ runtime,
librtlsdr, rtl_433 and so on) from the official OpenWrt feed, so the router needs
internet access during the install.

::: info Why `--allow-untrusted`
The packages are not signed with a key your router knows. `sha256sum -c` checks
that the files are exactly the ones CI built.
:::

### Router without internet for HTTPS

If the router can't download from GitHub, download the files on your computer
and copy them over:

```sh
scp kismet-*.apk root@192.168.1.1:/tmp/
```

On some systems `scp` needs `-O` because OpenWrt has no SFTP server.

## Upgrade

Download the new release's files and run the same `apk add` command. Your
`/etc/config/kismet` and `/etc/kismet/kismet_site.conf` are kept.

```sh
apk add --allow-untrusted ./kismet-*.apk
/etc/init.d/kismet restart
```

## Remove

```sh
/etc/init.d/kismet stop
apk del kismet-server kismet-capture-sdr kismet-capture-linux-wifi
```

Then give the radio back to your Wi-Fi network:

```sh
iw dev wlan1 del
uci set wireless.radio1.disabled=0 && uci commit wireless && wifi reload
```

## Messages you may see

**`unable to select packages … (no such package)` for a dependency**:
the router isn't on OpenWrt 25.12, or `apk update` hasn't been run. Run
`apk update` and try again.

**An architecture error**: the router's package architecture isn't
`aarch64_cortex-a53`. See [Supported routers](/hardware/other-routers).

**`would be lost on next reboot`**: the router's root file system lives in
RAM (unusual for a router, normal for a test VM). Add `--force-non-repository`.
