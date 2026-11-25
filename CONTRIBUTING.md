# Contributing

## Build and test

```sh
RELEASE=25.12.6 ./scripts/build.sh          # all packages, output in dist/
PKGS=kismet-capture ./scripts/build.sh      # only the Wi-Fi capture tool
```

This needs Linux x86_64 and a normal user (the OpenWrt SDK refuses to run as
root). The script downloads the SDK, builds the dependencies and the packages,
and runs a smoke test on `qemu-aarch64` if it is installed. The first full
build takes a while; the Kismet server alone needs about 2.5 GB of RAM per
compile job. [Building](docs/reference/building.md) has the details.

Before a change goes in:

* the CI build and its smoke test pass,
* anything that changes behaviour on the router is tested on an emulated or real
  OpenWrt 25.12 router: install with `apk`, start the service, check the web UI
  and a capture source.

## Documentation site

The documentation in `docs/` is a VitePress site, published to GitHub Pages by
`.github/workflows/docs.yml` on every push to `main` that changes it. To preview
it locally:

```sh
cd docs
npm install
npm run dev          # live preview; `npm run build` for the static site
```

In the repository settings, set **Pages → Source** to **GitHub Actions** once.

## Releases

1. Bump `PKG_RELEASE` in the Makefile you changed (`net/kismet-capture/Makefile`
   or `net/kismet/Makefile`). apk never reinstalls the same version.
2. Add a section to `CHANGELOG.md`.
3. Push to `main`.

`.github/workflows/build.yml` builds every package with the official SDK,
smoke-tests it and publishes a release with `SHA256SUMS`. Pushes that only
change documentation don't trigger a build.

## Ground rules

* **Unmodified upstream Kismet**, pinned to a commit. Build fixes belong in the
  package Makefiles; anything else goes upstream.
* **Dependencies only from the official OpenWrt feed** for the release, never
  vendored libraries.
* **Don't write to flash in normal operation.** Logs and other growing files go
  to external storage or RAM, and the service checks it.
* **Off by default.** Installing a package never starts capturing; the user
  enables it.
* **Keep `/etc/config/kismet` and `kismet_site.conf` as conffiles**, so upgrades
  keep the user's settings.
* Commits and documentation describe what was tested and what wasn't.

## Adding a router

If the router already uses `aarch64_cortex-a53`, nothing needs building. Test it
and add a page under `docs/hardware/` with what works.

For another package architecture, add a matrix entry to
`.github/workflows/build.yml` with a target of that architecture, and include
the architecture in the release file names so builds don't collide.
