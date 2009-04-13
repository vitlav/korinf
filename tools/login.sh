#!/bin/sh
##
#  Korinf project
#
#  Login in chroot script
#
#  Copyright (c) Etersoft <http://etersoft.ru> 2005, 2006, 2007, 2009
#  Copyright (c) Vitaly Lipatov <lav@etersoft.ru> 2009
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.

#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

# load common functions, compatible with local and installed script
. `dirname $0`/../share/eterbuild/korinf/common

SUDO="sudo"
if [ $UID = "0" ]; then
	SUDO=""
fi

if [ -z "$1" ] ; then
	echo "Login in build chroot." >&2
	echo "Use --help for usage information" >&2
	exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
	echo "Login in chrooted system as builder user"
	echo "	-r - login as root"
	echo "	-n - login via network (unsupported now)"
	exit 0
fi

[ "$1" = "-n" ] && { shift ; NETBUILD=1 ; } || NETBUILD=

SYS="$1"
shift

USERCO="su -"
[ "$1" = "-r" ] && shift || USERCO="su - $INTUSER"
# TODO:
[ -n "$1" ] && COMMANDTO="-c '$@\'"

#echo "Enter YOUR password below!"
export TMPDIR=/tmp
#TMP=~/tmp
#TESTDIR=/tmp/testlog-$USER
#mkdir -p $TESTDIR/
TESTDIR=`mktemp -d /tmp/autobuild/chroot-$USER-XXXXXX`

if [ -n "$NETBUILD" ] ; then
	echo Mount $SYS by network ...
	$SUDO mount borroman:/mnt/$SYS $TESTDIR -o soft || exit 1
else
	echo Mount $SYS from local...
	$SUDO mount $LOCALLINUXFARM/$SYS $TESTDIR --bind || exit 1
fi
$SUDO mkdir -p $TESTDIR/{srv/wine,proc,home/$INTUSER,dev/pts}

echo Mount local home...
BUILDERHOME=$TESTDIR/home/$INTUSER
$SUDO mount /srv/builder-login $BUILDERHOME --bind #|| exit 1
init_home
echo Mount swine...
#$SUDO mount /usr/local/ $TESTDIR/usr/local --bind
#$SUDO mount /net/wine/ $TESTDIR/srv/wine --bind

BUILDARCH=$DEFAULTARCH
if echo $SYS | grep x86_64 >/dev/null ; then
    BUILDARCH="x86_64"
fi
echo "Chrooting in $SYS system with $BUILDARCH arch"

export HOSTNAME=$SYS
export PS1="[\u@$SYS \W]\$"
#[\u@\h \W]\$
$SUDO chroot $TESTDIR su -c "mount -t proc none /proc"
$SUDO chroot $TESTDIR su -c "mount -t devpts none /dev/pts"
setarch $BUILDARCH $SUDO chroot $TESTDIR $USERCO $COMMANDTO
$SUDO umount $TESTDIR/home/$INTUSER && echo "Unmount home"
#$SUDO umount $TESTDIR/usr/local $TESTDIR/srv/wine  && echo "Unmount swine"
$SUDO chroot $TESTDIR su -c "umount /dev/pts"
$SUDO chroot $TESTDIR su -c "umount /proc"
$SUDO umount $TESTDIR && echo "Unmount $SYS"
# -f not supported
rmdir $TESTDIR
