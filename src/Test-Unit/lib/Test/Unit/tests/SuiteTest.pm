package Test::Unit::tests::SuiteTest;

use base qw(Test::Unit::TestCase);

use Test::Unit::TestResult;
use Test::Unit::TestSuite;
use Test::Unit::tests::TornDown;
use Test::Unit::tests::WasRun;

sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{_my_result} = undef;
    return $self;
}

sub result {
    my $self = shift;
    return $self->{_my_result};
}
    
sub set_up {
    my $self = shift;
    $self->{_my_result} = Test::Unit::TestResult->new();
}

sub suite {
    my $class = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Suite Tests");
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_no_test_case_class"));
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_no_test_cases"));
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_one_test_case"));
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_not_existing_test_case"));
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_inherited_tests"));
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_inherited_inherited_tests"));
    $suite->add_test(Test::Unit::tests::SuiteTest->new("test_shadowed_tests"));
    return $suite;
}

# test subs

sub test_inherited_tests {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->new("Test::Unit::tests::InheritedTestCase");
    $suite->run($self->result());
    $self->assert($self->result()->was_successful());
    $self->assert(2 == $self->result()->run_count());
}

sub test_inherited_inherited_tests {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->new("Test::Unit::tests::InheritedInheritedTestCase");
    $suite->run($self->result());
    $self->assert($self->result()->was_successful());
    $self->assert(3 == $self->result()->run_count());
}

sub test_no_test_case_class {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("Test::Unit::tests::NoTestCaseClass");
    $t->run($self->result());
    $self->assert(1 == $self->result()->run_count()); # warning test
    $self->assert(not $self->result()->was_successful());
}

sub test_no_test_cases {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("Test::Unit::tests::NoTestCases");
    $t->run($self->result());
    $self->assert(1 == $self->result()->run_count()); # warning test
    $self->assert(1 == $self->result()->failure_count());
    $self->assert(not $self->result()->was_successful());
}

sub test_not_existing_test_case {
    my $self = shift;
    my $t = Test::Unit::tests::SuiteTest->new("not_existing_method");
    $t->run($self->result());
    $self->assert(1 == $self->result()->run_count());
    $self->assert(1 == $self->result()->failure_count());
    $self->assert(0 == $self->result()->error_count());
}

sub test_one_test_case {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("Test::Unit::tests::OneTestCase");
    $t->run($self->result());
    $self->assert(1 == $self->result()->run_count());
    $self->assert(0 == $self->result()->failure_count());
    $self->assert(0 == $self->result()->error_count());
    $self->assert($self->result()->was_successful());
}

sub test_shadowed_tests {
    my $self = shift;
    my $t = Test::Unit::TestSuite->new("Test::Unit::tests::OverrideTestCase");
    $t->run($self->result());
    $self->assert(1 == $self->result()->run_count());
}

1;
