# Remote capture to a PC

If you already run Kismet on a PC, the router can act as a remote sensor: it
captures with its own radio and streams the frames to Kismet on the PC over the
network. Only `kismet-capture-linux-wifi` is needed on the router.

## On the PC

Install Kismet 2026-10-R1 or newer (on Arch: `sudo pacman -S kismet`) and start
it once. Open `http://localhost:2501` and create a login.

The router must be able to reach the PC's port 2501:

- Kismet must listen on all interfaces. Add to `/etc/kismet/kismet_site.conf`:

  ```ini
  httpd_bind_address=0.0.0.0
  ```

- If the PC runs a firewall (ufw, firewalld), open TCP 2501 for your LAN.

Find the PC's LAN address with `ip -4 addr`.

## On the router

[Free a radio](/features/wifi-capture#free-a-radio), then:

```sh
kismet_cap_linux_wifi --connect <pc-ip>:2501 \
  --user <kismet-user> --password <password> \
  --source=wlan1:name=router-2g
```

The source appears under **Data sources** in the web UI on the PC. All
[source options](/features/wifi-capture#source-options) work here too.

### Keep it running after you log out

```sh
nohup kismet_cap_linux_wifi --connect <pc-ip>:2501 \
  --user <kismet-user> --password <password> \
  --source=wlan1:name=router-2g > /tmp/kismet-cap.log 2>&1 &
```

The tool reconnects by itself if the PC goes away (`--disable-retry` turns this
off).

### API key instead of a password

In the web UI, create an API key with the **datasource** role, then use
`--apikey <key>` in place of `--user` and `--password`.

## Legacy TCP protocol

Kismet's older remote-capture protocol needs no login, which also means anyone
on the network can feed data to your Kismet. Use it only on a LAN you trust.

On the PC, in `kismet_site.conf`:

```ini
remote_capture_enabled=true
remote_capture_listen=0.0.0.0
remote_capture_port=3501
```

On the router:

```sh
kismet_cap_linux_wifi --tcp --connect <pc-ip>:3501 --source=wlan1:name=router-2g
```

## Stop

```sh
killall kismet_cap_linux_wifi
iw dev wlan1mon del
```
