package AssertTest;

use strict;

use Test::Unit::TestCase;

use Test::Unit::Failure;
use Test::Unit::Error;

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

sub test_assert {
    my $self = shift;
    $self->assert(1);
    $self->assert(1, 'should be true');
    $self->assert(qr/foo/, 'foobar');
    $self->assert(qr/foo/, 'foobar', 'should match /foo/');
    my $coderef = sub {
        $_[0] eq $_[1] or $self->fail("$_[0] ne $_[1]");
    };
    $self->assert($coderef, 'a', 'a');
    $self->check_failures(
        'expected TRUE, got FALSE' => [ __LINE__, sub { shift->assert(0)   } ],
        'expected TRUE, got FALSE' => [ __LINE__, sub { shift->assert('')  } ],

        'bang'  => [ __LINE__, sub { shift->assert(0, 'bang')              } ],
        'bang'  => [ __LINE__, sub { shift->assert('', 'bang')             } ],
        "'qux' did not match /(?-xism:foo)/"
                => [ __LINE__, sub { shift->assert(qr/foo/, 'qux')         } ],
        'bang'  => [ __LINE__, sub { shift->assert(qr/foo/, 'qux', 'bang') } ],
        'a ne b'=> [ __LINE__, sub { shift->assert($coderef, 'a', 'b')     } ],
    );
}

sub test_multi_assert {
    my $self = shift;
    my $assertion = sub {
        $_[0] =~ /1/
          or Test::Unit::Failure->throw(-text => "first arg missing 1");
        $_[1] eq 'cluck'
          or Test::Unit::Failure->throw(-text => "what? no chickens!?");
    };

    $self->multi_assert(
        $assertion,
        [ 1, 'cluck' ],
        [ 'el1te', 'cluck' ],
    );

    $self->check_failures(
        'first arg missing 1'
          => [ __LINE__, sub { shift->multi_assert($assertion, [ 2, 'cluck' ])
                             } ],
        'what? no chickens!?'
          => [ __LINE__, sub { shift->multi_assert($assertion, [ 1, 'cluck' ],
                                                               [ 1, 'moo'   ])
                             } ],
    );

}

sub test_assert_matches {
    my $self = shift;
    $self->assert_matches(qr/ob/i, 'fooBar');
    $self->check_errors(
        'arg 1 to assert_matches() must be a regexp'
            => [ __LINE__, sub { shift->assert_matches(1, 2) } ]
    );
}
    
sub test_assert_does_not_match {
    my $self = shift;
    $self->assert_does_not_match(qr/ob/, 'fooBar');
    $self->check_errors(
        'arg 1 to assert_does_not_match() must be a regexp'
            => [ __LINE__, sub { shift->assert_does_not_match(1, 2) } ]
    );
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

@AssertTest::Exception::ISA = 'Error';
sub test_assert_raises {
    my $self = shift;
    $self->assert_raises(
        'AssertTest::Exception',
        sub { AssertTest::Exception->throw(-text => 'boom'); }
    );
    $self->assert_str_equals('boom', AssertTest::Exception->prior->{-text});
    $self->check_failures(
        'No AssertTest::Exception was raised'
          => [
              __LINE__ + 1,
              sub { shift->assert_raises('AssertTest::Exception', sub {}) }
             ],
        'zxc'
          => [
              __LINE__ + 1,
              sub { shift->assert_raises('AssertTest::Exception', sub {}, 'zxc') }
             ],
    );
}    

sub test_ok_boolean {
    my $self = shift;
    $self->ok(1);
    $self->check_failures(
        'expected TRUE, got FALSE' => [ __LINE__, sub { shift->ok(0)     } ],
        'expected TRUE, got FALSE' => [ __LINE__, sub { shift->ok('')    } ],
        'expected TRUE, got FALSE' => [ __LINE__, sub { shift->ok(undef) } ],
    );
}

sub test_ok_bad_args {
    my $self = shift;
    $self->check_errors(
        'ok() called with wrong number of args'
            => [ __LINE__, sub { shift->ok()           } ],
        'ok() called with wrong number of args'
            => [ __LINE__, sub { shift->ok(1, 2, 3, 4) } ],
    );
}

sub test_ok_equals {
    my $self = shift;
    foreach my $args ([0, 0], [2, 2], [1.34, 1.34], 
		      ['foo', 'foo'], ['', ''], [undef, undef],
		      [sub {2+2}, 4], ['fixed', qr/x/]) {
	$self->ok(@$args);
	$self->ok(@$args, 'comment');
    }
}

sub test_ok_not_equals {
    my $self = shift;
    my $adder = sub { 2+2 };
    my %checks = (
        # interface is ok(GOT, EXPECTED);
        q{expected 1, got 0}                => [ 0,      1       ], 
        q{expected 0, got 1}                => [ 1,      0       ], 
        q{expected 3, got 2}                => [ 2,      3       ], 
        q{expected -57.001, got -57}        => [ -57,    -57.001 ], 
        q{expected 'bar', got 'foo'}        => [ 'foo',  'bar'   ], 
        q{expected '', got 'foo'}           => [ 'foo',  ''      ], 
        q{expected 'foo', got ''}           => [ '',     'foo'   ], 
        q{expected 5, got 4}                => [ $adder, 5       ], 
        q{'foo' did not match /(?-xism:x)/} => [ 'foo',  qr/x/   ], 
    );
    my %tests = ();
    while (my ($expected, $args) = each %checks) {
	$tests{$expected}
          = [ __LINE__, sub { shift->ok(@$args) } ];
	$tests{'failure comment'}
          = [ __LINE__, sub { shift->ok(@$args, 'failure comment') } ];
    }
    $self->check_failures(%tests);
}

sub test_fail {
    my $self = shift;
    $self->check_failures(
        ''                => [ __LINE__, sub { shift->fail() } ],
        'failure message' => [ __LINE__, sub { shift->fail('failure message') } ],
    );
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
    $self->assert_not_equals(1, 0);
    $self->assert_not_equals(0, 1);
    $self->assert_not_equals(0, 1E10);
    $self->assert_not_equals(1E10, 0);
    $self->assert_not_equals(1, 2);
    $self->assert_not_equals('string', 1);
    $self->assert_not_equals(1, 'string');
    $self->assert_not_equals('string', 0);
    # $self->assert_not_equals(0,'string'); # Numeric comparison done here.. 
    # $self->assert_not_equals(0, '');      # Numeric comparison done here.. 
    $self->assert_not_equals('', 0);
    $self->assert_not_equals(undef, 0);
    $self->assert_not_equals(0, undef);
    # $self->assert_not_equals(0, ''); FIXME
    $self->assert_not_equals(undef, '');
    $self->assert_not_equals('', undef);
}

sub test_fail_assert_not_equals {
    my $self = shift;
    my %pairs = (
        # Some of these are debatable, but at least including the tests
        # will alert us if any of the outcomes change.
        "0 and 0 should differ"      => [ 0,        0        ],
        "0 and 0 should differ"      => [ 0,        '0'      ],
        "0 and 0 should differ"      => [ '0',      0        ],
        "0 and 0 should differ"      => [ '0',      '0'      ],
        "1 and 1 should differ"      => [ 1,        1        ],
        "1 and 1 should differ"      => [ 1,        '1'      ],
        "1 and 1 should differ"      => [ '1',      1        ],
        "1 and 1 should differ"      => [ '1',      '1'      ],
        "0 and  should differ"       => [ 0,        ''       ], # Numeric comparison
        "0 and string should differ" => [ 0,        'string' ], # Numeric comparison
        "'' and '' should differ"    => [ '',       ''       ],
        "both args were undefined"   => [ undef,    undef    ],
    );
    my %tests = ();
    while (my ($expected, $pair) = each %pairs) {
        $tests{$expected}
          = [ __LINE__, sub { shift->assert_not_equals(@$pair) } ];
        $tests{"$expected with comment"}
          = [ __LINE__, sub { shift->assert_not_equals(@$pair,
                                                       "$expected with comment") } ];
    }
    $self->check_failures(%tests);
}

sub test_fail_assert_not_null {
    my $self = shift;
    $self->check_failures(
        '<undef> unexpected'
          => [ __LINE__, sub { shift->assert_not_null(undef) } ],
        'Weirdness'
          => [ __LINE__, sub { shift->assert_not_null(undef, 'Weirdness') } ]
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
    my ($asserter, $file, $line)
      = caller($Error::Depth + 1); # EVIL hack!  Assumes check_exceptions
                                   # always called via check_{failures,errors}.
                                   # My brain hurts too much right now to think
                                   # of a better way. 
    while (my ($expected, $test_components) = each %tests) {
        my ($test_code_line, $test) = @$test_components;
	my $exception;
	try {
	    $self->$test();
	}
	catch $exception_class with {
	    $exception = shift;
	}
	catch Error::Simple with {
	    $exception = shift;
	}
	otherwise {
	    $exception = 0;
	};

        try {
            $self->check_exception($exception_class, $expected, $exception);
            $self->check_file_and_line($exception, $test_code_line);
        }
        catch Test::Unit::Failure with {
            my $failure = shift;
            $failure->throw_new(
                -package => $asserter,
                -file    => $file,
                -line    => $line,
                -object  => $self
            );
        }
    }
}

sub check_exception {
    my $self = shift;
    my ($exception_class, $expected, $exception) = @_;
    Test::Unit::Failure->throw(
        -text => "Didn't get $exception_class `$expected'",
        -object => $self,
    ) unless $exception;

    my $got = $exception->text();
    Test::Unit::Failure->throw(
        -text => "Expected $exception_class `$expected', got `$got'",
        -object => $self,
    ) unless $got eq $expected;
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
                       . "$test_code_line, not " . $exception->line(),
            -object => $self,
        );
    }
}

# Key = assert_method
# Value = [[@arg_list],undef/expected exception]
# FIXME: These should probably be merged with the tests for assert_not_equals()
# somehow, since the failures aren't currently tested for the correct message
# via check_exception(), or originating file/line via check_file_and_line().
my %test_hash = (
    assert_equals => {
        success => [
            { args => [0,'foo'],      name => "0 == 'foo'" },
            { args => [1,'1.0'],      name => "1 == '1.0'" },
            { args => ['1.0', 1],     name => "'1.0' == 1" },
            { args => ['foo', 'foo'], name => 'foo eq foo' },
            { args => ['0e0', 0],     name => '0E0 == 0'   },
            { args => [0, 'foo'],     name => "0 == 'foo'" },
            { args => [undef, undef], name => "both undef" },
            { args => [0, 0],         name => "0 == 0"     },
            { args => [0, 0.0],       name => "0 == 0.0"   },
            { args => [0.0, 0],       name => "0.0 == 0"   },
            { args => [0.0, 0.0],     name => "0.0 == 0.0" },
            { args => ['', ''],       name => "'' == ''"   },
        ],
        'Test::Unit::Failure' => [
            { args => [1,'foo'],      name => "1 != 'foo'"     },
            { args => ['foo', 0],     name => "'foo' ne 0"     },
            { args => ['foo', 1],     name => "'foo' ne 1"     },
            { args => [0,1],          name => "0 != 1"         },
            { args => ['foo', 'bar'], name => "'foo' ne 'bar'" },
            { args => ['foo', undef], name => "'foo' ne undef" },
            { args => [undef, 'foo'], name => "undef ne 'foo'" },
            # { args => [0, ''],        name => "0 ne ''"        }, # numeric compare
            
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
