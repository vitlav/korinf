#!/bin/sh

# load common functions, compatible with local and installed script
. `dirname $0`/../share/eterbuild/korinf/common

TFILE=/var/ftp/pub/people/lav/nfound_test_file.out

RPATH=$(dirname $0)
do_test()
{

SC=$RPATH/list_nfound_libs.sh

$SC 1.0.12
#$SC testing
$SC 2.1
$SC 2.1-testing
#$SC cad
#$SC school
#$SC school-testing
$SC unstable

#$SC last wine /var/ftp/pub/Etersoft/Wine-public
$SC last wine-vanilla /var/ftp/pub/Etersoft/Wine-vanilla
$SC last wine /var/ftp/pub/Etersoft/Wine-staging

}

touch "$TFILE"
do_test >$TFILE.new 2>&1
DIFF=$(diff -u "$TFILE" "$TFILE.new")

if [ -n "$DIFF" ] ; then
	( echo "Generated by $0 script" ; echo "Full list can be loaded from ftp://server${TFILE/\/var\/ftp/}" ; echo ; echo "$DIFF" ) | mutt $EMAILNOTIFY -s "Changes in wine's not found libs"
fi

rm -f "$TFILE"
mv "$TFILE.new" "$TFILE"
