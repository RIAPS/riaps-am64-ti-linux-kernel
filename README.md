# RIAPS AM64 TI Linux RT Kernel Build Script

This repo is used to create the TI Linux RT Kernel for the AM64x boards and place the results into a Debian Bookworm package.  

The resultant packages will are "linux-headers-<kernel version>-k3-rt_<release version>_arm64.deb", "linux-image-<kernel version>-k3-rt_<release version>_arm64.deb", "linux-image-<kernel version>-k3-rt-dbg_<release version>_arm64.deb" and "linux-libc-dev_<release version>_arm64.deb".

The intent is to place these packages into an RIAPS AM64x kernel apt repository which will be utilized by the AM64x image creation repository (https://github.com/RIAPS/riaps-ti-bdebstrap).  The device tree patch (ti-linux-kernel-rt/patches/riaps-dts-bootargs-gpio.patch) here should be copied to the above repository under patches/ti-u-boot/riaps-dts-bootargs-gpio.patch.

Acknowledgement: This repository was created based on the TI Debian repo scripts in https://github.com/TexasInstruments/debian-repos/tree/master.  Utilizing the `run.sh` and `ti-linux-kernel-rt` information.

## To build a kernel on the AM64

* Apt install `bc` and `rsync`

>Note: The main branch is based on the original TI repo and only build on the native processor (TI AM64x).  The `develop` branch is a cross-compilation setup that is a work in progress.  At this time the 'linux-libc-dev' package is not building correctly.  So it is suggested that for real kernel development, use the master branch and build the kernel natively on the TI AM64B board.  This will create the correct 'linux-libc-dev' package for the kernel build.