# [WIP] USB 2.0 Device IP Core using Migen


#### Directory Structure:
```
.
├── doc
|
├── firmware
│   └── basic.c
|
├── gateware
│   ├── ip_repo
│   │   └── USB_Device_1.0
│   └── usb_ulpi.py
|
├── LICENSE
|
├── platform
│   └── zybo
│       └── zybo_usb3300.xdc
|
└── README.md

```

* `firmware/basic.c` : Basic C code which tests current capability of the IP Core
* `gateware/ip_repo/USB_Device_1.0` : Vivado packaged IP core
* `platform` : Platform specific stuff. Currently only features constraints for Zybo platform


#### How to use:
1. Run usb_ulpi.py after se...tting up Migen environment
2. Copy the generated code `usb_ulpi.v` to `gateware/ip_repo/USB_Device_1.0/src/usb_ulpi.v`. Overwrite the existing one.
3. Create Vivado project with the IP and provided constraints file.
4. [Sample Vivado Block Diagram][1]
5. After bitstream is generated, create Vivado SDK project with provided `basic.c` file. Run the program on `Zybo`.

[1]: doc/Sample_design_portrait.pdf
