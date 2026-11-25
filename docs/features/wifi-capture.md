# Wi-Fi capture

`kismet_cap_linux_wifi` puts a radio into monitor mode, hops through the
channels and hands every frame to Kismet: access points, clients, probe
requests, WPA handshakes and so on. The Kismet server starts it for each
`source`; for [remote capture](/features/remote-capture) you start it yourself.

## Free a radio

A radio in monitor mode can't also serve your Wi-Fi network. With an access
point and a monitor interface on the same radio, many drivers only capture the
router's own traffic.

1. Find the radio for the band you want to watch:

   ```sh
   uci show wireless | grep -E "radio[0-9]=|\.band="
   iw dev
   ```

2. Disable its access point:

   ```sh
   uci set wireless.radio1.disabled=1 && uci commit wireless && wifi reload
   ```

3. Give its phy an interface for Kismet to use:

   ```sh
   iw phy phy1 interface add wlan1 type managed
   ```

Kismet creates `wlan1mon` on top of it when capture starts, and the service
removes it again when stopped.

::: warning Keep a way in
Stay connected by Ethernet, or through the other radio, before you disable one.
:::

::: info After a reboot
`iw phy … interface add` doesn't survive a reboot. Run it again before starting
Kismet, or put it in `/etc/rc.local` above `exit 0`.
:::

## Source options

A source is the interface name followed by options:

```text
wlan1:name=router-2g,channels="1,6,11"
```

| Option | Example | Effect |
|---|---|---|
| `name` | `name=router-2g` | name shown in the web UI |
| `channel` | `channel=6` | stay on one channel (no hopping) |
| `channels` | `channels="1,6,11"` | hop only these channels |
| `add_channels` | `add_channels="14"` | hop the default list plus these |
| `block_channels` | `block_channels="12,13"` | hop the default list minus these |
| `band24ghz` / `band5ghz` / `band6ghz` | `band5ghz=false` | include or skip a whole band |
| `ht_channels` / `vht_channels` | `vht_channels=false` | hop the wider HT40 / VHT80/160 channel variants or not |

Quote the source when it contains `"`, as in the examples.

### Examples

```sh
# 2.4 GHz, the three non-overlapping channels
uci add_list kismet.main.source='wlan1:name=2g,channels="1,6,11"'

# 5 GHz, UNII-1 and UNII-3 only
uci add_list kismet.main.source='wlan0:name=5g,channels="36,40,44,48,149,153,157,161,165"'

# one channel, e.g. to watch a single network
uci add_list kismet.main.source='wlan1:name=ch6,channel=6'
```

Remove a source with `uci del_list` using exactly the same string, then
`uci commit kismet && /etc/init.d/kismet restart`.

## What a router radio can and can't do

- **Monitor mode** uses the standard Linux mac80211 interface. It has been tested
  on the Qualcomm ath11k radios of the [GL-AXT1800](/hardware/gl-axt1800); other
  mac80211 drivers, such as MediaTek mt76, normally support it as well.
- **Signal strength and data rates** reported in monitor mode can be inexact on
  some drivers.
- **Busy channels** may drop frames. A router CPU is slower than a PC's.
- **Packet injection** (sending frames, for example deauthentication) is not
  something Kismet does, and router drivers aren't built for it.
