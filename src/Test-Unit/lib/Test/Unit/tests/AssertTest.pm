package Test::Unit::tests::AssertTest;

use Test::Unit::TestCase;

require Test::Unit::ExceptionFailure;
require Test::Unit::ExceptionError;

use strict;
use vars qw/@ISA/;

use Error qw/:try/;

package TestObject;
sub new {
    my $class = shift;
    bless [@_], $class;
}

package Test::Unit::tests::AssertTest;

use vars qw/@ISA/;
@ISA = 'Test::Unit::TestCase';

sub assertion_has_failed {
    my $error = shift;
    return eval {ref($error) && $error->isa('Test::Unit::ExceptionFailure')};
}



sub test_assert_equals {
    my $self = shift;
    my $o = TestObject->new();
    $self->assert_equals($o, $o);
}

sub test_assert_equals_null {
    my $self = shift;
    $self->assert_equals(undef, undef);
}

# Not sure this has meaning in Perl
#  sub test_assert_null_not_equals_null {
#      my $self = shift;
#      eval { $self->assert_equals(undef, TestObject->new()) };
#      $self->fail unless assertion_has_failed($@);
#  }


sub test_fail {
    my $self = shift;
    my $got_fail;
    try { $self->fail }
    catch Test::Unit::ExceptionFailure with { $got_fail = 1 }
    otherwise { $got_fail = 0 };
    $got_fail ||
        throw Test::Unit::ExceptionFailure -text => 'Expected to fail', -object => $self;
}

sub test_fail_assert_not_null {
    my $self = shift;
    my $got_fail;
    try { $self->assert_not_null(undef) }
    catch Test::Unit::ExceptionFailure with { $got_fail = 1 }
    otherwise { $got_fail = 0 };
    $got_fail ||
        throw Test::Unit::ExceptionFailure -text => "Expected failure...", -object => $self;
}

sub test_succeed_assert_not_null {
    my $self = shift;
    $self->assert_not_null(TestObject->new);
    $self->assert_not_null('');
    $self->assert_not_null('undef');
    $self->assert_not_null(0);
    $self->assert_not_null(10);
}

1;
