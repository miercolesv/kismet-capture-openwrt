---
layout: home

hero:
  name: Kismet for OpenWrt
  text: A wireless sniffer that lives on your router
  tagline: Kismet 2026-10-R1 packaged for OpenWrt 25.12. Monitor-mode Wi-Fi capture, the full Kismet web UI and RTL-SDR tools, installed with apk.
  image:
    src: /logo.svg
    alt: Kismet for OpenWrt
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: alt
      text: Configuration reference
      link: /reference/configuration

features:
  - icon: 📡
    title: Kismet on the router
    details: The Kismet server and web UI run on the router itself as a normal OpenWrt service. Open it from any browser on your LAN.
    link: /features/server
  - icon: 📶
    title: Monitor-mode Wi-Fi capture
    details: Puts a free radio into monitor mode and hops channels. Networks, clients, probes and handshakes show up in Kismet.
    link: /features/wifi-capture
  - icon: 💻
    title: Remote capture
    details: Or keep Kismet on your PC and use the router as a network-attached sensor, like a USB adapter on a long cable.
    link: /features/remote-capture
  - icon: ✈️
    title: Aircraft, sensors and ships
    details: With an RTL-SDR dongle, Kismet decodes ADS-B aircraft, rtl_433 sensors and AIS ship transponders.
    link: /features/sdr
  - icon: 💾
    title: Flash-safe logging
    details: Logs go to a microSD card or USB drive, never to flash. Convert them to pcap for Wireshark.
    link: /features/logging
  - icon: 🧪
    title: Built and tested in CI
    details: Every package is built with the official OpenWrt SDK, smoke-tested on an ARM emulator and published as a GitHub release.
    link: /reference/building
---
