use ExtUtils::MakeMaker;
use strict;
# use warnings; # avoid, and hope the caller has -w

use lib 'inc';
use GetVersion;
use MY_distdir;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

require 5.005;

WriteMakefile(
    'NAME'         => 'Test::Unit',

    # When building from source, consult Git; else VERSION_FROM T:U
    GetVersion->version_pair(),

    # When building from source not a dist tarball, modules have not
    # been edited to insert $VERSION.  Test::Unit which requires this,
    # so we lie to SetVersion.pl to make it just do that file.
    PM_FILTER      => (-d "dist-tools/"
		       ? q{$(ABSPERLRUN) dist-tools/SetVersion.pl --pmf $(VERSION) Test::Unit}
		       : undef),

    'PREREQ_PM'    => {
                       'Class::Inner'   => 0,
                       'Devel::Symdump' => 0,
                       'Error'          => 0,
                       'base'           => 1,
                      },
);
