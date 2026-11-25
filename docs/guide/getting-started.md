# Getting started

This page takes you from a stock OpenWrt router to Kismet running in your
browser in a few minutes.

## 1. Check your router

The packages fit OpenWrt **25.12.x** on routers whose package architecture is
**`aarch64_cortex-a53`**. On the router:

```sh
cat /etc/openwrt_release
```

You need both of these lines:

```text
DISTRIB_RELEASE='25.12.6'           # any 25.12.x
DISTRIB_ARCH='aarch64_cortex-a53'
```

[Supported routers](/hardware/other-routers) lists models known to match.

## 2. Pick a setup

| Setup | Kismet runs on | Use it when |
|---|---|---|
| **On the router** | the router | you want a standalone sensor you open from a phone or laptop |
| **Remote capture** | your PC | you already run Kismet on a PC and want the router as an extra radio |

You can switch between them at any time: both use the same capture tool.

## 3. Install

Open the [latest release](https://github.com/miercolesv/kismet-capture-openwrt/releases/latest)
and run the install commands from its notes on the router. They look like this:

```sh
cd /tmp
U=https://github.com/miercolesv/kismet-capture-openwrt/releases/download/<tag>
wget $U/kismet-capture-linux-wifi-<version>.apk $U/kismet-server-<version>.apk
apk add --allow-untrusted ./kismet-*.apk
```

For remote capture only, `kismet-capture-linux-wifi` is enough.
[Installation](/guide/installation) covers checksums, upgrades and removal.

## 4. Free a radio

A radio can't serve your Wi-Fi network and capture everything around it at the
same time. Pick the radio you don't need (or use the router only as a sensor):

```sh
uci show wireless | grep -E "radio[0-9]=|\.band="   # which radio is 2g / 5g
iw dev                                              # which phy each radio is
```

Then disable that radio's access point and give its phy a plain interface
(example: `radio1` on `phy1`):

```sh
uci set wireless.radio1.disabled=1 && uci commit wireless && wifi reload
iw phy phy1 interface add wlan1 type managed
```

::: warning Keep a way in
Stay connected by Ethernet, or through the other radio, before you disable one.
:::

## 5. Start Kismet

::: code-group

```sh [On the router]
uci set kismet.main.enabled=1
uci add_list kismet.main.source='wlan1:name=router-2g'
uci commit kismet
/etc/init.d/kismet enable
/etc/init.d/kismet start
# then open http://192.168.1.1:2501 and create a login
```

```sh [Remote capture]
# start Kismet on the PC first, then on the router:
kismet_cap_linux_wifi --connect <pc-ip>:2501 \
  --user <kismet-user> --password <password> --source=wlan1:name=router-2g
```

:::

Kismet takes a few seconds to start (it loads its aircraft database). Networks
appear in the web UI as the radio hops through the channels.

## Next steps

- [Kismet on the router](/features/server): the service, the web UI and memory limits
- [Wi-Fi capture](/features/wifi-capture): channels, bands and source options
- [Logging](/features/logging): keep a record on a microSD card
- [SDR](/features/sdr): aircraft, sensors and ships with an RTL-SDR dongle

::: tip Only your own networks
Capturing traffic on networks you don't own or have permission to test may be
illegal where you live.
:::
