# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}
use Test::Unit;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict;
use constant DEBUG => 0;

sub runtest {
    my ($number, $testcase, $expected) = @_;
    open(FH, ">test.out") or die "Error: no write open on test.out: $!";
    local *OLD_STDOUT = *STDOUT;
    local *STDOUT = *FH;
    $testcase->run();
    close(FH);
    open(FH, "<test.out") or die "Error: no read open on test.out: $!";
    local $/ = undef;
    my $result = <FH>;
    if (DEBUG) {
	print OLD_STDOUT "Echo: '", $result, "'\n";
    }
    close(FH);
    if ($result =~ /$expected/) {
	print OLD_STDOUT "ok $number\n";
    } else {
	print OLD_STDOUT "not ok $number\n";
    }
}

my $test_ok = sub { Test::Unit->assert(1 == 1); };
my $test_fail = sub { Test::Unit->assert(23 == 42); };
my $setup = sub { };
my $teardown = sub { };

# --- 2 ---------------------------------------------
my $testcase_ok = new Test::Unit(name => "testcase_ok",
			      test => $test_ok,
			      setup => $setup,
			      teardown => $teardown,
			      );
my $ok_pat = "^\\.\nOK \\(1 test\\)\n\$";
runtest(2, $testcase_ok, $ok_pat);

# --- 3 ---------------------------------------------
my $testcase_ok_full = new Test::Unit(name => "testcase_ok_full",
				      test => sub {
					  print "testcase_ok_full: run\n";
				      },
				      setup => sub { 
					  print "testcase_ok_full: setup\n";
				      },
				      teardown => sub {
					  print "testcase_ok_full: teardown\n";
				      },
			      );
my $ok_pat_full = "^testcase_ok_full: setup\n" .
    "testcase_ok_full: run\n" .
    "testcase_ok_full: teardown\n" .
    "\\.\n" .
    "OK \\(1 test\\)\n\$";
runtest(3, $testcase_ok_full, $ok_pat_full);


# --- 4 ---------------------------------------------
my $testcase_not_ok = new Test::Unit(name => "testcase_not_ok",
			      test => $test_fail,
			      setup => $setup,
			      teardown => $teardown,
			      );
my $fail_pat = "^F\n!!!FAILURES!!!\n".
    "Test Results:\n" .
    "Run: 1 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'testcase_not_ok':[^\n]*\n\$";
runtest(4, $testcase_not_ok, $fail_pat);

# --- 5 ---------------------------------------------
my $testcase_defaults = new Test::Unit();
my $defaults_pat = "^\nOK \\(0 tests\\)\n\$";
runtest(5, $testcase_defaults, $defaults_pat);

# --- 6 ---------------------------------------------
my $tree_1_pat = "^\\.\nOK \\(1 test\\)\n\$";
my $testcase_tree_1 = $testcase_defaults;
$testcase_tree_1->add($testcase_ok);
runtest(6, $testcase_tree_1, $tree_1_pat);

# --- 7 ---------------------------------------------
my $tree_2_pat = "^F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 2 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'testcase_not_ok':[^\n]*\n\$";
my $testcase_tree_2 = $testcase_tree_1;
$testcase_tree_2->add($testcase_not_ok);
runtest(7, $testcase_tree_2, $tree_2_pat);

# --- 8 ---------------------------------------------
package try_1;
sub test_try_1_ok { Test::Unit->assert(1 == 1) }
sub test_try_1_fail { Test::Unit->assert(23 == 43) }

my $try_1_suite_1 = Test::Unit->create_suite();
my $try_1_suite_1_pat = "^F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 2 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'try_1::test_try_1_fail':[^\n]*\n";
main::runtest(8, $try_1_suite_1, $try_1_suite_1_pat);

# --- 9 ---------------------------------------------
package main;
sub test_main_ok { Test::Unit->assert(1 == 1) }
sub test_main_fail { Test::Unit->assert(23 == 43) }
my $try_1_suite_2 = Test::Unit->create_suite(package => "try_1");
my $try_1_suite_2_pat = "^F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 2 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'try_1::test_try_1_fail':[^\n]*\n";
main::runtest(9, $try_1_suite_2, $try_1_suite_2_pat);

# --- 10 ---------------------------------------------
my $main_suite = Test::Unit->create_suite();
my $main_suite_pat = "^F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 2 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'main::test_main_fail':[^\n]*\n";
main::runtest(10, $main_suite, $main_suite_pat);

# --- 11 ---------------------------------------------
package try_2;
sub test_try_2_ok { Test::Unit->assert(1 == 1) }
sub test_try_2_fail { Test::Unit->assert(23 == 43) }

package main;
my $try_1_suite_3 = Test::Unit->create_suite(package => "try_1");
my $try_2_suite = Test::Unit->create_suite(package => "try_2");
my $main_suite_all = Test::Unit->create_suite();
$main_suite_all->add($try_1_suite_3);
$main_suite_all->add($try_2_suite);
my $main_suite_all_pat = "^F\\.F\\.F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 6 Failures: 3\n" .
    "There were 3 failures:\n" .
    "1\\) Testcase 'main::test_main_fail':[^\n]*\n" .
    "2\\) Testcase 'try_1::test_try_1_fail':[^\n]*\n" .
    "3\\) Testcase 'try_2::test_try_2_fail':[^\n]*\n";
main::runtest(11, $main_suite_all, $main_suite_all_pat);

# --- 12 ---------------------------------------------
package empty_subclass;
use vars qw(@ISA);
@ISA = qw(Test::Unit);

sub test_empty_subclass_ok { empty_subclass->assert(1 == 1) }
sub test_empty_subclass_fail { empty_subclass->assert(23 == 43) }

my $empty_subclass_suite = empty_subclass->create_suite();
my $empty_subclass_suite_pat = "^F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 2 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'empty_subclass::test_empty_subclass_fail':[^\n]*\n";
main::runtest(12, $empty_subclass_suite, $empty_subclass_suite_pat);

# --- 13 ---------------------------------------------
# running a test after it has been added to another one
package main;
my $try_2_suite_pat = "^F\\.\n!!!FAILURES!!!\n" .
    "Test Results:\n" .
    "Run: 2 Failures: 1\n" .
    "There was 1 failure:\n" .
    "1\\) Testcase 'try_2::test_try_2_fail':[^\n]*\n";
main::runtest(13, $try_2_suite, $try_2_suite_pat);

# --- 14 ---------------------------------------------
# running a test multiple times
main::runtest(14, $try_2_suite, $try_2_suite_pat);
