#!/bin/sh

# set GENBASE if target repo was changed

print()
{
	#echo "$@"
	true
}

add_and_remove()
{
	local i=$2
	[ -n "$i" ] || return
	cd $1 2>&1 || return
	local LIST="$i-[0-9]*.*.rpm"
	for file in $LIST ; do
		[ -r "$file" ] || { print "Skip $file (missed now)" ; continue ; }
		# FIXME: just compare dates?
		#test -r $TP/$(basename $file) && cmp "$file" $TP/$(basename $file) && { print "Skip $file (not changed)" ; continue ; }
		# Don't check contains.
		test -r $TP/$(basename $file) && { print "Skip $file (the same name is exists)" ; continue ; }
		# remove previous packages
		rm -fv $TP/$(get_pkgname_from_filename $file)*.rpm
		# copying new package
		cp -flv $file $TP 2>/dev/null || cp -fv $file $TP || fatal "Can't copy $file"
		# set flag to genbase
		GENBASE=1
	done
	#echo "## $(pwd) ## $LIST"
	cd - >/dev/null
}

gen_baserepo()
{
	# run genbase only if has changed files
	[ -n "$GENBASE" ] || return

	set_binaryrepo $(basename $1)
	ssh git.eter genbases -b $BINARYREPO 2>&1 >/dev/null
}
