#!/bin/bash

export git_repo="https://git.ti.com/git/ti-linux-kernel/ti-linux-kernel.git"


#export release_tag="09.02.00.010-rt-1"
#export package_name="linux-upstream"



function run_custom_build() {
    cd "${builddir}"
    # Clone ti-linux-kernel
    if [ ! -d ${package_name} ]; then
        git clone "${git_repo}" -b "${release_tag}" --single-branch --depth=1 ${package_name}
    fi

    # Apply patches, reset the repo first in case a previous patch was applied
    if [ -d ${topdir}/ti-linux-kernel-rt/patches/ti-linux-kernel ]; then
        echo ">> ti-linux-kernel (${package_name}): patching .."
        cd "${builddir}/${package_name}" 
        git checkout .
        git apply ${topdir}/ti-linux-kernel-rt/patches/ti-linux-kernel/*
        cd "${builddir}"
        echo ">> ti-linux-kernel patches applied"
    fi

    cd ${package_name}
    echo ">> copy RIAPS configurations to kernel/configs .."
    cp ${topdir}/ti-linux-kernel-rt/riaps.config kernel/configs/riaps.config

    echo ">> compiling kernel .."
    make ARCH=arm64 CROSS_COMPILE="$AARCH64_TOOL_LOC/aarch64-none-linux-gnu-" -j2 defconfig ti_arm64_prune.config ti_rt.config riaps.config
    make ARCH=arm64 CROSS_COMPILE="$AARCH64_TOOL_LOC/aarch64-none-linux-gnu-" -j2 bindeb-pkg LOCALVERSION=-k3-rt
}