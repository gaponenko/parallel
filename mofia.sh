#!/bin/bash
#
# Andrei Gaponenko, 2013

absname() {
    case $1 in
	/*) echo $1 ;;
	*) echo $(/bin/pwd)/$1 ;;
    esac
}

kcm=${1:?KCM file arg missing}
kcm=$(absname $kcm)
if [ ! -r $kcm ]; then
    echo "Can't read command file $kcm" >&2
    exit 1
fi

ybs=${2:?Data file arg missing}
ybs=$(absname $ybs)
if [ ! -r $ybs ]; then
    echo "Can't read data file $ybs" >&2
    exit 1
fi

bn=$(basename $ybs .ybs)
if mkdir $bn && cd $bn; then
    /usr/bin/time ${MOFIA_USER:?MOFIA_USER not set}/photo $kcm $ybs > job.log 2>&1 <<EOF
show name all
ana
exit
EOF
ret=$?
echo "MOFIA exit status: $ret"
exit $ret
fi

exit 1
