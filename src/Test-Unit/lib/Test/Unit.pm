package Test::Unit;

use strict;
use vars qw($VERSION @ISA @EXPORT);

use Test::Unit::TestSuite;
use Test::Unit::TestRunner;

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw(assert create_suite run_suite add_suite);

$VERSION = '0.10';

# private

my $test_suite = Test::Unit::TestSuite->empty_new("Test::Unit");
my %suites = ();
%suites = ('Test::Unit' => $test_suite);
    
sub add_to_suites {
    my $suite_holder = shift;
    if (not exists $suites{$suite_holder}) {
	my $test_suite = Test::Unit::TestSuite->empty_new($suite_holder);
	$suites{$suite_holder} = $test_suite;
    }
}

# public

sub assert {
    my ($condition, $message) = @_;
    my $asserter = caller();
    add_to_suites($asserter);
    $suites{$asserter}->assert($condition, $message);
}

sub create_suite {
    my ($test_package_name) = @_;
    $test_package_name = caller() unless defined($test_package_name);
    add_to_suites($test_package_name);
    
    no strict 'refs';

    my $set_up_call = "42";
    my $tear_down_call = "23";

    my @set_up_candidates = grep /^set_up$/, keys %{"$test_package_name" . "::"};
    for my $c (@set_up_candidates) {
	if (defined(&{$test_package_name . "::" . $c})) {
	    $set_up_call = $test_package_name . "::" . $c . "()";
	}
    }

    my @tear_down_candidates = grep /^tear_down$/, keys %{"$test_package_name" . "::"};
    for my $c (@tear_down_candidates) {
	if (defined(&{$test_package_name . "::" . $c})) {
	    $tear_down_call = $test_package_name . "::" . $c . "()";
	}
    }

    my @candidates = grep /^test/, keys %{"$test_package_name" . "::"};
    for my $c (@candidates) {
	if (defined(&{$test_package_name . "::" . $c})) {
	    my $test_method_call = $test_package_name . "::" . $c . "()";
	    my $test_case = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<"EOIC", $c);
# note: interpolation mode here
sub set_up {
    $set_up_call ;
}
sub $c {
    $test_method_call ;
}
sub tear_down {
    $tear_down_call ;
}
EOIC
	    $suites{$test_package_name}->add_test($test_case);
	}
    }
}

sub run_suite {
    my ($test_package_name, $filehandle) = @_;
    $test_package_name = caller() unless defined($test_package_name);
    my $test_runner = Test::Unit::TestRunner->new($filehandle);
    $test_runner->do_run($suites{$test_package_name});
}

sub add_suite {
    my ($to_be_added, $to_add_to) = @_;
    $to_add_to = caller() unless defined($to_add_to);
    die "Error: no suite '$to_be_added'" unless exists $suites{$to_be_added};
    die "Error: no suite '$to_add_to'" unless exists $suites{$to_add_to};
    $suites{$to_add_to}->add_test($suites{$to_be_added});
}

1;
