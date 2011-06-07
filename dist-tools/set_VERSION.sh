#! /bin/sh

# This is called during 'make distdir'
#
# Usage:
#  cd to top of project
#  ./tools/set_VERSION.sh $(VERSION) $(DISTVNAME)
#
# Read output or check the exitcode!

modify_files() {
    vsn=$1
    distvname=$2
    perlrun=${ABSPERLRUN:-perl}
    find $distvname/lib -name '*.pm' -print0 | \
	xargs -r0 -n1 $perlrun dist-tools/SetVersion.pl $vsn $distvname/lib
}

if ! modify_files "$@"; then
    {
	echo
	echo "Some files were not updated."
    } >&2
    exit 1
fi
