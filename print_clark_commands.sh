#!/bin/bash
#
#
# 20151221: while read fn ; do echo ~/bin/parallel/clark.sh ${1:?exe-file arg missing}  ${2:?config-file arg missing} $fn ; done
# 20160816: while read fn ; do echo cd `pwd` \&\& ~/bin/parallel/clark.sh ${1:?exe-file arg missing}  ${2:?config-file arg missing} $fn ; done

print_clark_cmd() {
    echo cd `pwd` \&\& ~/bin/parallel/clark.sh "$@"
}

exe=${1:?exe-file arg missing}
conf=${2:?config-file arg missing}
chunksize=${3:?chunksize arg is missing}

inputs=()

while read fn ; do inputs=("${inputs[@]}" "$fn"); if [ ${#inputs[@]} -ge "$chunksize" ]; then print_clark_cmd "$exe" "$conf" "${inputs[@]}"; inputs=(); fi; done

if [ ${#inputs[@]} -gt 0 ]; then 
    print_clark_cmd "$exe" "$conf" "${inputs[@]}"; inputs=();
fi
