# Curie Open Development Kit - A

For Intel Community Support, product questions, or help troubleshooting, visit
ICS: [https://communities.intel.com/community/tech/intel-curie](https://communities.intel.com/community/tech/intel-curie)

|

### Contents

  - x86: Arduino 101 Firmware
  - ARC: Arduino sketches or `*.cpp`

### Supported Platforms
 - Ubuntu 14.04 - 64 bit

### Installation
```
mkdir -p ~/CODK && cd $_
git clone https://github.com/01org/CODK-A.git
cd CODK-A
make clone
sudo make install-dep
make setup
export CODK_DIR=$(pwd)
```

### Compile
- x86: `make compile-x86`
- ARC: `make compile-arc`
- Both: `make compile`

### Upload

##### Using USB/DFU
- x86: `make upload-x86-dfu`
- ARC: `make upload-arc-dfu`
- Both: `make upload`

##### Using JTAG
- x86 and bootloader: `make upload-x86-jtag`
- ARC: `make upload-arc-jtag`
- Both and bootloader: `make upload-jtag`

##### Using JLINK
- x86 and bootloader: `make upload-x86-jlink`
- ARC: `make upload-arc-jlink`
- Both and bootloader: `make upload-jlink`

Default app prints the ASCII table over the serial port.
To see the output, connect at 9600 bps to the CDC ACM virtual serial port
the Arduino 101 shows up under, e.g. `/dev/ttyACM0`.

##### Uploading Arduino Sketch by USB Interface in Windows
If you can not see "Arduino 101 Serial Monitor" in Device Manager, you have to execute "Arduino IDE -> Tool -> flashing bootloader".

#### BLE Firmware
Curie ODK requires an updated BLE firmware. If you're on a factory version, please update.    
The script will prompt you to manually reset the board.
- BLE: `make upload-ble-dfu`

### Debug
Connect JTAG and open three terminal tabs

##### Tab 1: Debug Server
`make debug-server`

##### Tab 2: x86
`make debug-x86`    
`(gdb) target remote localhost:3334`

##### Tab 3: ARC
`make debug-arc`    
`(gdb) target remote localhost:3333`
