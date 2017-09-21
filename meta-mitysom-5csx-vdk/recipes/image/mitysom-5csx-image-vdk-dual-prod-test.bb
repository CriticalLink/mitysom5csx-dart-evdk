DESCRIPTION = "MitySOM-5CSX Vision Development Kit Image, Dual Cameras"

IMAGE_FEATURES += "debug-tweaks package-management ssh-server-openssh tools-sdk"
PACKAGE_CLASSES = "package_rpm "
IMAGE_INSTALL = "\
    packagegroup-core-boot \
    packagegroup-core-full-cmdline \
    ${CORE_IMAGE_EXTRA_INSTALL} \
        kernel\
        kernel-image\
        kernel-devicetree\
        kernel-modules\
        kernel-base\
        i2c-tools-misc\
        i2c-tools\
        packagegroup-core-eclipse-debug\
        mtd-utils\
        memtool\
        memtester\
        demo-app\
        demo-app-dev\
	libmitycambconadapter\
	vdk-dual-pcie-fpga\
	init-ifupdown\
	vdk-moduleconfig\
	busybox-udhcpd\
	libpng\
	jpeg\
	iperf\
	strace\
	gdbserver\
	tiffxx\
	gstreamer1.0\
	gstreamer1.0-plugins-base\
	gstreamer1.0-plugins-good\
	gstreamer1.0-plugins-bad\
	cairo\
	vdk-democode\
	test-drive\
	test-eth\
	test-gpio\
	e2fsprogs-tune2fs\
    "
inherit core-image distro_features_check

IMAGE_FSTYPES_append = " sdcard"

IMAGE_TYPEDEP_sdcard = "tar.gz"


IMAGE_CMD_sdcard() {
	cd ${DEPLOY_DIR_IMAGE}
	./make_sd.sh \
	-p preloader-mkpimage-dual-ssd.bin \
	-e ubootenv-dual-ssd.bin \
	-u u-boot-dual-ssd.img \
	-o sd_card_dual_ssd_prod_test.img \
	${IMAGE_NAME}.rootfs.tar.gz || die "Make SD CARD image script failed"
}
