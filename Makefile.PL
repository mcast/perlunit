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
    GetVersion->version_pair(),
    'PREREQ_PM'    => {
                       'Class::Inner'   => 0,
                       'Devel::Symdump' => 0,
                       'Error'          => 0,
                       'base'           => 1,
                      },
);
