#!/bin/bash
#
# bash one-liners have to be put in scripts because MOFIA env is only available in csh.
#
while read fn ; do echo ~/bin/parallel/mofia.sh ${1:?kcm-file arg missing} $fn ; done
