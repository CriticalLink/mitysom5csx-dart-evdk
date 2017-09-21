#!/bin/bash

#
# This script is designed to take the qsys.tcl file exported from Qsys 16.0 for
# the complete Qsys system and modify it so we can reorder the add_instance
# commands so that the system displays in the Qsys GUI with the desired order.
#
# To create the qsys.tcl script, run qsys-edit version 16.0, open your existing
# Qsys system and choose File->"Export system as qsys script".
#
# Pass the name of the <qsys.tcl> file to be processed into this script, the
# name of the output file will be create_qsys_system_<qsys.tcl>.
#
#------------------------------------------------------------------------------

[ ${#} -eq 1 ] || {
	echo ""
	echo "USAGE: ${0} <qsys.tcl file>"
	echo ""
	exit 1
}

[ -f "${1:?}" ] || {
	echo "ERROR: Input file does not exists..."
	echo "'${1:?}'"
	realpath "${1:?}"
	exit 1
}

OUTPUT_FILE="create_vdk_qsys.tcl"

set -x

# look for some indications that this is a qsys.tcl file
grep "create_system" ${1:?} || { set +x; echo "ERROR"; exit 1; }
grep "save_system" ${1:?} || { set +x; echo "ERROR"; exit 1; }

cat "${1:?}" | \
sed -n -e "1,/add_instance/ p" | \
sed -e "/add_instance/ d" \
> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

cat << EOF >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

#
# Manually reorder this list of component instances to reflect the order that
# you wish to see them appear in the Qsys GUI.
#
#-------------------------------------------------------------------------------

EOF

cat "${1:?}" | \
sed -n -e "/add_instance/ p" >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

cat << EOF >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

#-------------------------------------------------------------------------------

EOF


cat "${1:?}" | \
sed -n -e "/add_instance/,/save_system/ p" | \
sed -e "/save_system/ d" |\
sed -e "s/add_instance/# add_instance/" | \
sed -e "/baseAddress/s/^/# /" >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

cat << EOF >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }
#-------------------------------------------------------------------------------

EOF
cat "${1:?}" | \
sed -n -e "/baseAddress/ p" |\
sed -e "s/# //" >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

cat << EOF >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

#-------------------------------------------------------------------------------

EOF

cat "${1:?}" | \
sed -n -e "/save_system/,$ p" >> ${OUTPUT_FILE:?} || { set +x; echo "ERROR"; exit 1; }

set +x

echo "Script completed successfully..."

exit 0

