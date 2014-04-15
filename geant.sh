#!/bin/bash
#
# Andrei Gaponenko, 2013

absname() {
    case $1 in
	/*) echo $1 ;;
	*) echo $(/bin/pwd)/$1 ;;
    esac
}

FFCARD=${1:?FFCARD template file arg missing}
FFCARD=$(absname $FFCARD)
if [ ! -r $FFCARD ]; then
    echo "Can't read command file $ffcard" >&2
    exit 1
fi

run=${2:?Run number arg missing}
nevt=${3:?Num events missing}

export DIO_SPECTRUM=$CAL_DB/dio.00003

#========================================================
# For the Aluminium 2007 run period
export CHGEOM=$CAL_DB/dt_geo.00066
#========================================================
#
IsAsymGEOM=`grep -ic asym $CHGEOM`
#
# Check the Bfield is off or on
# 
bfld=`grep "^BFLD" $FFCARD | grep -v C |awk '{print $2}'`
#
if  [ $bfld -eq 0 ]; then
    echo "BField is set OFF..."
    if [ $IsAsymGEOM -gt 0 ]; then        # asymmetric cell
	export ISOMAP1=$CAL_DB/dc_str.00023
    else
	export ISOMAP1=$CAL_DB/dc_str.00018
    fi
    export ISOMAP2=$CAL_DB/pc_str.00005
    export ISOMAP3=$CAL_DB/tc_str.00008
else
    echo "BField is set ON..."
    if [ $IsAsymGEOM -gt 0 ]; then        # asymmetric cell
	export ISOMAP1=$CAL_DB/dc_str.00023
    else
	export ISOMAP1=$CAL_DB/dc_str.00018
    fi
    export ISOMAP2=$CAL_DB/pc_str.00001
    export ISOMAP3=$CAL_DB/tc_str.00009
fi
#
# The STR      is asymmetric or not
#
IsAsymSTR=`grep -ic version $ISOMAP1`
#
if [ $IsAsymGEOM -gt 0 ] && [ $IsAsymSTR -eq 0 ]; then
    echo " Geometry file do not match STR. Exiting"
    exit 1
fi
if [ $IsAsymGEOM -eq 0 ] && [ $IsAsymSTR -gt 0 ]; then
    echo " Geometry file do not match STR. Exiting"
    exit 1
fi
#
export TDCMAP1=$CAL_DB/fbc1_map.00044
export TDCMAP2=$CAL_DB/fbc2_map.00045
#========================================================
# For the Silver 2006 run period
#setenv CORRUVDC  $CAL_DB/dc_ppc.00024
#setenv CORRROTDC $CAL_DB/dc_prc.00011
#setenv CORRUVPC  $CAL_DB/pc_ppc.00004
#========================================================
# For the Aluminium 2007 run period
export CORRUVDC=$CAL_DB/dc_ppc.00025
export CORRROTDC=$CAL_DB/dc_prc.00013
export CORRUVPC=$CAL_DB/pc_ppc.00005
#========================================================
# For the Large Target 2007 run period
# setenv CORRUVDC  $CAL_DB/dc_ppc.00026
# setenv CORRROTDC $CAL_DB/dc_prc.00014
# setenv CORRUVPC  $CAL_DB/pc_ppc.00005
#========================================================
export CORRROTPC=$CAL_DB/pc_prc.00001
export CORRTEC=$CAL_DB/tc_rpc.00001
#
# setenv FIELDMAP $CAL_DB/field_map.0002
#
# Uncomment OPERAMAP below to activate the OPERA field map
#
#========================================================
# For the Silver 2006 run period
# setenv OPERAMAP $CAL_DB/bfld_map.00025
#========================================================
# For the Aluminium 2007 run period
export OPERAMAP=$CAL_DB/bfld_map.00026
#========================================================
# For the Large Target 2007 run period
# setenv OPERAMAP $CAL_DB/bfld_map.00027
#========================================================
#
# location of all output files
#
export E614GEANT=.
#
# DC efficiencies
#
# ignored  if CALC_DC_EFFS is false or omitted
# used     if CALC_DC_EFFS is true
# setenv CALC_DC_EFFS false
export DCEFF=$CAL_DB/dc_effs.dat
#
# PC efficiencies
#
# ignored  if CALC_PC_EFFS is false or omitted
# used     if CALC_PC_EFFS is true
# setenv CALC_PC_EFFS false
export PCEFF=$CAL_DB/pc_effs.dat
#
# TC efficiencies
#
# ignored  if CALC_TC_EFFS is false or omitted
# used     if CALC_TC_EFFS is true
# setenv CALC_TC_EFFS false
export TCEFF=$CAL_DB/tc_effs.dat
#
# Input ray file
#
# testbeam.dat is a REVMOC ray file
# real.out is a M13GEANT ray file
# setenv RAYFILE testbeam.dat
export RAYFILE=real.out
#
# Below is latest beam input file:
#
# Check for the first particle (MUON)
#
msor=`grep "^MSOR" $FFCARD | grep -v C |awk '{print $2}'`
#
if [ $msor -eq 4 ]; then
    export MU_BEAM=$CAL_DB/surface_tune_03.dat
elif [ $msor -eq 5 ]; then
    export MDC_X_VS_Y=/home/drgill/e614/experiment/analysis/run_mofia/entrance/data/run20558/old/xyMID_20558LC_tcap.dat
    export MDC_X_VS_DX=/home/drgill/e614/experiment/analysis/run_mofia/entrance/data/run20558/old/xdxMID_20558LC_tcap.dat
    export MDC_Y_VS_DY=/home/drgill/e614/experiment/analysis/run_mofia/entrance/data/run20558/old/ydyMID_20558LC_tcap.dat
elif [ $msor -eq 6 ]; then
# 2006 silver (s74)
#  setenv MTECXVSY $CAL_DB/msor6_production_s74_begin_set.dat
# 2007 aluminium (s84)
#    setenv MTECXVSY $CAL_DB/msor6_production_s84_begin_set.dat
# 2007 aluminium muminus from James (s81)
    export MTECXVSY=$CAL_DB/msor6_s81.dat
fi
#
# Check for the second particle (POSITRON)
#
msor=`grep "^MSOR" $FFCARD | grep -v C |awk '{print $3}'`
#
if [ $msor -eq 4 ]; then
    export E_BEAM=$CAL_DB/surface_tune_03.dat
elif [ $msor -eq 5 ]; then
    # These are from Anthony Hillairet's analysis of 2005 data,
    # using DCs for the positron profiles.
    export EDC_X_VS_Y=$CAL_DB/beame2004_msor6_YvsX_Ant4Mar2006.dat
    export EDC_X_VS_DX=$CAL_DB/beame2004_msor6_AXvsX_Ant4Mar2006.dat
    export EDC_Y_VS_DY=$CAL_DB/beame2004_msor6_AYvsY_Ant4Mar2006.dat
elif [ $msor -eq 6 ]; then
    export ETECXVSY=$CAL_DB/beame2006_msor6_Ant12Jan2009.dat
fi
#
#
#========================================================
echo "FFCARD = $FFCARD"
echo "Run number = $run"
bn="run$run"
echo "bn = $bn"
if mkdir $bn && cd $bn; then
    sed -e 's/^RUNG .*/RUNG '$run'/' -e 's/^TRIG .*/TRIG '$nevt'/' $FFCARD > thisjob.ffcards
    export FFCARD=thisjob.ffcards
    /usr/bin/time ${GEANT_BIN:?GEANT_BIN not set}/bat614 > run$run.log 2>&1
    ret=$?
    echo "GEANT exit status: $ret"
    exit $ret
fi

exit 1
