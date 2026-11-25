include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture
PKG_VERSION:=2026.10.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kismetwireless/kismet.git
PKG_SOURCE_VERSION:=361328d9702457e7ba27b2be796a196180e765e8
PKG_SOURCE_DATE:=2026-10-01
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libpcap libnl-tiny libwebsockets
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=0

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-linux-wifi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  TITLE:=Kismet remote capture tool for Linux Wi-Fi (kismet_cap_linux_wifi)
  URL:=https://www.kismetwireless.net/
  DEPENDS:=+libpcap +libnl-tiny +libwebsockets-mbedtls +libpthread
endef

define Package/kismet-capture-linux-wifi/description
 Remote capture helper from Kismet 2026-10-R1. Puts a mac80211 radio in
 monitor mode, hops channels and streams frames to a Kismet server on
 another machine, over websockets (default) or the legacy TCP protocol (--tcp).
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny
TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny

CONFIGURE_ARGS += \
	--enable-capture-tools-only \
	--with-netlink-tiny \
	--disable-python-tools \
	--disable-debuglibs \
	--disable-libcap \
	--disable-pcre \
	--disable-libnm \
	--disable-libusb \
	--disable-usbwifi \
	--disable-mm8108 \
	--disable-usbserial \
	--disable-wifi-coconut \
	--disable-ubertooth \
	--disable-librtlsdr \
	--disable-bladerf \
	--disable-btgeiger \
	--disable-cell \
	--disable-mosquitto \
	--disable-lmsensors \
	--disable-firmware-compression

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		capture_linux_wifi/kismet_cap_linux_wifi
endef

define Package/kismet-capture-linux-wifi/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_linux_wifi/kismet_cap_linux_wifi $(1)/usr/bin/
endef

$(eval $(call BuildPackage,kismet-capture-linux-wifi))
