package Test::Unit::tests::AssertTest;

use Test::Unit::TestCase;

require Test::Unit::Failure;
require Test::Unit::Error;

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
    return eval {ref($error) && $error->isa('Test::Unit::Failure')};
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

sub test_ok_boolean {
    my $self = shift;
    $self->ok(1);
    $self->check_failures('Expected ok(0) to fail' => sub { shift->ok(0) });
}

sub test_ok_bad_args {
    my $self = shift;
    $self->check_failures(
	'Expected ok() to fail'        => sub { shift->ok()        },
	'Expected ok(1, 2, 3) to fail' => sub { shift->ok(1, 2, 3) },
    );
}

sub test_ok_equals {
    my $self = shift;
    $self->ok(2, 2);
    $self->ok(0, 0);
    $self->ok(1.34, 1.34);
    $self->ok('foo', 'foo');
    $self->ok('', '');
    $self->ok(sub {2+2}, 4);
    $self->ok('fixed', qr/x/);
}

sub test_ok_not_equals {
    my $self = shift;
    my $adder = sub { 2+2 };
    $self->check_failures(
        q{ok(0, 1) should fail}         => sub { shift->ok(0, 1)         },
        q{ok(1, 0) should fail}         => sub { shift->ok(1, 0)         },
        q{ok(2, 3) should fail}         => sub { shift->ok(2, 3)         },
        q{ok(-57, -57.001) should fail} => sub { shift->ok(-57, -57.001) },
        q{ok('foo', 'bar') should fail} => sub { shift->ok('foo', 'bar') },
        q{ok('foo', '') should fail}    => sub { shift->ok('foo', '')    },
        q{ok('', 'foo') should fail}    => sub { shift->ok('', 'foo')    },
        q{ok('', 'foo') should fail}    => sub { shift->ok('', 'foo')    },
        q{ok(sub {2+2}, 5) should fail} => sub { shift->ok($adder, 5)    },
        q{ok('foo', qr/x/) should fail} => sub { shift->ok('foo', qr/x/) },
    );
}

sub test_fail {
    my $self = shift;
    $self->check_failures('Expected fail() to fail' => sub { shift->fail() });
}

sub test_succeed_assert_null {
    my $self = shift;
    $self->assert_null(undef);
}

sub test_fail_assert_null {
    my $self = shift;
    $self->check_failures(
        'Defined is defined' => sub { shift->assert_null('Defined') },
        'Weirdness'          => sub { shift->assert_null('Defined', 'Weirdness') },
    );
}

sub test_success_assert_not_equals {
    my $self = shift;
    $self->assert_not_equals(1,0);
    $self->assert_not_equals(0,1);
    $self->assert_not_equals(0,1E10);
    $self->assert_not_equals(1E10,0);
    $self->assert_not_equals(1,2);
    $self->assert_not_equals('string', 1);
    $self->assert_not_equals(1,'string');
    $self->assert_not_equals('string',0);
    # $self->assert_not_equals(0,'string'); # Numeric comparison done here.. 
}

sub test_fail_assert_not_equals {
    my $self = shift;
    my %tests = ();
    foreach my $pair ([1, 1], [0, 0], [undef, undef],[0, 'string'],
                      ['string', 'string'], ['10', 10], [10, '10']) {
        my ($a, $b) = @$pair;
        $_ ||= 'undef' foreach $a, $b;
	my $code = "assert_not_equals($a, $b)";
        $tests{"$code should fail"} = sub { shift->assert_not_equals(@$pair) };
    }
    $self->check_failures(%tests);
}

sub test_fail_assert_not_null {
    my $self = shift;
    $self->check_failures(
        'assert_not_null(undef) should fail'
            => sub { shift->assert_not_null(undef) }
    );
}

sub test_succeed_assert_not_null {
    my $self = shift;
    $self->assert_not_null(TestObject->new);
    $self->assert_not_null('');
    $self->assert_not_null('undef');
    $self->assert_not_null(0);
    $self->assert_not_null(10);
}

sub check_failures {
    my $self = shift;
    my %tests = @_;
    while (my ($message, $test) = each %tests) {
	my $got_fail = 0;
	try { $self->$test() }
	catch Test::Unit::Failure with {
	    $got_fail++;
	};
	$got_fail || throw Test::Unit::Failure -text => $message, -object => $self;
    }
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
                   'Test::Unit::Failure' =>
                              [
                           {args => [1,'foo'],      name => "1 != 'foo'"    },
                           {args => ['foo', 0],     name => "'foo' ne 0"    },
                           {args => ['foo', 1],     name => "'foo' ne 1"    },
                           {args => [0,1],          name => "0 != 1"        },
                           {args => ['foo', 'bar'], name => "'foo' ne 'bar'"},
                              ],
                  },
);

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
                         } or Test::Unit::Failure->throw(-text => $spec->{name},
                                                                  -object => $self);
                     }, $spec->{name});
            }
        }
    }
    return @tests;
}

1;
