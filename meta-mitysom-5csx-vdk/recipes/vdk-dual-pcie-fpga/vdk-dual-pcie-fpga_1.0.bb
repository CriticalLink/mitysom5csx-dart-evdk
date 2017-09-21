DESCRIPTION = "MitySOM-5CSX Embedded VDK Dual Camera FPGA"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${S}/COPYING;md5=8822a951fb1863b8809d01d1faa2511b"

# Revision History
# r1 - baseline
# r2 - add boot environment, move RBF to /boot
# r3 - only extract key sources
PR = "r3"

SRC_URI = "svn://svnsrv/svn/mityaltera/stereo_vision_carrier/trunk/hw/fpga;protocol=http;module=vdk_dual_ssd;name=vdk_dual_ssd; \
           svn://svnsrv/svn/mityaltera/stereo_vision_carrier/trunk;protocol=http;module=build;name=build;"
SRCREV_vdk_dual_ssd = "${AUTOREV}"
SRCREV_build = "${AUTOREV}"
SRCREV_FORMAT = "vdk_dual_ssd_build"

S = "${WORKDIR}/vdk_dual_ssd"

# ${PV} is pulled from the recipe filename, e.g. helloworld_2.7.bb -> ${PV} expands to "2.7".
# We use immediate evaluation to define a new var PVBASE holding the original value of ${PV}.
PVBASE := "${PV}"

# We need to tell bitbake about our current directory structure or we won't be able to find patches after we mess with ${PV}
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PVBASE}:"

# Then redefine PV to tack the svn rev onto the base version. This is evaluated at fetch time.
# Then the package will get rebuilt any time the relevant part of the source tree changes.
PV = "${PVBASE}.${SRCPV}"

# override QUARTUS_DIR in your local.conf file if necessary
QUARTUS_DIR ?= "/opt/intelFPGA/17.0"
export SOCEDS_DEST_ROOT = "${QUARTUS_DIR}/embedded"
export QSYS_NAME = "vdk_dual_ssd"
export DEVICE_TYPE = "5CSXFC6C6U23C7"
export PROJECT_NAME = "vdk_dual_ssd"
export LM_LICENSE_FILE = "27000@10.0.0.23"

inherit fpga-cvsoc

FILES_${PN} += "/boot \
	/boot/vdk_dual_ssd.rbf \
	"

do_compile_append() {
	${S}/software/spl_bsp/uboot-socfpga/tools/mkenvimage -s 4096 -o ${S}/ubootenv_dual_ssd.bin ${WORKDIR}/build/ubootenv_dual_ssd.txt
}

do_install_append() {
	install -d ${D}/boot
	install -m 755 ${S}/output_files/vdk_dual_ssd.rbf ${D}/boot
}

# override do_deploy to use dual in names...
do_deploy() {
	echo CALLING DO_DEPLOY
	echo DEPLOYDIR = ${DEPLOYDIR}
	install -d ${DEPLOYDIR}
	install -m 0755 software/spl_bsp/preloader-mkpimage.bin ${DEPLOYDIR}/preloader-mkpimage-dual-ssd-${PV}.bin
	install -m 0755 software/spl_bsp/uboot-socfpga/u-boot.img ${DEPLOYDIR}/u-boot-dual-ssd-${PV}.img
	rm -f ${DEPLOYDIR}/preloader-mkpimage-dual-ssd.bin
	ln -sf ./preloader-mkpimage-dual-ssd-${PV}.bin ${DEPLOYDIR}/preloader-mkpimage-dual-ssd.bin
	rm -f ${DEPLOYDIR}/u-boot-dual-ssd.img
	ln -sf ./u-boot-dual-ssd-${PV}.img ${DEPLOYDIR}/u-boot-dual-ssd.img
	install -m 0755 ${S}/ubootenv_dual_ssd.bin ${DEPLOYDIR}/ubootenv-dual-ssd-${PV}.bin
	ln -sf ./ubootenv-dual-ssd-${PV}.bin ${DEPLOYDIR}/ubootenv-dual-ssd.bin
	install -m 0755 ${WORKDIR}/build/make_sd.sh ${DEPLOYDIR}
}
