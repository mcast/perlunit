package Test::Unit::tests::AssertTest;

use Test::Unit::TestCase;

require Test::Unit::ExceptionFailure;
require Test::Unit::ExceptionError;

use strict;
use vars qw/@ISA/;

use Error qw/:try/;
use Class::Inner;

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

sub test_assert_equals_again {
    my $self = shift;
    $self->assert_equals(1,'1.0', "1 == '1.0'");
    $self->assert_equals('1.0', 1, "'1.0' == 1");
    $self->assert_equals('foo', 'foo', 'foo eq foo');
    $self->assert_equals('0e0', 0, '0E0 == 0');
    $self->assert_equals(0, 'foo', "0 == 'foo'");
    $self->assert_equals('0', 'foo', "'0' == 'foo'");
}

# Key = assert_method
# Value = [[@arg_list],undef/expected exception]
my %test_hash =
(
 assert_equals => {success => [
                           {args => [0,'foo'],      name => "0 == 'foo'"},
                           {args => [1,'1.0'],      name => "1 == '1.0'"},
                           {args => ['1.0', 1],     name => "'1.0' == 1"},
                           {args => ['foo', 'foo'], name => 'foo eq foo'},
                           {args => ['0e0', 0],     name => '0E0 == 0'  },
                           {args => [0, 'foo'],     name => "0 == 'foo'"},
                              ],
                   Test::Unit::ExceptionFailure =>
                              [
                           {args => [1,'foo'],      name => "1 != 'foo'"    },
                           {args => ['foo', 0],     name => "'foo' ne 0"    },
                           {args => ['foo', 1],     name => "'foo' ne 1"    },
                           {args => [0,1],          name => "0 != 1"        },
                           {args => ['foo', 'bar'], name => "'foo' ne 'bar'"},
                              ],
                  },
);
sub test_assert_not_equals {
    my $self = shift;
    foreach my $pair ([1,'foo'], ['foo', 0], ['foo', 1], [0,1], ['foo', 'bar']) {
        try { $self->assert_equals(@$pair); 0}
        catch Test::Unit::ExceptionFailure with { 1 } or
            Test::Unit::ExceptionFailure->throw(-text => 'should not have matched',
                                                -object => $self);
    }
}


sub suite {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Assertion Tests");
    foreach my $test ($self->make_tests_from_matrix(\%test_hash)) {
        $suite->add_test($test);
    }
    foreach my $test ($self->list_tests) {
        no strict 'refs';
        $suite->add_test($self->make_test_from_coderef(sub {my $self = shift; $self->$test(@_)},$test));
    }
    return $suite;
}


sub make_tests_from_matrix {
    my $self = shift;
    my $matrix = shift;
    my @tests;
    foreach my $method_name (keys %$matrix) {
        # Build 'successful' tests.
        foreach my $spec (@{$matrix->{$method_name}{success}}) {
            push @tests, $self->make_test_from_coderef
                (sub {
                     my $self = shift;
                     $self->$method_name(@{$spec->{args}});
                 }, $spec->{name});
        }
        
        foreach my $outcome (grep {$_ ne 'success'} keys %{$matrix->{$method_name}}) {
            foreach my $spec (@{$matrix->{$method_name}{$outcome}}) {
                push @tests, $self->make_test_from_coderef
                    (sub {
                         my $self = shift;
                         try {
                             $self->$method_name(@{$spec->{args}});
                             0;
                         }
                         catch $outcome with {
                              1;
                         } or Test::Unit::ExceptionFailure->throw(-text => $spec->{name},
                                                                  -object => $self);
                     }, $spec->{name});
            }
        }
    }
    return @tests;
}

1;
