use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	   => 'Test::Unit',
    'VERSION_FROM' => 'lib/Test/Unit/Test.pm', # finds $VERSION
    'PREREQ_PM'    => {'Class::Inner' => 0,
    		       'Devel::Symdump' => 0,
	              },
);
