#!/bin/bash

export git_repo="https://git.ti.com/git/ti-linux-kernel/ti-linux-kernel.git"
export custom_build=true
export require_root=false
export release_tag="09.02.00.008-rt"
export package_name="linux-upstream"

export DEBFULLNAME="Sai Sree Kartheek Adivi"
export DEBEMAIL="s-adivi@ti.com"
export KDEB_CHANGELOG_DIST=bookworm

function setup_build_tools() {
    mkdir -p ${topdir}/tools/
    cd ${topdir}/tools/
    echo "> Downloading Aarch64 Toolchain .."
    wget https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz &>>/dev/null
    if [ $? -eq 0 ]; then
        echo "> Aarch64 Toolchain: downloaded .."
        tar -Jxf arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
        rm arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
        echo "> Aarch64 Toolchain: available"
        export AARCH64_TOOL_LOC="$PWD/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu/bin"
        echo "$AARCH64_TOOL_LOC"
    else
        echo "> Aarch Toolchain: Failed to download. Exit code: $?"
    fi
}

function run_custom_build() {
    setup_build_tools
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