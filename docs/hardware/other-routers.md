# Other routers

The packages are not tied to one router. They run on any device with:

* OpenWrt **25.12.x**, and
* the package architecture **`aarch64_cortex-a53`**.

Check on the router:

```sh
grep -E "DISTRIB_RELEASE|DISTRIB_ARCH" /etc/openwrt_release
```

## OpenWrt targets with this architecture

These OpenWrt 25.12.6 targets build for `aarch64_cortex-a53` (from the
official download server):

| Target | Examples |
|---|---|
| `qualcommax/ipq60xx` | GL.iNet GL-AXT1800, GL-AX1800, Linksys MR7350 / MR7500 |
| `qualcommax/ipq807x` | Xiaomi AX3600 / AX9000, Dynalink DL-WRX36, Linksys MX4200 / MX5300 |
| `qualcommax/ipq50xx` | various Wi-Fi 6 routers |
| `mediatek/filogic` | Cudy TR3000, WR3000, M3000; ASUS RT-AX52, RT-AX59U, TUF-AX4200; Banana Pi BPI-R3 / R4; and more than 180 other models |
| `mediatek/mt7622` | Linksys E8450, Xiaomi Redmi AX6S, Banana Pi BPI-R64 |
| `mvebu/cortexa53` | Marvell Armada 3700 boards |
| `bcm27xx/bcm2710` | Raspberry Pi 3 (64-bit) |
| `sunxi/cortexa53`, `imx/cortexa53`, `bcm4908/generic` | other boards |

Only the [GL-AXT1800](/hardware/gl-axt1800) has been tested. On the others the
packages install the same way, but Wi-Fi monitor mode depends on the router's
Wi-Fi driver.

## Cudy TR3000

Target `mediatek/filogic`, package architecture `aarch64_cortex-a53`: the
packages install unchanged. Its radios use the MediaTek `mt76` driver, which
normally supports monitor mode; not tested yet.

## What to check on a new router

1. `apk add` succeeds and pulls the dependencies.
2. `kismet_cap_linux_wifi --list` shows the free radio's interface.
3. With the access point on that radio disabled, the source runs in the web UI
   and networks appear.
4. `grep VmRSS /proc/$(pidof kismet)/status` after a while: Kismet's memory use
   fits the router's RAM. On 256 MB routers, lower `tracker_max_devices`.

If you try another router, a report (an issue or a pull request adding a page
here) helps others.

## Routers with a different architecture

Packages for another architecture (for example `aarch64_generic`,
`arm_cortex-a7_neon-vfpv4` or `mipsel_24kc`) need their own build: add the
target to the CI workflow. Kismet's server needs a lot of RAM and flash, so it
only makes sense on routers with at least 256 MB of RAM; the Wi-Fi capture tool
alone is small enough for most.
