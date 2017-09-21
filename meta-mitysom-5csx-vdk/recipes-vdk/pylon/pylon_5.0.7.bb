SUMMARY = "Basler Pylon Camera Software Suite"
DESCRIPTION = "Library for abstracting access to cameras"
LICENSE = "CLOSED"
#TODO: is this licensing correct?

# This tells bitbake where to find the files we're providing on the local filesystem
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

PR = "r0"
BUILD_NUMBER = "9992"

# Use local tarball
#SRC_URI = "file://pylon-${PV}-armhf.tar.gz"
SRC_URI = "file://pylonSDK-${PV}.${BUILD_NUMBER}-armhf.tar.gz"

# Make sure our source directory (for the build) matches the directory structure in the tarball
#S = "${WORKDIR}/pylon-${PV}-armhf"
S = "${WORKDIR}/pylon5"

#TODO
# from https://wiki.yoctoproject.org/wiki/TipsAndTricks/Packaging_Prebuilt_Libraries

COMPATIBLE_HOST = "arm-poky-linux-gnueabi"

INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT  = "1"

LIBSBASE = "libpylon_TL_bcon \
	libpylonbase \
	libpylonutility \
	libuxapi \
	libpylon_TL_camemu \
	libpylon_TL_gige \
	libpylon_TL_gtc \
	libpylonc \
	libbxapi \
	libgxapi \
	"

do_install() {
	install -m 0755 -d ${D}${libdir}
	# this is necessary because oe_soinstall is looking for .so.X.Y.Z not .X.Y.Z.so
	for l in ${LIBSBASE}; do
		cp ${S}/lib/${l}-${PV}.so ${S}/lib/${l}.so.${PV}
		oe_soinstall ${S}/lib/${l}.so.${PV} ${D}${libdir}
	done
	for l in ${S}/lib/*v5_0.so; do
		cp ${l} ${l}.${PV}
		oe_soinstall ${l}.${PV} ${D}${libdir}
	done
	# stuff all the headers
	install -d ${D}${includedir}
	pushd ${S}/include
	find * -type d -exec install -d ${D}${includedir}/{} \;
	find * -type f -exec install -m 0755 {} ${D}${includedir}/{} \;
	popd
}

