# This is a makeover of Test::Harness to allow its tests
# to be retrofitted as unit tests.
package Test::Unit::UnitHarness;

BEGIN {require 5.002;}
use base qw(Test::Unit::TestListener Test::Unit::Test);
use Exporter;
use Config;
use Carp;
use FileHandle;
use constant DEBUG => 1;
use Test::Unit::TestCase;
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

# class and object methods

sub new {
    my $class = shift;
    my ($name) = @_;
    
    my @_Tests = ();
    my $self = {
	_Tests => \@_Tests,
	_Name => $name,
	_Names => [],
    };
    bless $self, $class;
    print ref($self) . "::new($name) called\n" if DEBUG;
    
    return $self;
}

sub run {
  my $self=shift;
  my $result=shift;
  my $test=$self->{_Name};
  my $fh = new FileHandle;
  my $next=1;
  my $max=0;

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
	  # Not supported in TestResult - It's needed!!!
      #$result->plan($1);
      $next=1;
      $max=$1;
    } elsif ($max && /^(not\s+)?ok\b/) {
      my $this = $next;
      if (/^not ok\s*(\d*)/){
	$this = $1 if $1 > 0;
	$result->add_failure($this);
      } elsif (/^ok\s*(\d*)/) {
	$this = $1 if $1 > 0;
	$result->add_pass($this);
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

sub name {
    my $self = shift;
    return $self->{_Name};
}

sub names {
    my $self = shift;
    return $self->{_Names};
}

sub add_test {
  croak "This is suite is not mutable.";
}

sub add_test_method {
  croak "This suite is not mutable.";
}
 
sub count_test_cases {
  return 0;
}

sub to_string {
    my $self = shift;
    return $self->{_Name};
}

sub warning {
    my $self = shift;
    my ($message) = @_;
    return make_inner_class("Test::Unit::TestCase", <<"EOIC", "warning");
sub run_test {
    my \$self = shift;
    \$self->fail('$message');
EOIC
}

1;
__END__

=head1 NAME

=cut
