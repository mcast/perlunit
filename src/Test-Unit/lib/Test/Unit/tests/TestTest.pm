package Test::Unit::tests::TestTest;
use strict;

use base qw(Test::Unit::TestCase);

use Test::Unit::tests::TornDown;
use Test::Unit::tests::WasRun;
use Test::Unit::InnerClass;

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {}, $class;
    my $a_test_case = $self->SUPER::new($name);
    return bless $a_test_case, $class;
}
    
sub verify_error {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 1);
}

sub verify_failure {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 1);
    $self->assert($result->error_count() == 0);
}

sub verify_success {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 0);
}

# test subs

sub test_case_to_string {
    my $self = shift;
    $self->assert($self->to_string() eq "test_case_to_string(Test::Unit::tests::TestTest)");
}

sub test_error {
    my $self = shift;
    my $error = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "error"); 
sub run_test {
    my $self = shift;
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verify_error($error);
}

sub test_fail {
    my $self = shift;
    my $fail = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fail"); 
sub run_test {
    my $self = shift;
    fail();
}
EOIC
    $self->verify_error($fail);
}

sub test_failure {
    my $self = shift;
    my $failure = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "failure"); 
sub run_test {
    my $self = shift;
    $self->assert(0);
}
EOIC
    $self->verify_failure($failure);
}
    
sub test_failure_exception {
    my $self = shift;
    eval {
	$self->fail();
    };
    my $exception = $@;
    if ($exception->isa("Test::Unit::ExceptionFailure")) {
	return;
    }
    $self->fail();
}

sub test_run_and_tear_down_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("TornDown", <<'EOIC', "fails");
sub tear_down {
    my $self = shift;
    $self->SUPER::tear_down();
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub run_test {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_runner_printing {
    my $self = shift;
    $self->assert("1.05" eq (1050 / 1000));
}

sub test_setup_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fails"); 
sub set_up {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub run_test {
}
EOIC
    $self->verify_error($fails);
}

sub test_success {
    my $self = shift;
    my $success = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "success"); 
sub run_test {
    my $self = shift;
    $self->assert(1);
}
EOIC
    $self->verify_success($success);
}

sub test_tear_down_after_error {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("TornDown", "", "fails");
    $self->verify_error($fails);
    $self->assert($fails->torn_down());
}

sub test_tear_down_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fails"); 
sub tear_down {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub run_test {
}
EOIC
    $self->verify_error($fails);
}

sub test_tear_down_setup_fails {
    my $self = shift;
    my $fails = Test::Unit::InnerClass::make_inner_class("TornDown", <<'EOIC', "fails");
sub set_up {
    my $self = shift;
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verify_error($fails);
    $self->assert(not $fails->torn_down());
}

sub test_was_not_successful {
    my $self = shift;
    my $failure = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "fail"); 
sub run_test {
    my $self = shift;
    $self->fail();
}
EOIC
    my $result = $failure->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 1);
    $self->assert($result->error_count() == 0);
    $self->assert(not $result->was_successful());
}

sub test_was_run {
    my $self = shift;
    my $test = WasRun->new("");
    $test->run();
    $self->assert($test->was_run());
}

sub test_was_successful {
    my $self = shift;
    my $success = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<'EOIC', "success"); 
sub run_test {
    my $self = shift;
    $self->assert(1);
}
EOIC
    my $result = $success->run();
    $self->assert($result->run_count() == 1);
    $self->assert($result->failure_count() == 0);
    $self->assert($result->error_count() == 0);
    $self->assert($result->was_successful());
}

1;
