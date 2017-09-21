#!/bin/bash

die()
{
       shift
       echo $(hostname): FATAL: "$*" >&2
       exit 1
}

QUARTUS_CPF=$(which quartus_cpf)
[ -n "$QUARTUS_CPF" ] || die "qurtus_cpf missing.. please source the intelFPGA embedded shell"

SOF_FILE=`find . -name *.sof`
echo "SOF: $SOF_FILE"
RBF_FILE=`echo $SOF_FILE | sed "s/\.sof/\.rbf/"`
echo "RBF: $RBF_FILE"
$QUARTUS_CPF -c $SOF_FILE $RBF_FILE
readlink -f ${RBF_FILE}
