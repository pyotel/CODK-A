TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CODK_ARC_URL := https://github.com/01org/CODK-A-ARC.git
CODK_ARC_DIR := $(TOP_DIR)/arc
CODK_ARC_TAG ?= master
CODK_X86_URL := https://github.com/01org/CODK-A-X86.git
CODK_X86_DIR := $(TOP_DIR)/x86
CODK_X86_TAG ?= master
CODK_BL_URL := https://github.com/01org/CODK-A-Bootloader.git
CODK_BL_DIR := $(CODK_X86_DIR)/bsp/bootable/bootloader
CODK_BL_TAG ?= master
CODK_FLASHPACK_URL := https://github.com/pyotel/CODK-A-Flashpack.git
CODK_FLASHPACK_DIR := $(TOP_DIR)/flashpack
CODK_FLASHPACK_TAG ?= master
BLE_IMAGE   := $(CODK_FLASHPACK_DIR)/images.dist/firmware/ble_core/imagev3.bin

CODK_DIR ?= $(TOP_DIR)
X86_PROJ_DIR ?= $(CODK_X86_DIR)/projects/arduino101/
ARC_PROJ_DIR ?= $(CODK_ARC_DIR)/examples/ASCIITable/
SKETCH       ?= $(ARC_PROJ_DIR)/$(shell basename $(ARC_PROJ_DIR)).ino
SKETCH_DIR   := $(dir $(SKETCH))

help:
	@echo
	@echo "CODK-A available targets"
	@echo
	@echo "project            : create new blank project (PROJ_DIR variable must be set)"
	@echo "convert-sketch     : convert *.ino to *.cpp (SKETCH variable must be set)"
	@echo "compile-x86        : compile the x86 application in X86_PROJ_DIR"
	@echo "compile-arc        : compile the ARC application in ARC_PROJ_DIR, with debug"
	@echo "                     symbols disabled and optimisation flags enabled"
	@echo "compile-debug-arc  : compile the ARC application in ARC_PROJ_DIR, with debug"
	@echo "                     symbols enabled and optimisation flags disabled"
	@echo "compile            : compile x86 and ARC applications, with debug symbols"
	@echo "                     disabled and optimisation flags enabled"
	@echo "compile-debug      : compile x86 and ARC applications, with debug symbols"
	@echo "                     enabled and optimisation flags disabled"
	@echo "upload-x86-dfu     : upload the x86 application (USB cable & dfu-util)"
	@echo "upload-arc-dfu     : upload the ARC application (USB cable & dfu-util)"
	@echo "upload             : upload the ARC and x86 applications (USB cable & dfu-util)"
	@echo "upload-x86-jtag    : upload the x86 application using OpenOCD configured  "
	@echo "                     for a Flyswatter2 JTAG debugger"
	@echo "upload-arc-jtag    : upload the ARC application using OpenOCD configured  "
	@echo "                     for a Flyswatter2 JTAG debugger"
	@echo "upload-jtag        : upload the ARC and x86 applications using OpenOCD configured "
	@echo "                     for a Flyswatter2 JTAG debugger"
	@echo "upload-x86-jlink   : upload the x86 application using OpenOCD configured "
	@echo "                     for a Jlink JTAG debugger"
	@echo "upload-arc-jlink   : upload the ARC application using OpenOCD configured "
	@echo "                     for a Jlink JTAG debugger"
	@echo "upload-jlink       : upload the ARC and x86 applications using OpenOCD "
	@echo "                     configured for a Jlink JTAG debugger"
	@echo "upload-ble-dfu     : upload the Nordic BLE firmware (USB cable & dfu-util)"
	@echo "debug-server       : start OpenOCD server, configured for a Flyswatter2 "
	@echo "                     JTAG debugger (deprecated)"
	@echo "debug-server-jtag  : start OpenOCD server, configured for a Flyswatter2 "
	@echo "                     JTAG debugger"
	@echo "debug-server-jlink : start OpenOCD server, configured for a Jlink "
	@echo "                     JTAG debugger"
	@echo "debug-x6           : Debug x86 application with GDB"
	@echo "debug-arc          : Debug ARC application with GDB"
	@echo
	
check-root:
	@if [ `whoami` != root ]; then echo "Please run as sudoer/root" && exit 1 ; fi

install-dep: check-root
	$(MAKE) install-dep -C $(CODK_ARC_DIR)
	$(MAKE) one_time_setup -C $(X86_PROJ_DIR)
	dpkg --purge modemmanager
	usermod -a -G dialout $(SUDO_USER)

setup: x86-setup arc-setup

clone: $(CODK_ARC_DIR) $(CODK_X86_DIR) $(CODK_BL_DIR) $(CODK_FLASHPACK_DIR)

$(CODK_ARC_DIR):
	git clone -b $(CODK_ARC_TAG) $(CODK_ARC_URL) $(CODK_ARC_DIR)

$(CODK_X86_DIR):
	git clone -b $(CODK_X86_TAG) $(CODK_X86_URL) $(CODK_X86_DIR)
	ln -s $(abspath $(CODK_X86_DIR)) $(TOP_DIR)firmware

$(CODK_BL_DIR):
	git clone -b $(CODK_BL_TAG) $(CODK_BL_URL) $(CODK_BL_DIR)

$(CODK_FLASHPACK_DIR):
	git clone -b $(CODK_FLASHPACK_TAG) $(CODK_FLASHPACK_URL) $(CODK_FLASHPACK_DIR)

x86-setup:
	@echo "Setting up x86"

arc-setup:
	@echo "Setting up ARC"
	@$(MAKE) -C $(CODK_ARC_DIR) setup CORELIBS_URL=https://github.com/01org/corelibs-arduino101/archive/2.0.0.zip

compile: compile-x86 compile-arc

compile-x86:
	$(MAKE) setup image -C $(X86_PROJ_DIR)

compile-arc:
	CODK_DIR=$(CODK_DIR) $(MAKE) -C $(ARC_PROJ_DIR) compile

convert-sketch:
	CODK_DIR=$(CODK_DIR) $(MAKE) -C $(SKETCH_DIR) convert-sketch SKETCH=$(notdir $(SKETCH))

sleepitoff:
	sleep 10

compile-debug: compile-x86 compile-debug-arc

compile-debug-arc:
	CODK_DIR=$(CODK_DIR) $(MAKE) -C $(ARC_PROJ_DIR) compile-debug

upload: upload-dfu

upload-dfu: upload-x86-dfu sleepitoff upload-arc-dfu

upload-x86-dfu:
	cd $(CODK_FLASHPACK_DIR) && ./create_flasher.sh
	cd $(CODK_FLASHPACK_DIR) && ./flash_dfu.sh

upload-arc-dfu:
	CODK_DIR=$(CODK_DIR) $(MAKE) -C $(ARC_PROJ_DIR) upload

upload-jtag: upload-x86-jtag upload-arc-jtag

upload-x86-jtag:
	cd $(CODK_FLASHPACK_DIR) && ./create_flasher.sh
	cd $(CODK_FLASHPACK_DIR) && ./flash_jtag.sh

upload-arc-jtag:
	cd $(CODK_FLASHPACK_DIR) && ./flash_arc_jtag.sh $(ARC_PROJ_DIR)/arc.bin

upload-jlink: upload-x86-jlink upload-arc-jlink

upload-x86-jlink:
	cd $(CODK_FLASHPACK_DIR) && ./create_flasher.sh
	cd $(CODK_FLASHPACK_DIR) && ./flash_x86_jlink.sh

upload-arc-jlink:
	cd $(CODK_FLASHPACK_DIR) && ./flash_arc_jlink.sh $(ARC_PROJ_DIR)/arc.bin

upload-ble-dfu:
	cd $(CODK_FLASHPACK_DIR) && ./flash_ble_dfu.sh $(BLE_IMAGE)

clean: clean-x86 clean-arc

clean-x86:
	-rm -rf out pub flashpack.zip

clean-arc:
	CODK_DIR=$(CODK_DIR) $(MAKE) -C $(ARC_PROJ_DIR) clean-all

debug-server-jtag:
	$(CODK_FLASHPACK_DIR)/bin/openocd.l64 -f $(CODK_FLASHPACK_DIR)/scripts/interface/ftdi/flyswatter2.cfg -f $(CODK_FLASHPACK_DIR)/scripts/board/quark_se.cfg

debug-server-jlink:
	$(CODK_FLASHPACK_DIR)/bin/openocd.l64 -f $(CODK_FLASHPACK_DIR)/scripts/interface/ftdi/jlink.cfg -f $(CODK_FLASHPACK_DIR)/scripts/board/quark_se.cfg

debug-server: debug-server-jtag

debug-x86:
	gdb $(TOP_DIR)/out/current/firmware/quark.elf

debug-arc:
	$(CODK_ARC_DIR)/arc32/bin/arc-elf32-gdb $(ARC_PROJ_DIR)/arc.elf
