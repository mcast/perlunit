use ExtUtils::MakeMaker;
use strict;

# This horribleness because we run with 'perl Makefile.PL ...' and
# don't want to 'use warnings'.  See MIN_PERL_VERSION below.
$^W ||= 1;

require 5.005; # DUP: see MIN_PERL_VERSION

use lib 'inc';
use GetVersion;
use MY_distdir;


WriteMakefile
  (### Functional elements, for the build to work
   #

   NAME           => 'Test::Unit',

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


   ### Informational elements, to build META.yml
   #
   # Written for the spec1.4 produced by EU:MM v6.55_02 (Perl 5.10.1)
   #   http://module-build.sourceforge.net/META-spec-v1.4.html
   #
   # but with an eye to current stable spec2
   #   http://module-build.sourceforge.net/META-spec-current.html -->
   #   http://search.cpan.org/dist/CPAN-Meta/lib/CPAN/Meta/Spec.pm v2.110930

   ABSTRACT_FROM  => 'lib/Test/Unit.pm',

   LICENSE => 'perl',
   # META.yml spec 2 says 'perl_5'.  Spec 1.4 defers to
   # Module::Build::API, where 5.10.1 says 'perl'.

   # DUP: this file's require
   MIN_PERL_VERSION => '5.005', # for qr{}
   # Version 0.14 and earlier ran on older Perls.  Let us know if you
   # still need to do that.
   #
   # 'use base' is rife, POD says that is 5.004_04.
   # 'use warnings' should be used in build support only, needs 5.6 (?)

   META_MERGE =>
   {
    # here because EU:MM 'AUTHOR' wants one string
    author => [ 'Matthew Astley <mca1001@users.sourceforge.net>',
		'Perlunit Users <perlunit-users@lists.sourceforge.net>' ],
#
# CPAN::Meta::Spec v2.110930 says of 'author =>' for spec 1.2
#
# # The addressee(s) can be contacted for any purpose [...]
# #
# # A distribution's original author is usually the contact listed
# # within this field. Co-maintainers, successor maintainers or
# # mailing lists devoted to the distribution may also be listed in
# # addition to or instead of the original author.
#
# Original authors don't want to be contacted.  I am not claiming to
# be "the author".  I wish the META key were s/author/contact/ but too
# late now.

    # call us to build, but not to know our requirements
    dynamic_config => 1,
    # 1 by the older spec1.0 meaning; 0 by spec2

    resources =>
    {
     license => [ 'http://perlunit.git.sourceforge.net/git/gitweb.cgi?p=perlunit/perlunit;a=blob;f=AUTHORS;hb=master' ],
     homepage => 'http://perlunit.sourceforge.net/',
     Repository => # data per spec2; subkey conforms to spec 1.4
     {
      url => 'git://perlunit.git.sourceforge.net/gitroot/perlunit/perlunit',
      web => 'http://perlunit.git.sourceforge.net/git/gitweb.cgi?p=perlunit/perlunit',
      type => 'git',
     },
     # bugtracker => rt.cpan, I guess; project roots are still in SourceForge
    },
   });
