package Test::Unit::tests::TestTest;
use strict;

use base qw(Test::Unit::TestCase);

use Test::Unit::tests::TornDown;
use Test::Unit::tests::WasRun;
use Test::Unit::ExceptionError;
use Test::Unit::ExceptionFailure;
use Class::Inner;
use Error qw/:try/;

sub verify_error {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 1);
    $self->assert(! $result->was_successful());
}

sub verify_failure {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 1);
    $self->assert($result->error_count() == 0);
    $self->assert(! $result->was_successful());
}

sub verify_success {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 0);
    $self->assert($result->was_successful());
}

# test subs

sub make_dummy_testcase {
    my $self = shift;
    my $sub  = pop;
    my $method_name = shift || 'run_test';

    Class::Inner->new(parent => 'Test::Unit::TestCase',
                      methods => { $method_name => $sub });
}

sub test_case_to_string {
    my $self = shift;
    $self->assert(qr"test_case_to_string\(Test::Unit::tests::TestTest\)",
                  $self->to_string);
    $self->assert($self->to_string() eq "test_case_to_string(Test::Unit::tests::TestTest)");
}

sub test_error {
    my $self = shift;
    my $error = $self->make_dummy_testcase(sub { Test::Unit::ExceptionError->throw(-object => $self) });
    $self->verify_error($error);
}

sub test_fail {
    my $self = shift;
    my $fail = $self->make_dummy_testcase(sub { my $self = shift; fail() });
    $self->verify_error($fail);
}

sub test_failure {
    my $self = shift;
    my $failure = $self->make_dummy_testcase(sub {my $self = shift; $self->assert(0)});
    $self->verify_failure($failure);
}
    
sub test_failure_exception {
    my $self = shift;
    try {
        $self->fail;
    }
    catch Test::Unit::ExceptionFailure with {
        1;
    }
    otherwise {
        $self->fail;
    }
}

sub test_run_and_tear_down_fails {
    my $self = shift;
    my $fails = Class::Inner->new
        (
         parent => 'TornDown',
         methods => { tear_down => sub {
                          my $self = shift;
                          $self->SUPER;
                          throw Test::Unit::ExceptionError -object => $self;
                      },
                      run_test => sub {
                          throw Test::Unit::ExceptionError -object => $_[0];
                      }
                    }
        );
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_runner_printing {
    my $self = shift;
    $self->assert("1.05" eq (1050 / 1000));
}

sub test_setup_fails {
    my $self = shift;
    my $fails = Class::Inner->new
        (parent => 'Test::Unit::TestCase',
         methods => { set_up => sub {
                          my $self = shift;
                          throw Test::Unit::ExceptionError -object => $self;
                      },
                      run_test => sub {},
                    },
        );
    $self->verify_error($fails);
}

sub test_success {
    my $self = shift;
    my $success = $self->make_dummy_testcase(sub {shift->assert(1)});
    $self->verify_success($success);
}

sub test_tear_down_after_error {
    my $self = shift;
    my $fails = Class::Inner->new
        (parent => 'TornDown',
         methods => {dummy => sub {}});
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_tear_down_fails {
    my $self = shift;
    my $fails = Class::Inner->new
        (parent => 'Test::Unit::TestCase',
         methods => {tear_down => sub { throw Test::Unit::ExceptionError -object => $_[0] },
                     run_test  => {}});
    $self->verify_error($fails);
}

sub test_tear_down_setup_fails {
    my $self = shift;
    my $fails = Class::Inner->new
        (parent => 'TornDown',
         methods => { set_up => sub { throw Test::Unit::ExceptionError -object => $_[0] } },
        );
    $self->verify_error($fails);
    $self->assert(! $fails->torn_down());
}

sub test_was_not_successful {
    my $self = shift;
    my $failure = $self->make_dummy_testcase(sub { shift->fail });
    $self->verify_failure($failure);
}

sub test_was_run {
    my $self = shift;
    my $test = WasRun->new("");
    $test->run();
    $self->assert($test->was_run());
}

sub test_was_successful {
    my $self = shift;
    my $success = $self->make_dummy_testcase(sub { shift->assert(1) });
    $self->verify_success($success);
}

sub test_assert_on_matching_regex {
    my $self = shift;
    my $matching_regex = $self->make_dummy_testcase
        (sub {
             my $self = shift;
             $self->assert('foo' =~ /foo/, 'foo matches foo (boolean)');
             $self->assert(qr/foo/, 'foo', 'foo matches foo (Assertion::Regex)');
         });
    $self->verify_success($matching_regex);
}

sub test_assert_on_failing_regex {
    my $self = shift;
    
    my $matching_regex = $self->make_dummy_testcase
        (sub {
             my $self = shift;
             $self->assert(scalar("foo" =~ /bar/), "Should not have matched!");
             $self->assert(qr/bar/, "foo");
         });
    $self->verify_failure($matching_regex);
}

sub test_assert_with_non_assertion_object {
    my $self = shift;
    my $obj = bless {}, 'NonExistentClass';
    $self->assert($obj, "Object should eval to true");
}
1;
