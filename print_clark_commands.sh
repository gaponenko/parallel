#!/bin/bash
#
# bash one-liners have to be put in scripts because MOFIA env is only available in csh.
#
while read fn ; do echo ~/bin/parallel/clark.sh ${1:?exe-file arg missing}  ${2:?config-file arg missing} $fn ; done
