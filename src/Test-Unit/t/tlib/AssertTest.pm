package AssertTest;

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

package AssertTest;

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
    $self->check_failures('Expected ok(0) to fail'
                              => [ __LINE__, sub { shift->ok(0) } ]);
}

sub test_ok_bad_args {
    my $self = shift;
    $self->check_errors(
        'Expected ok() to fail'
            => [ __LINE__, sub { shift->ok()           } ],
        'Expected ok(1, 2, 3, 4) to fail'
            => [ __LINE__, sub { shift->ok(1, 2, 3, 4) } ],
    );
}

sub test_ok_equals {
    my $self = shift;
    foreach my $args ([0, 0], [2, 2], [1.34, 1.34], 
		      ['foo', 'foo'], ['', ''], 
		      [sub {2+2}, 4], ['fixed', qr/x/]) {
	$self->ok(@$args);
	$self->ok(@$args, 'comment');
    }
}

sub test_ok_not_equals {
    my $self = shift;
    my $adder = sub { 2+2 };
    my %checks = (
        q{0, 1}         => [ 0,      1       ], 
        q{1, 0}         => [ 1,      0       ], 
        q{2, 3}         => [ 2,      3       ], 
        q{-57, -57.001} => [ -57,    -57.001 ], 
        q{'foo', 'bar'} => [ 'foo',  'bar'   ], 
        q{'foo', ''}    => [ 'foo',  ''      ], 
        q{'', 'foo'}    => [ '',     'foo'   ], 
        q{'', 'foo'}    => [ '',     'foo'   ], 
        q{sub {2+2}, 5} => [ $adder, 5       ], 
        q{'foo', qr/x/} => [ 'foo',  qr/x/   ], 
    );
    my %tests = ();
    while (my ($targs, $args) = each %checks) {
        my $message = "ok($targs) should fail";
	$tests{$message}
          = [ __LINE__, sub { shift->ok(@$args) } ];
        $message =~ s/(\) should fail)/, 'comment'$1/;
	$tests{$message}
          = [ __LINE__, sub { shift->ok(@$args, "comment: $message") } ];
    }
    $self->check_failures(%tests);
}

sub test_fail {
    my $self = shift;
    $self->check_failures('Expected fail() to fail'
                            => [ __LINE__, sub { shift->fail() } ]);
}

sub test_succeed_assert_null {
    my $self = shift;
    $self->assert_null(undef);
}

sub test_fail_assert_null {
    my $self = shift;
    $self->check_failures(
        'Defined is defined'
          => [ __LINE__, sub { shift->assert_null('Defined') } ],
        'Weirdness'
          => [ __LINE__, sub { shift->assert_null('Defined', 'Weirdness') } ],
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
        $tests{"$code should fail"}
          = [ __LINE__, sub { shift->assert_not_equals(@$pair) } ];
    }
    $self->check_failures(%tests);
}

sub test_fail_assert_not_null {
    my $self = shift;
    $self->check_failures(
        'assert_not_null(undef) should fail'
          => [ __LINE__, sub { shift->assert_not_null(undef) } ]
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
    $self->check_exceptions('Test::Unit::Failure', @_);
}

sub check_errors {
    my $self = shift;
    $self->check_exceptions('Test::Unit::Error', @_);
}

sub check_exceptions {
    my $self = shift;
    my ($exception_class, %tests) = @_;
    while (my ($message, $test_components) = each %tests) {
        my ($test_code_line, $test) = @$test_components;
	my $exception;
	try {
	    $self->$test();
	}
	catch $exception_class with {
	    $exception = shift;
	}
	otherwise {
	    $exception = 0;
	};
	$exception || throw Test::Unit::Failure -text => $message, -object => $self;
        $self->check_file_and_line($exception, $test_code_line);
    }
}

sub check_file_and_line {
    my $self = shift;
    my ($exception, $test_code_line) = @_;
    if ($exception->file() ne __FILE__) {
        throw Test::Unit::Failure(
            -text   => "failure's file() should have returned "
                       . __FILE__
                       . " (line $test_code_line), not " . $exception->file(),
            -object => $self,
        );
    }
    if ($exception->line() != $test_code_line) {
        throw Test::Unit::Failure(
            -text   => "failure's line() should have returned "
                       . "$test_code_line, not " . $exception->file(),
            -object => $self,
        );
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
