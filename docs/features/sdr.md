# SDR: aircraft, sensors and ships

`kismet-capture-sdr` lets Kismet listen far beyond Wi-Fi with a cheap RTL-SDR
USB dongle in the router's USB port. Nothing here uses the router's own radios.

| Source | Frequency | What you see |
|---|---|---|
| `rtladsb` | 1090 MHz | Aircraft: ICAO address, flight number, position, altitude, speed. The bundled database adds registration and aircraft type. |
| `rtl433` | 433 / 868 / 915 MHz (region-dependent) | Weather stations, tyre-pressure sensors, doorbells, power meters, and the hundreds of other devices rtl_433 decodes |
| `rtlais` | 162 MHz | Ship transponders (only near a coast or a large river) |

## What you need

- **An RTL-SDR dongle** with the RTL2832U chip. The RTL-SDR Blog V3 is a safe
  choice. Newer models (such as the V4) need recent driver support; the OpenWrt
  feed ships librtlsdr 2.0.2.
- **An antenna for the band.** For aircraft, the telescopic dipole sold with
  most kits works with each arm pulled out to about **6.9 cm** (a quarter
  wavelength at 1090 MHz). A dedicated 1090 MHz antenna does better.
- **A good spot.** Aircraft and ships are line of sight: put the antenna as high
  as possible, at a window or outdoors.

::: warning USB power
Some routers can't power a dongle from their USB port reliably. If the dongle
disappears or resets, use a powered USB hub.
:::

## Check the dongle

```sh
cat /sys/bus/usb/devices/*/idVendor /sys/bus/usb/devices/*/idProduct 2>/dev/null \
  | paste - - | grep -i 0bda     # most RTL-SDR dongles are 0bda:2838
kismet_cap_sdr_rtladsb --list
```

## Add it to Kismet

```sh
uci add_list kismet.main.source='rtladsb-0:name=adsb'
uci commit kismet && /etc/init.d/kismet restart
```

The number after the type picks the dongle: `rtladsb-0` is the first one,
`rtl433-1` the second, and so on. **One dongle serves one source at a time**;
with two dongles you can watch aircraft and sensors together:

```sh
uci add_list kismet.main.source='rtladsb-0:name=adsb'
uci add_list kismet.main.source='rtl433-1:name=sensors'
```

### Switch a dongle to another mode

```sh
uci del_list kismet.main.source='rtladsb-0:name=adsb'
uci add_list kismet.main.source='rtl433-0:name=sensors'
uci commit kismet && /etc/init.d/kismet restart
```

## Source options

| Option | Example | Effect |
|---|---|---|
| `name` | `name=adsb` | name shown in the web UI |
| `gain` | `gain=40` | fixed tuner gain in dB instead of automatic |
| `ppm` | `ppm=1` | frequency correction for cheap dongles |
| `biast` | `biast=true` | power an active antenna or amplifier through the coax (only if yours needs it) |
| `frequency` | `frequency=868000000` | rtl433 only: listen on another frequency (Hz) |

## Where it shows up

Aircraft, sensors and ships appear as devices in the web UI with their own
device types (for example **ADSB**). Use the device-type filter to show only
those.

## What was tested

The SDR tools and the aircraft database were tested in an emulator without a
dongle: the server registers all three source types, loads the database
(353,010 aircraft) and probes for a dongle when a source is added. Reception
with a real dongle has not been tested yet.
