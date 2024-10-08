#!/bin/bash

set -e

if [ "$#" -eq 0 ]; then
    echo "run.sh: missing operands"
    echo "Requires source package name as argument"
    exit 1
fi

source debian_version.sh
DEB_SUITE="${DEB_SUITE:-$deb_suite}"

topdir=$(git rev-parse --show-toplevel)
projdir="${topdir}/$1"
sourcedir="${topdir}/build/sources"
builddir="${topdir}/build/${DEB_SUITE}/$1"
debcontroldir="${projdir}/suite/${DEB_SUITE}"

if [ ! -d ${projdir} ]; then
    echo "This project does not exist."
    echo "Exiting."
    exit 1
fi

source ${projdir}/version.sh

mkdir -p ${builddir}

package_name=$(cd ${debcontroldir} && dpkg-parsechangelog --show-field Source)
deb_version=$(cd ${debcontroldir} && dpkg-parsechangelog --show-field Version)
package_version=$(echo $deb_version | sed 's/\(.*\)-.*/\1/')
last_tested_commit=$(echo $package_version | sed 's/.*+//')
package_full="${package_name}-${package_version}"
package_full_ll="${package_name}_${package_version}"
echo "Building " $package_name " version " $deb_version

# MM - for debugging
echo "Package_full_ll: " $package_full_ll
echo "Build dir: " $builddir
echo "Source dir: " $sourcedir
echo "Debcontroldir: " $debcontroldir
echo "Package name: " $package_name
echo "Deb Version: " $deb_version
echo "Package Version: " $package_version
echo "Last tested commit: " $last_tested_commit

# Generate original source tarball if none found
if [ ! -f "${builddir}/${package_full_ll}.orig.tar.gz" ]; then
    mkdir -p "${sourcedir}"
    if [ ! -d "${sourcedir}/${package_name}" ]; then
        git clone "${git_repo}" "${sourcedir}/${package_name}"
    fi
    git -C "${sourcedir}/${package_name}" remote update
    git -C "${sourcedir}/${package_name}" checkout "${last_tested_commit}"
    echo ">> Kernel source now available"

    # RIAPS: Apply patches and configurations
    # Apply patches, reset the repo first in case a previous patch was applied
    if [ -d ${topdir}/ti-linux-kernel-rt/patches ]; then
        echo ">> ${package_name}: patching .."
        git -C "${sourcedir}/${package_name}" apply ${topdir}/ti-linux-kernel-rt/patches/*
        echo ">> ti-linux-kernel-rt patches applied"
    fi

    echo ">> copy RIAPS configurations to kernel/configs .."
    cp ${topdir}/ti-linux-kernel-rt/riaps.config ${sourcedir}/${package_name}/kernel/configs/riaps.config

    echo ">> Tar downloaded kernel source code .."
    tar -czf "${builddir}/${package_full_ll}.orig.tar.gz" \
      --exclude-vcs \
      --absolute-names "${sourcedir}/${package_name}" \
      --transform "s,${sourcedir}/${package_name},${package_full},"
fi

# Generate source package if none found
if [ ! -f "${builddir}/${package_name}_${deb_version}.dsc" ]; then
    # Extract original source tarball
    echo ">> Untar downloaded kernel source code into build directory .."
    tar -xzmf "${builddir}/${package_full_ll}.orig.tar.gz" -C "${builddir}"

    # Deploy our Debian control files
    cp -rv "${debcontroldir}/debian" "${builddir}/${package_full}/"

    # Build source package
    echo ">> Build source package .."
    (cd "${builddir}/${package_full}" && dpkg-source -b .)

    # Cleanup intermediate source directory
    rm -r "${builddir}/${package_full}"
fi

# Generate binary package for this arch if not found
build_arch=$(dpkg --print-architecture)
if [ ! -f "${builddir}/${package_name}_${deb_version}_${build_arch}.buildinfo" ]; then
    run_prep || true

    # Extract source package
    if [ ! -d "${builddir}/${package_name}_${deb_version}" ]; then
        echo ">> Extract source package .."
        dpkg-source -x "${builddir}/${package_name}_${deb_version}.dsc" "${builddir}/${package_name}_${deb_version}"
    fi

    # Install build dependencies
    echo ">> Install build dependencies .."
    (cd "${builddir}/${package_name}_${deb_version}" && mk-build-deps -ir -t "apt-get -o Debug::pkgProblemResolver=yes -y --no-install-recommends")

    # Build debian package.
    # HACK: There is an issue with building source package for Linux Kernel. So only build binary packages for Linux.
    if [[ "${package_name}" == "ti-linux-kernel"* ]]; then
        (cd "${builddir}/${package_name}_${deb_version}" && debuild --no-lintian --no-sign -b || true)
    else
        (cd "${builddir}/${package_name}_${deb_version}" && debuild --no-lintian --no-sign -sa || true)
    fi

    # Cleanup intermediate build directory
    #MM: keep files while debugging
    #rm -r "${builddir}/${package_name}_${deb_version}"
    echo "Reset ${sourcedir}/${package_name} repository ..."
    git -C "${sourcedir}/${package_name}" checkout arch/arm64/boot/dts/ti/k3-am642-*.dts
fi