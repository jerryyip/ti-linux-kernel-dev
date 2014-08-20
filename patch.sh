#!/bin/sh
#
# Copyright (c) 2009-2014 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Split out, so build_kernel.sh and build_deb.sh can share..

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi

git="git am"
git_patchset="git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git"
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="git apply"
fi

echo "Starting patch.sh"

git_add () {
	git add .
	git commit -a -m 'testing patchset'
}

start_cleanup () {
	git="git am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		git format-patch -${number} -o ${DIR}/patches/
	fi
	exit
}

external_git () {
	git_tag="ti-linux-3.14.y"
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
#local_patch

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtsi_append () {
	wfile="arch/arm/boot/dts/${base_dts}-${cape}.dts"
	cp arch/arm/boot/dts/${base_dts}.dts ${wfile}
	echo "" >> ${wfile}
	echo "#include \"am335x-bone-${cape}.dtsi\"" >> ${wfile}
	git add ${wfile}
}

dtsi_drop_nxp_hdmi () {
	sed -i -e 's:#include "am335x-boneblack-nxp-hdmi.dtsi":/* #include "am335x-boneblack-nxp-hdmi.dtsi" */:g' ${wfile}
	git add ${wfile}
}

dtsi_drop_emmc () {
	sed -i -e 's:#include "am335x-boneblack-emmc.dtsi":/* #include "am335x-boneblack-emmc.dtsi" */:g' ${wfile}
	git add ${wfile}
}

beaglebone () {
	echo "dir: beaglebone/pinmux"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
	# cp arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# gedit arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi &
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-bone.dts &
	# git add arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# git commit -a -m 'am335x-bone-common: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0001-am335x-bone-common-split-out-am33xx_pinmux.patch"

	# meld arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi arch/arm/boot/dts/am335x-boneblack.dts
	# git commit -a -m 'am335x-boneblack: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0002-am335x-boneblack-split-out-am33xx_pinmux.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# git commit -a -m 'am335x-boneblack: split out emmc' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0003-am335x-boneblack-split-out-emmc.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-nxp-hdmi.dtsi
	# git commit -a -m 'am335x-boneblack: split out nxp hdmi' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0004-am335x-boneblack-split-out-nxp-hdmi.patch"

	${git} "${DIR}/patches/beaglebone/pinmux/0005-am335x-bone-common-pinmux-i2c2.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0006-am335x-bone-common-pinmux-uart.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0007-am335x-bone-common-pinmux-spi0-spidev.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0008-am335x-bone-common-pinmux-mcasp0.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0009-am335x-bone-common-pinmux-lcd.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0010-am335x-bone-common-pinmux-tscadc-4-wire.patch"
	if [ "x${regenerate}" = "xenable" ] ; then
		number=10
		cleanup
	fi

	echo "dir: beaglebone/dts"
	#${git} "${DIR}/patches/beaglebone/dts/0001-am335x-boneblack-add-cpu0-opp-points.patch"

	echo "dir: beaglebone/capes"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="ttyO1"
		dtsi_append

		cape="ttyO2"
		dtsi_append

		cape="ttyO4"
		dtsi_append

		cape="ttyO5"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="ttyO1"
		dtsi_append

		cape="ttyO2"
		dtsi_append

		cape="ttyO4"
		dtsi_append

		cape="ttyO5"
		dtsi_append
		dtsi_drop_nxp_hdmi

		git commit -a -m 'auto generated: cape: uarts' -s
		git format-patch -1 -o ../patches/beaglebone/capes/
	else
		${git} "${DIR}/patches/beaglebone/capes/0001-auto-generated-cape-uarts.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="audio"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="audio"
		dtsi_append

		git commit -a -m 'auto generated: cape: audio' -s
		git format-patch -2 -o ../patches/beaglebone/capes/
	else
		${git} "${DIR}/patches/beaglebone/capes/0002-auto-generated-cape-audio.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="lcd3-01-00a2"
		dtsi_append

		cape="lcd4-01-00a0"
		dtsi_append
		cape="lcd4-01-00a1"
		dtsi_append

		cape="lcd7-01-00a2"
		dtsi_append
		cape="lcd7-01-00a3"
		dtsi_append
		cape="lcd7-01-00a4"
		dtsi_append

		base_dts="am335x-boneblack"
		#lcd3 a2+
		cape="lcd3-01-00a2"
		dtsi_append
		dtsi_drop_nxp_hdmi

		#lcd4 a1+
		cape="lcd4-01-00a1"
		dtsi_append
		dtsi_drop_nxp_hdmi

		#drop emmc:
		cape="lcd7-01-00a2"
		dtsi_append
		dtsi_drop_nxp_hdmi
		dtsi_drop_emmc

		#lcd4 a3+
		cape="lcd7-01-00a3"
		dtsi_append
		dtsi_drop_nxp_hdmi
		cape="lcd7-01-00a4"
		dtsi_append
		dtsi_drop_nxp_hdmi

		git commit -a -m 'auto generated: cape: lcd' -s
		git format-patch -3 -o ../patches/beaglebone/capes/
	else
		${git} "${DIR}/patches/beaglebone/capes/0003-auto-generated-cape-lcd.patch"
	fi

	#last...
	if [ "x${regenerate}" = "xenable" ] ; then
		device="am335x-bone-audio.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd3-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd4-01-00a0.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd4-01-00a1.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd7-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd7-01-00a3.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd7-01-00a4.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO1.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO2.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO4.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO5.dtb"
		dtb_makefile_append

		device="am335x-boneblack-audio.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd3-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd4-01-00a1.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd7-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd7-01-00a3.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd7-01-00a4.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO1.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO2.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO4.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO5.dtb"
		dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/dtb_makefile/
		exit
	else
		echo "dir: beaglebone/dtb_makefile"
		${git} "${DIR}/patches/beaglebone/dtb_makefile/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi

	#must be last..
	${git} "${DIR}/patches/beaglebone/capes/000x-cape-basic-proto-cape.patch"

#	echo "dir: beaglebone/mac"
#	${git} "${DIR}/patches/beaglebone/mac/0001-DT-doc-net-cpsw-mac-address-is-optional.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0002-net-cpsw-Add-missing-return-value.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0003-net-cpsw-header-Add-missing-include.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0004-net-cpsw-Replace-pr_err-by-dev_err.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0005-net-cpsw-Add-am33xx-MACID-readout.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0006-am33xx-define-syscon-control-module-device-node.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0007-arm-dts-am33xx-Add-syscon-phandle-to-cpsw-node.patch"
}

backport () {
	echo "dir: backport"
	${git} "${DIR}/patches/backport/0001-backport-gpio_backlight.c-from-v3.15.10.patch"
}

firmware () {
	echo "dir: firmware"
	#git clone git://git.ti.com/ti-cm3-pm-firmware/amx3-cm3.git
	#git checkout origin/next -b next

	#commit fb0117edd5810a8d3bd9b1cd8abe34e12ff2d0ba
	#Author: Dave Gerlach <d-gerlach@ti.com>
	#Date:   Tue Aug 5 11:44:20 2014 -0500
	#
	#    CM3: Bump firmware release version to 0x187
	#
	#    This version, 0x187, adds support for the following:
	#     - Further optimized IO DDR config on AM43xx platforms
	#     - Remoteproc resource table for use with the linux kernel
	#     - Standby support for am335x and am437x without any need for kernel
	#       clockdomain control.
	#
	#    Implementations not using the resource table will not be affected by
	#    this, but all future implementations within the linux kernel will use
	#    remoteproc and require this firmware or higher.

	#cp ../../amx3-cm3/bin/am335x-pm-firmware.elf ./firmware/
	#git add -f ./firmware/am335x-pm-firmware.elf

	${git} "${DIR}/patches/firmware/0001-firmware-am335x-pm-firmware.elf.patch"
}

###
beaglebone
backport
firmware

packaging_setup () {
	cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
	git commit -a -m 'packaging: sync with mainline' -s

	git format-patch -1 -o "${DIR}/patches/packaging"
}

packaging () {
	echo "dir: packaging"
	${git} "${DIR}/patches/packaging/0001-packaging-sync-with-mainline.patch"
	${git} "${DIR}/patches/packaging/0002-deb-pkg-install-dtbs-in-linux-image-package.patch"
	${git} "${DIR}/patches/packaging/0003-deb-pkg-no-dtbs_install.patch"
}

#packaging_setup
packaging
echo "patch.sh ran successful"
