#!/bin/sh
# 2005, 2006, 2007 (c) Etersoft http://etersoft.ru
# Author: Vitaly Lipatov <lav@etersoft.ru>
# GNU Public License

# BUILDROOT - root of current system
# BUILDERHOME - absolute path to user dir in current system

#WORKDIR=$(dirname $0)
#WORKDIR=.

# TODO: user dist_ver

build_pkgbuild()
{
	local RET
	echo "Copying to $BUILDROOT/tmp"
	cp -f functions/remote-archlinux.sh $BUILDROOT/tmp || { warning "Cannot copy script" ; return 1 ; }
	$SUDO chroot $BUILDROOT su -l $INTUSER -c "$NICE sh -x /tmp/remote-archlinux.sh \"$PACKAGE\" \"$WINENUMVERSION\" \"$PRODUCT\" \"$ETERREGNUM\" \"$SOURCEURL\""
	RET=$?
	if [ $RET != 0 ] ; then
		warning "Can't build"
		#cat $BUILDROOT/var/tmp/portage/app-emulation/$PACKAGE-*/temp/build.log
		return 1
	fi
	true
}

copying_pkgbuild()
{
	prepare_copying

	cp -f $BUILDROOT/home/lav/abs/$PACKAGE/wine*.pkg* $DESTDIR || { warning "Cannot copy packages" ; return 1; }

	chmod g+rw -R $DESTDIR/* || true

}