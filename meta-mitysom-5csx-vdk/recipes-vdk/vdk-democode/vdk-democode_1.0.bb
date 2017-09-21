SUMMARY = "Basler BCON Demo Software Package"
DESCRIPTION = "Software to install on local target to allow building in MitySOM-5CSX"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "svn://svnsrv/svn/mityaltera/stereo_vision_carrier/trunk/sw;protocol=http;module=ARM;name=demo_app; \
	svn://svnsrv/svn/mityaltera/mityarm-5csx/tags/basler_vdk/sw/ARM;protocol=http;module=libfpga;name=libfpga; \
	svn://svnsrv/svn/camera/soc_camera/trunk/sw/ARM;protocol=http;module=bconadapter;name=bconadapter; "

SRCREV_FORMAT = "demo_app"
SRCREV_demo_app = "${AUTOREV}"
SRCREV_libfpga = "${AUTOREV}"
SRCREV_bconadapter = "${AUTOREV}"

# r1 - use latest demo_app SVN version number as part of PV
PR = "r1"

# ${PV} is pulled from the recipe filename, e.g. helloworld_2.7.bb -> ${PV} expands to "2.7".
# We use immediate evaluation to define a new var PVBASE holding the original value of ${PV}.
PVBASE := "${PV}"

# Then redefine PV to tack the svn rev onto the base version. This is evaluated at fetch time.
# Then the package will get rebuilt any time the relevant part of the source tree changes.
PV = "${PVBASE}.${SRCPV}"

do_install() {
	install -m 0755 -d ${D}/home
	install -m 0755 -d ${D}/home/root
	install -m 0755 -d ${D}/home/root/sw

	# demo application
	install -m 0755 -d ${D}/home/root/sw/demo_app
	install -m 0755 -d ${D}/home/root/sw/demo_app/src
	pushd ${WORKDIR}/ARM/demo_app/src
	find * -type f -exec install -m 0755 {} ${D}/home/root/sw/demo_app/src/{} \;
	cd ..
	find * -type f -exec install -m 0755 {} ${D}/home/root/sw/demo_app/{} \;
	popd

	# libfpga
	install -m 0755 -d ${D}/home/root/sw/libfpga
	install -m 0755 -d ${D}/home/root/sw/libfpga/altera_vip
	pushd ${WORKDIR}/libfpga/altera_vip
	find * -type f -exec install -m 0755 {} ${D}/home/root/sw/libfpga/altera_vip/{} \;
	cd ..
	find * -type f -exec install -m 0755 {} ${D}/home/root/sw/libfpga/{} \;
	popd

	# bconadapter
	install -m 0755 -d ${D}/home/root/sw/bconadapter
	pushd ${WORKDIR}/bconadapter
	find * -type f -exec install -m 0755 {} ${D}/home/root/sw/bconadapter/{} \;
	popd
}

FILES_${PN} = "/home \
	/home/root \
	/home/root/sw \
	/home/root/sw/demo_app \
	/home/root/sw/demo_app/src \
	/home/root/sw/demo_app/* \
	/home/root/sw/demo_app/src/* \
	/home/root/sw/libfpga \
	/home/root/sw/libfpga/altera_vip \
	/home/root/sw/libfpga/* \
	/home/root/sw/libfpga/altera_vip/* \
	/home/root/sw/libfpga/bconadapter \
	/home/root/sw/libfpga/bconadapter/* \
	"
