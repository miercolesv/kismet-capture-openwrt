# Building

## CI

`.github/workflows/build.yml` builds every package on each push:

1. Downloads the official OpenWrt SDK for the release and target
   (`25.12.6`, `qualcommax/ipq60xx`).
2. Builds the dependencies and the packages in `net/`. The SDK, including the
   built dependencies, is cached between runs.
3. Smoke-tests the result on an ARM emulator: every binary must start and
   report its version or help text.
4. On `main`, publishes a GitHub release with the packages and `SHA256SUMS`,
   unless a release with the same version already exists.

A full build of the server takes about 30 minutes; a run that only rebuilds the
capture tool takes a few minutes.

Run the workflow by hand (**Actions → build → Run workflow**) to build for
another OpenWrt release with the `release` input.

## Build locally

On Linux x86_64 (Arch, Debian, Ubuntu or WSL2), as a normal user:

```sh
RELEASE=25.12.6 ./scripts/build.sh          # all packages, output in dist/
PKGS=kismet-capture ./scripts/build.sh      # only the Wi-Fi capture tool
```

You need the usual build tools (`gcc`, `make`, `gawk`, `git`, `python3`,
`rsync`, `unzip`, `wget`, `zstd`, `file`) and, for the smoke test,
`qemu-aarch64` (`qemu-user-static` on Debian/Ubuntu, `qemu-user` on Arch).

::: warning Memory
Some Kismet C++ files need about 2.5 GB of RAM each to compile. The build runs
as many compile jobs as fit in the available memory, and retries with one job if
a compile is killed anyway.
:::

## Repository layout

| Path | What |
|---|---|
| `net/kismet-capture/Makefile` | `kismet-capture-linux-wifi` (capture tools only build) |
| `net/kismet/Makefile` | `kismet-server` and `kismet-capture-sdr` (full build) |
| `net/kismet/files/` | service script, uci config, `kismet_site.conf` |
| `scripts/build.sh` | SDK download, feeds, build and smoke test |
| `.github/workflows/build.yml` | CI and releases |
| `docs/` | this site |

## Notes on the build

* The upstream source is fetched with git at a pinned commit
  (`PKG_SOURCE_VERSION`).
* Kismet's generated `Makefile.inc` adds `-g` and `-O3`; the package removes
  both (and `-pipe`), so the server is built with OpenWrt's `-Os`. That keeps
  the binary small and the compiler's memory use down.
* The C++ code needs C++20. Configure records the right compiler flags, so the
  package doesn't override `CXX` when it runs `make`.
* `libnl-tiny` replaces libnl; the SDR tools use `librtlsdr` and `libusb` from
  the feed.

## Publishing a new build

Bump `PKG_RELEASE` in the Makefile you changed and push to `main`. apk never
reinstalls the same version, so a router only upgrades to a new release
number.

To move to a new Kismet version, change `PKG_VERSION`, `PKG_SOURCE_VERSION` and
`PKG_SOURCE_DATE` in both Makefiles and reset `PKG_RELEASE` to `1`.
