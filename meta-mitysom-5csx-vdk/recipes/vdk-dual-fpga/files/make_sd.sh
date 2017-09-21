#!/bin/bash 
apppath=$(readlink -f $0)
appdir=$(dirname ${apppath})
app=$(basename $apppath)

#
# function die
# print an error message and exit with status
# args 1- are the message to print
die()
{
       shift
       echo $(hostname): FATAL: "$*" >&2
       exit 1
}
usage()
{
	echo Usage:
	echo "$app [-s|--size <size>] [-o|--outfile <outfile>] [-g] <root.tar.gz>"
	echo "    SD card size(MB) specs how big the SD card image is [default $SD_CARD_SIZE]"
	echo "    outfile is the name of the filesystem image file [default is $IMAGE_FILE]"
	echo "    -v sets verbose flag in shell"
	echo "    -g will result in the output file being compressed with gzip"
	echo "    <root.tar.gz> is the yocto filesystem tarball to use"
}

IMAGE_FILE=sd_card.img
UBOOT_IMG=u-boot.img
PRELOADER=preloader-mkpimage.bin
UBOOTENV=ubootenv.bin
SD_CARD_SIZE_MB=2048
GZIP=N

guestfish=$(which guestfish)
[ -n "$guestfish" ] || die guestfish missing.. run sudo apt-get install libguestfs-tools

# Note that we use `"$@"' to let each command-line parameter expand to a 
# separate word. The quotes around `$@' are essential!
# We need TEMP as the `eval set --' would nuke the return value of getopt.
TEMP=`getopt -o o:s:p:e:u:ghv --long outfile:,size:,preloader:,environment:,uboot:,gzip,help,verbose\
     -n $app -- "$@"`

[ $? != 0 ] && die 2 "Terminating... getopt failed"
eval set -- "$TEMP"
while true ; do
        case "$1" in
        -o|--outfile) IMAGE_FILE="$2"; shift 2;;
        -s|--size) SD_CARD_SIZE_MB="$2"; shift 2;;
        -g|--gzip) GZIP=Y; shift ;;
        -k|--keep) keepfiles=Y; shift ;;
        -v|--verbose) set -v; shift ;;
        -h|--help) usage ; exit 0; shift;;
	-p|--preloader) PRELOADER="$2"; shift 2;;
	-e|--environment) UBOOTENV="$2"; shift 2;;
	-u|--uboot) UBOOT_IMG="$2"; shift 2;;
        --) shift ; break ;;
        *) die 2 "Internal error!: $*" ; shift;;
        esac
done

if [ "$#" -lt 1 ] ; then
	usage
	exit 1
fi
ROOT_BALL=$(readlink -f $1)
[ -f $ROOT_BALL ] || die Filesystem image \"$ROOT_BALL\" does not exist
[ -f $UBOOT_IMG ] || die u-Boot image \"$UBOOT_IMG\" does not exist
[ -f $PRELOADER ] || die Preloader image \"$PRELOADER\" does not exist
[ -f $UBOOTENV ] || die u-Boot env image \"$UBOOTENV\" does not exist


# Create a blank image 
dd if=/dev/zero of=$IMAGE_FILE bs=1M count=$SD_CARD_SIZE_MB || die unable to create SD image file

sfdisk_version=$(sfdisk --version|awk '{print $NF}')
echo sfdisk version $sfdisk_version

if [[ $sfdisk_version == 2.20* ]]
then
SD_LAYOUT=$'unit: sectors

/dev/sdc1 : start=        2048, size=2048, 	Id=a2
/dev/sdc2 : start=        8192,		Id=83'
else
SD_LAYOUT=$'unit: sectors

/dev/sdc1 : start=        2048, size=2048, type=a2
/dev/sdc2 : start=        8192, type=83'
fi

# Create partition table (2 partitions, one for uboot/preloader and second for linux
echo "$SD_LAYOUT" | sfdisk --force $IMAGE_FILE || die error creating partition table

guestfish -a ${IMAGE_FILE} << EOF
	run
	mke2fs /dev/sda2 fstype:ext3
	mount /dev/sda2 /
	tar-in  ${ROOT_BALL} / compress:gzip
	upload ./${PRELOADER} /boot/${PRELOADER}
	upload ./${UBOOT_IMG} /boot/${UBOOT_IMG}
	upload ./${UBOOTENV} /boot/${UBOOTENV}
	copy-file-to-device /boot/${PRELOADER} /dev/sda1
	copy-file-to-device /boot/${UBOOT_IMG} /dev/sda1 destoffset:256k
	copy-file-to-device /boot/${UBOOTENV} /dev/sda destoffset:512
	umount /
	sync
EOF

if [ "Y" == "$GZIP" ] ; then
	echo compressing ${IMAGE_FILE}
	gzip -f ${IMAGE_FILE}
fi

exit 0
