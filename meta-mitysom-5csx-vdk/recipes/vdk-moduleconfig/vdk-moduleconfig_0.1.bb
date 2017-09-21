DESCRIPTION = "MitySOM-5CSX VDK USB configuration"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e"

# Revision History
# r1 - baseline
PR = "r1"

SRC_URI = "file://modprobe.d/usbgadget.conf \
	file://modules-load.d/usbgadget.conf \
	file://COPYING "

SRCREV = "${AUTOREV}"

S = "${WORKDIR}"

FILES_${PN} += "${sysconfdir}/modprobe.d/usbgadget.conf\
		${sysconfdir}/modules-load.d/usbgadget.conf "

do_install() {
	install -d ${D}${sysconfdir}/modprobe.d/
	install -m 0755 ${WORKDIR}/modprobe.d/usbgadget.conf ${D}${sysconfdir}/modprobe.d
	install -d ${D}${sysconfdir}/modules-load.d/
	install -m 0755 ${WORKDIR}/modules-load.d/usbgadget.conf ${D}${sysconfdir}/modules-load.d
}
