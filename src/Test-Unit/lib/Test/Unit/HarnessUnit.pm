package Test::Unit::HarnessUnit;
# this is a test runner which outputs in the same
# format that Test::Harness expects. 
use strict;
use constant DEBUG => 0;

use base qw(Test::Unit::TestListener); 

use Test::Unit::TestSuite;
use Test::Unit::TestResult;

sub new {
    my $class = shift;
    my ($filehandle) = @_;
	# should really use the IO::Handle package here.
	# this is very ugly.
    $filehandle = \*STDOUT unless $filehandle;
    bless { _Print_stream => $filehandle }, $class;
}

sub print_stream {
    my $self = shift;
    return $self->{_Print_stream};
}

sub _print {
    my $self = shift;
    my (@args) = @_;
    local *FH = *{$self->print_stream()};
    print FH @args;
}

sub start_test {
  my $self=shift;
  my $test=shift;
}

sub add_error {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("\nnot ok ERROR ".$test->name()."\n");
}
	
sub add_failure {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("\nnot ok FAIL ".$test->name()."\n");
}

sub add_pass {
    # in this runner passes are ignored.
    my $self = shift;
    my ($test) = @_;
    $self->_print("\nok PASS ".$test->name()."\n");
}

sub end_test {
    my $self = shift;
    my ($test) = @_;
	print "\nTEST ".$test->name()." complete.\n";
}

sub create_test_result {
    my $self = shift;
    return Test::Unit::TestResult->new();
}
	
sub do_run {
    my $self = shift;
    my ($suite) = @_;
    my $result = $self->create_test_result();
	my $count=$suite->count_test_cases();
    $result->add_listener($self);
    $suite->run($result);
    if (not $result->was_successful()) {
    	exit(-1);
    }
    exit(0);		
}

sub this_package {
  # trick cycling. I need the name of the current package,
  # not the calling package, in some of the static methods.
  # If this were java it would be a private static method.
  return (caller())[0];
}

sub main {
    my $self = shift;
    my $a_test_runner = this_package()->new();
    $a_test_runner->start(@_);
}

sub run {
    my $self = shift;
    my ($class) = @_;
    if ($class->isa("Test::Unit::Test")) {
	$self->_run($class);
    } else {
	$self->_run(Test::Unit::TestSuite->new($class));
    }
}
	
sub _run {
    my $self = shift;
    my ($test) = @_;
    my $a_test_runner = this_package()->new();
    $a_test_runner->do_run($test, 0);
}

sub start {
    my $self = shift;
    my (@args) = @_;

    my $test_case = "";
    my $wait = 0;
	my $suite=Test::Unit::TestLoader::load(@args);
	if ($suite) {
	  my $count=$suite->count_test_cases();
	  print "\nSTARTING TEST RUN\n1..$count\n";
	  $self->do_run($suite);
	  exit(0);
    } else {
	  print "Invalid argument to test runner: $args[0]\n";
	  exit(1);
	}
}

1;
