FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://gpio.csv"

do_install_append() {
    install -d ${D}/home
    install -d ${D}/home/root
    install -m 0755 ${WORKDIR}/gpio.csv ${D}/home/root
}

FILES_${PN} += " \
	/home \
	/home/root \
	/home/root/gpio.csv \
	"
