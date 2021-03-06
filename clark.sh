#!/bin/bash
#
# Andrei Gaponenko, 2013

absname() {
    case $1 in
	/*) echo $1 ;;
	*) echo $(/bin/pwd)/$1 ;;
    esac
}

exe=${1:?Clark binary arg missing}
exe=$(absname $exe)
if [ ! -x $exe ]; then
    echo "Error: file $exe is not executable" >&2
    exit 1
fi
shift

cfg=${1:?CFG file arg missing}
cfg=$(absname $cfg)
if [ ! -r $cfg ]; then
    echo "Can't read command file $cfg" >&2
    exit 1
fi
shift

tree=${1:?Data file arg missing}
tree=$(absname $tree)
if [ ! -r $tree ]; then
    echo "Can't read data file $tree" >&2
    exit 1
fi
### no shift here - data files are now $@

bn=$(basename $tree .root)
bn=${bn##tree}

echo "CFG = $cfg"
echo "Data files = $@"
echo "bn = $bn"
if mkdir cr$bn && cd cr$bn; then
    /usr/bin/time ${exe} -l clark$bn.log -o clark$bn.root $cfg "$@" > job.log 2>&1
    ret=$?
    echo "Clark exit status: $ret" >> job.log
    exit $ret
else
    echo "ERROR assuming working directory cr$bn" >&2
    exit 1
fi

exit 1
