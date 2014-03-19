#!/bin/bash
#
# bash one-liners have to be put in scripts because GEANT env is only available in csh.
#
ffcard=${1:?ffcard arg missing}
firstrun=${2:?first run arg missing}
numruns=${3:?numruns arg missing}

i=-1; while [ $((i+=1)) -lt $numruns ]; do
    echo ~/bin/parallel/geant.sh "$ffcard" $((firstrun + i))
done
