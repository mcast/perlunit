package Test::Unit;

use strict;
use vars qw($VERSION @ISA @EXPORT $SIGNPOST $test_suite);

use Test::Unit::TestSuite;
use Test::Unit::TestRunner;

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw(assert create_suite run_suite);

if (defined($SIGNPOST)) {
    # highlander principle
    goto END_OF_THIS_MODULE;
} else {
    $SIGNPOST = 'I was here';
    $test_suite = Test::Unit::TestSuite->empty_new("Scripting API");
}
    
$VERSION = '0.10';

sub assert {
    my ($condition, $message) = @_;
    $test_suite->assert($condition, $message);
}

sub create_suite {
    my ($test_package_name) = @_;
    $test_package_name = caller() unless defined($test_package_name);
    $test_suite = Test::Unit::TestSuite->empty_new($test_package_name);
    
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
	    $test_suite->add_test($test_case);
	}
    }
}

sub run_suite {
    my ($filehandle) = @_;
    my $test_runner = Test::Unit::TestRunner->new($filehandle);
    $test_runner->do_run($test_suite);
}

END_OF_THIS_MODULE:

1;
