package Test::Unit::tests::TestUnitTest;

use strict;

use base qw(Test::Unit::TestCase);

use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {}, $class;
    my $a_test_case = $self->SUPER::new($name);
    bless $a_test_case, $class;
    $a_test_case->{_my_tmpfile} = "./_tmpfile";
    return $a_test_case;
}

sub set_up {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    die "Please remove $filename, I need it for testing ..." if (-e $filename);
}

sub tear_down {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    if (DEBUG) {
	print " LOOK NOW in $filename "; 
	my $answer = <STDIN>;
    }
    die "Could not remove $filename: $!" unless unlink($filename);
}
    
# test subs

sub test_pkg_main_ok {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    # we must redefine subs test_1 and test_2 in the eval 
    # to get new results for test_1 and test_2 in package main
    # if we just introduce new tests here, 
    # test_1 and test_2 will be run, too, ruining our ok result,
    # so switch warnings off to keep nice output
    local $^W = 0;
    eval << "EOT";
package main; 
use Test::Unit;
sub test_1 { assert(42 == 42); }
sub test_2 { assert(23 == 23); }
create_suite(); 
open(FH, '>$filename');
run_suite(\*FH);
close(FH);
EOT
    $self->assert(not $@); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

sub test_pkg_main_fail {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    eval << "EOT";
package main; 
use Test::Unit;
sub test_1 { assert(23 == 42); }
sub test_2 { assert(42 == 23); }
create_suite(); 
open(FH, '>$filename');
run_suite(\*FH);
close(FH);
EOT
    # this depends on the die message in Test::Unit::TestRunner
    $self->assert($@ eq "\nTest was not successful.\n"); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

1;
