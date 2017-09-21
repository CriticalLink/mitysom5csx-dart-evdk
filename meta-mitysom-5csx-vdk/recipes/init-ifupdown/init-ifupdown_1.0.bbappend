FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI += "file://udhcpd.conf \
	file://if-up.d/start_udhcpd \
	file://if-down.d/stop_udhcpd "

do_install_append() {
	install -d ${D}${sysconfdir}/
	install -m 644 ${WORKDIR}/udhcpd.conf ${D}${sysconfdir}
	install -d ${D}${sysconfdir}/network
	install -d ${D}${sysconfdir}/network/if-up.d
	install -m 644 ${WORKDIR}/if-up.d/start_udhcpd ${D}${sysconfdir}/network/if-up.d
	install -d ${D}${sysconfdir}/network/if-down.d
	install -m 644 ${WORKDIR}/if-down.d/stop_udhcpd ${D}${sysconfdir}/network/if-down.d
}
