include $(TOPDIR)/rules.mk

PKG_NAME:=kismet
PKG_VERSION:=2026.10.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kismetwireless/kismet.git
PKG_SOURCE_VERSION:=361328d9702457e7ba27b2be796a196180e765e8
PKG_SOURCE_DATE:=2026-10-01
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libpcap libnl-tiny openssl sqlite3 zlib pcre2 libusb rtl-sdr
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

# Some Kismet C++ files need ~3.5 GB to compile: limit parallel jobs to what fits
# in memory (and to the CPU count).
KISMET_JOBS := $(shell n=$$(nproc); m=$$(awk '/MemAvailable/{j=int($$2/4500000); if(j<1)j=1; print j}' /proc/meminfo); echo $$(( n < m ? n : m )))

define Package/kismet-server
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  TITLE:=Kismet wireless sniffer and IDS server, with web UI
  URL:=https://www.kismetwireless.net/
  DEPENDS:=+libpcap +libnl-tiny +libopenssl +libsqlite3 +zlib +libpcre2 \
	+libstdcpp +libpthread +kismet-capture-linux-wifi
endef

define Package/kismet-server/description
 Kismet 2026-10-R1 server and web UI (port 2501), built for routers.
 Uses kismet_cap_linux_wifi (separate package) for local Wi-Fi capture and
 accepts remote capture sources. Logging is off by default; point it at
 external storage in /etc/config/kismet before enabling it.
endef

define Package/kismet-server/conffiles
/etc/config/kismet
/etc/kismet/kismet_site.conf
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny
TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny

# Kismet's generated Makefile.inc adds -g and -O3 (after OpenWrt's -Os, so -O3 wins).
# Debug info is stripped from the package anyway and -O3 bloats the binary; both make
# single C++ files need several GB to compile. Without -pipe, a compile killed for
# memory cannot leave a truncated object file behind.
define Build/Configure
	$(call Build/Configure/Default)
	$(SED) 's/ -g / /g; s/ -O3//g; s/ -pipe / /g' $(PKG_BUILD_DIR)/Makefile.inc
	grep -qE '(^| )-(g|O3|pipe)( |$$)' $(PKG_BUILD_DIR)/Makefile.inc && \
		{ echo "Makefile.inc still has -g/-O3/-pipe"; exit 1; } || true
endef

CONFIGURE_ARGS += \
	--sysconfdir=/etc/kismet \
	--with-netlink-tiny \
	--disable-python-tools \
	--disable-debuglibs \
	--disable-libcap \
	--disable-libwebsockets \
	--disable-libnm \
	--disable-usbwifi \
	--disable-mm8108 \
	--disable-usbserial \
	--disable-wifi-coconut \
	--disable-ubertooth \
	--disable-bladerf \
	--disable-btgeiger \
	--disable-cell \
	--disable-mosquitto \
	--disable-lmsensors \
	--disable-firmware-compression

define Build/Compile
	# No $(TARGET_CONFIGURE_OPTS) here: configure stored CXX with -std=gnu++20,
	# and overriding CXX on the make command line would drop it.
	+$(MAKE) -j$(KISMET_JOBS) -C $(PKG_BUILD_DIR) \
		AR="$(TARGET_AR)" RANLIB="$(TARGET_RANLIB)" \
		kismet log_tools/kismetdb_to_pcap log_tools/kismetdb_strip_packets \
		capture_sdr_rtladsb_v2/kismet_cap_sdr_rtladsb \
		capture_sdr_rtl433_v2/kismet_cap_sdr_rtl433 \
		capture_sdr_rtlais/kismet_cap_sdr_rtlais
endef

define Package/kismet-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/kismet $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_to_pcap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_strip_packets $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/kismet $(1)/etc/kismet/kismet_site.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/*.conf $(1)/etc/kismet/
	$(INSTALL_DATA) ./files/kismet_site.conf $(1)/etc/kismet/kismet_site.conf

	$(INSTALL_DIR) $(1)/usr/share/kismet
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/kismet_manuf.txt.gz $(1)/usr/share/kismet/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/kismet_bluetooth_ids.txt.gz $(1)/usr/share/kismet/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/kismet_bluetooth_manuf.txt.gz $(1)/usr/share/kismet/
	$(CP) $(PKG_BUILD_DIR)/http_data $(1)/usr/share/kismet/httpd

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/kismet.config $(1)/etc/config/kismet
	$(INSTALL_BIN) ./files/kismet.init $(1)/etc/init.d/kismet
endef

define Package/kismet-capture-sdr
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  TITLE:=Kismet RTL-SDR capture tools: ADS-B (aircraft), rtl_433 sensors, AIS (ships)
  URL:=https://www.kismetwireless.net/
  DEPENDS:=+librtlsdr +libusb-1.0 +zlib +libpthread +rtl_433
endef

define Package/kismet-capture-sdr/description
 Kismet 2026-10-R1 capture tools for RTL-SDR USB dongles:
 kismet_cap_sdr_rtladsb (ADS-B aircraft on 1090 MHz, with the ICAO
 aircraft database), kismet_cap_sdr_rtl433 (433/868/915 MHz sensors via
 rtl_433) and kismet_cap_sdr_rtlais (AIS ship transponders).
endef

define Package/kismet-capture-sdr/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/share/kismet
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_sdr_rtladsb_v2/kismet_cap_sdr_rtladsb $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_sdr_rtl433_v2/kismet_cap_sdr_rtl433 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_sdr_rtlais/kismet_cap_sdr_rtlais $(1)/usr/bin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/kismet_adsb_icao.txt.gz $(1)/usr/share/kismet/
endef

$(eval $(call BuildPackage,kismet-server))
$(eval $(call BuildPackage,kismet-capture-sdr))
