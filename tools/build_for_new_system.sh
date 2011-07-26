#!/bin/sh

# Args:
# group (wine-group dir)
# package (package name)
# options (optionally)
build()
{
    local GROUP=$1
    local PACKAGE=$2
    local TARGET=$3
    local ARG=$4
    shift 4

    [ -n "$ARG" ] || ARG=-f

    echo
    # install needed packages
    ../bin-$GROUP/$PACKAGE.sh -i $SYSTEM $TARGET || exit
    # run build
    ../bin-$GROUP/$PACKAGE.sh $ARG $SYSTEM $TARGET $@
}

fatal()
{
    echo "$@" >&2
    exit 1
}

SYSTEM=$1
PART=$2
# Stop when error
export NIGHTBUILD=1

if [ -z "$PART" ] ; then
    ../bin-common/rpm-build-altlinux-compat.sh $SYSTEM -b || fatal
fi


build_wine()
{
######## WINE@Etersoft ############

#for BRANCH in 1.0.12 testing school school-testing unstable
build wine fonts-ttf-liberation stable
build wine fonts-ttf-ms stable

# build and install wine
build wine wine-etersoft stable -b || return
build wine wine-etersoft-all stable

#build wine wine-etersoft-cad

# build hasp without target
build hasp haspd stable
# TODO: only for dkms target
# build hasp dkms-aksparlnx

# build cifs without target
build cifs etercifs stable
# TODO: only for dkms target
#build cifs dkms-etercifs stable
}
if [ -z "$PART" ] || [ "$PART" = "wine" ] ; then
    build_wine
fi


build_rx()
{
######## RX@Etersoft ###########

build nx nx stable -b || return
build nx rx-etersoft stable
build nx nxclient stable
build nx nxsadmin stable
build nx opennx stable
}
if [ -z "$PART" ] || [ "$PART" = "rx" ] ; then
    build_rx
fi


build_pg()
{
########## Postgre@Etersoft ############

build postgres icu38 stable -b
build postgres postgre-etersoft9.0 stable
}
if [ -z "$PART" ] || [ "$PART" = "pg" ] ; then
    build_pg
fi