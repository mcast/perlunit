use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
$VERSION=0.1;
WriteMakefile(
    'NAME'	=> 'Test::Unit',
    'VERSION_FROM' => 'Makefile.PL', # finds $VERSION
);
