package Test::SuiteWrapper;

BEGIN {require 5.002;}
use Exporter;
use Config;
use FileHandle;
use strict;

use vars qw($VERSION $verbose $switches $have_devel_corestack $curtest
	    @ISA @EXPORT @EXPORT_OK);
$have_devel_corestack = 0;

$VERSION = "1.1502";

@ISA=('Exporter');
@EXPORT= qw(&runtests);
@EXPORT_OK= qw($verbose $switches);

$verbose = 1;
$switches = "-w";

sub new {
  my $self=bless {},shift;
  $self->{'test'}=shift;
  $self->{'listener'}=$self;
  return $self;
}

sub add_listener {
  my $self=shift;
  $self->{'listener'}=shift;
}

sub run {
  my $self=shift;
  my $test=$self->{'test'};
  my $fh = new FileHandle;
  my $next=1;
  my $max=0;
  my $listener=$self->{'listener'};
  # pass -I flags to children
  my $old5lib = $ENV{PERL5LIB};
  local($ENV{'PERL5LIB'}) = join($Config{path_sep}, @INC);
  
  if ($^O eq 'VMS') { $switches =~ s/-(\S*[A-Z]\S*)/"-$1"/g }

  $fh->open($test) or print "can't open $test. $!\n";
  my $first = <$fh>;
  my $s = $switches;
  $s .= q[ "-T"] if $first =~ /^#!.*\bperl.*-\w*T/;
    $fh->close or print "can't close $test. $!\n";
  my $cmd = "$^X $s $test|";
  $cmd = "MCR $cmd" if $^O eq 'VMS';
  $fh->open($cmd) or print "can't run $test. $!\n";
  while (<$fh>) {
    if( $verbose ){ print $_; }
    if (/^1\.\.([0-9]+)/) {
      $listener->plan($1);
      $next=1;
      $max=$1;
    } elsif ($max && /^(not\s+)?ok\b/) {
      my $this = $next;
      if (/^not ok\s*(\d*)/){
	$this = $1 if $1 > 0;
	$listener->fail($this);
      } elsif (/^ok\s*(\d*)/) {
	$this = $1 if $1 > 0;
	$listener->pass($this);
      }
      $next++;
    }
  }
  $fh->close; # must close to reap child resource values
  if ($^O eq 'VMS') {
    if (defined $old5lib) {
      $ENV{PERL5LIB} = $old5lib;
    } else {
      delete $ENV{PERL5LIB};
    }
  }
}


1;
__END__

=head1 NAME

Test::Harness - run perl standard test scripts with statistics

=head1 SYNOPSIS

use Test::Harness;

runtests(@tests);

=head1 DESCRIPTION

Perl test scripts print to standard output C<"ok N"> for each single
test, where C<N> is an increasing sequence of integers. The first line
output by a standard test script is C<"1..M"> with C<M> being the
number of tests that should be run within the test
script. Test::Harness::runtests(@tests) runs all the testscripts
named as arguments and checks standard output for the expected
C<"ok N"> strings.

After all tests have been performed, runtests() prints some
performance statistics that are computed by the Benchmark module.

=head2 The test script output

Any output from the testscript to standard error is ignored and
bypassed, thus will be seen by the user. Lines written to standard
output containing C</^(not\s+)?ok\b/> are interpreted as feedback for
runtests().  All other lines are discarded.

It is tolerated if the test numbers after C<ok> are omitted. In this
case Test::Harness maintains temporarily its own counter until the
script supplies test numbers again. So the following test script

    print <<END;
    1..6
    not ok
    ok
    not ok
    ok
    ok
    END

will generate 

    FAILED tests 1, 3, 6
    Failed 3/6 tests, 50.00% okay

The global variable $Test::Harness::verbose is exportable and can be
used to let runtests() display the standard output of the script
without altering the behavior otherwise.

The global variable $Test::Harness::switches is exportable and can be
used to set perl command line options used for running the test
script(s). The default value is C<-w>.

=head1 EXPORT

C<&runtests> is exported by Test::Harness per default.

=head1 DIAGNOSTICS

=over 4

=item C<All tests successful.\nFiles=%d,  Tests=%d, %s>

If all tests are successful some statistics about the performance are
printed.

=item C<FAILED tests %s\n\tFailed %d/%d tests, %.2f%% okay.>

For any single script that has failing subtests statistics like the
above are printed.

=item C<Test returned status %d (wstat %d)>

Scripts that return a non-zero exit status, both C<$? E<gt>E<gt> 8> and C<$?> are
printed in a message similar to the above.

=item C<Failed 1 test, %.2f%% okay. %s>

=item C<Failed %d/%d tests, %.2f%% okay. %s>

If not all tests were successful, the script dies with one of the
above messages.

=back

=head1 SEE ALSO

See L<Benchmark> for the underlying timing routines.

=head1 AUTHORS

Either Tim Bunce or Andreas Koenig, we don't know. What we know for
sure is, that it was inspired by Larry Wall's TEST script that came
with perl distributions for ages. Numerous anonymous contributors
exist. Current maintainer is Andreas Koenig.

=head1 BUGS

Test::Harness uses $^X to determine the perl binary to run the tests
with. Test scripts running via the shebang (C<#!>) line may not be
portable because $^X is not consistent for shebang scripts across
platforms. This is no problem when Test::Harness is run with an
absolute path to the perl binary or when $^X can be found in the path.

=cut
