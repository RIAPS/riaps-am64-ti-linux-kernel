# RIAPS AM64 TI Linux RT Kernel Build Script

This repo is used to create the TI Linux RT Kernel for the AM64x boards and place the results into a Debian Bookworm package.

Acknowledgement: This was created based on the TI Debian repo scripts in https://github.com/TexasInstruments/debian-repos/tree/master.  Utilizing the `run.sh` and `ti-linux-kernel-rt` information.

## To build a kernel on the AM64

* Apt install `bc` and `rsync`

>Note: The main branch is based on the original TI repo, but does not work in cross architecture setup (using Ubuntu 22.04).  The other branch is experimenting with builds on Jenkins.