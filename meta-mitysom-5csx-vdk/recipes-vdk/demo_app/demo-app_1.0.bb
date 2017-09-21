SUMMARY = "Baslcer BCON Demo Application"
DESCRIPTION = "Early demo app to be run in 5csx dev board"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "svn://svnsrv/svn/mityaltera/stereo_vision_carrier/trunk/sw;protocol=http;module=ARM;"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/ARM/demo_app"

# r1 - add logos
# r2 - add support files for stereo vision application
PR = "r1"
PR = "r2"

# ${PV} is pulled from the recipe filename, e.g. helloworld_2.7.bb -> ${PV} expands to "2.7".
# We use immediate evaluation to define a new var PVBASE holding the original value of ${PV}.
PVBASE := "${PV}"

# We need to tell bitbake about our current directory structure or we won't be able to find patches after we mess with ${PV}
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PVBASE}:"

# Then redefine PV to tack the svn rev onto the base version. This is evaluated at fetch time.
# Then the package will get rebuilt any time the relevant part of the source tree changes.
PV = "${PVBASE}.${SRCPV}"

inherit autotools

DEPENDS += "pylon libfpga"

RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}/home
    install -d ${D}/home/root
    install -m 0755 ${WORKDIR}/ARM/config/setup.sh ${D}/home/root
    install -m 0755 ${WORKDIR}/ARM/config/setup_dual.sh ${D}/home/root
    install -m 0755 ${WORKDIR}/ARM/config/daA2500-14bc.ini ${D}/home/root
    install -m 0755 ${WORKDIR}/ARM/config/da1280-54bm_cam1.ini ${D}/home/root
    install -m 0755 ${WORKDIR}/ARM/config/da1280-54bm_cam2.ini ${D}/home/root
    install -m 0644 ${WORKDIR}/ARM/config/basler_logo.raw ${D}/home/root
    install -m 0644 ${WORKDIR}/ARM/config/critical_link_logo.raw ${D}/home/root
}

FILES_${PN} += " \
	/home \
	/home/root \
	/home/root/setup.sh \
	/home/root/setup_dual.sh \
	/home/root/daA2500-14bc.ini \
	/home/root/da1280-54bm_cam1.ini \
	/home/root/da1280-54bm_cam2.ini \
	/home/root/basler_logo.raw \
	/home/roo/critical_link_logo.raw "
