# RIAPS AM64 TI Linux RT Kernel Build Script

This repo is used to create the TI Linux RT Kernel for the AM64x boards and place the results into a Debian Bookworm package.  The **ti-linux-kernel-rt/riaps.config** file indicates the kernel config flag changes desired.  Device tree changes are provided by patches in **ti-linux-kernel-rt/patches** folder.

There are two ways to create these packages: 
1) Building directly on a TI-AM64B Starter Kit hardware (see section below)
2) Utilize Jenkins build system to get cross built solution using dockers (see Jenkinfile)

The resultant packages will are "linux-headers-<kernel version>-k3-rt_<release version>_arm64.deb", "linux-image-<kernel version>-k3-rt_<release version>_arm64.deb", "linux-image-<kernel version>-k3-rt-dbg_<release version>_arm64.deb" and "linux-libc-dev_<release version>_arm64.deb".

The intent is to place these packages into an RIAPS AM64x kernel apt repository which will be utilized by the AM64x image creation repository (https://github.com/RIAPS/riaps-ti-bdebstrap).  The device tree patch (ti-linux-kernel-rt/patches/riaps-dts-bootargs-gpio.patch) here should be copied to the above repository under patches/ti-u-boot/riaps-dts-bootargs-gpio.patch.

Acknowledgement: This repository was created based on the TI Debian repo scripts in https://github.com/TexasInstruments/debian-repos/tree/master.  Utilizing the `run.sh` and `ti-linux-kernel-rt` information.

## To Build a Kernel on the AM64

* Apt install `bc` and `rsync`
* Indicate the Debian codename in `debian_version.sh`
* Build command: `./run.sh ti-linux-kernel-rt`

## To Create Device Tree Patches

* Clone the TI kernel: `git clone https://git.ti.com/git/ti-linux-kernel/ti-linux-kernel.git` 
* Checkout the branch that relates to the desired kernel.  This version number is found in the **ti-linux-kernel-rt/suite/bookworm/debian/changelog** file.  For example, the branch to checkout for the changelog entry of `ti-linux-kernel-rt (09.02.00.010-rt-1) bookworm; urgency=medium` is ***09.02.00.010-rt***.
* Modify the device tree file as desired.  File location: **arch/arm64/boot/dts/ti/k3-am642-sk.dts**
  >Note: In addition to the hardware interface updates, modify the "bootargs" line to be `bootargs = "console=ttyS2,115200n8 earlycon=ns16550a,mmio32,0x02800000 security=apparmor systemd.unified_cgroup_hierarchy=0";` 
* Create patch: move to top of the repository and run: `git diff > riaps-dts-bootargs-gpio.patch`
* Copy the patch file to this repository under **ti-linux-kernel-rt/patches** folder