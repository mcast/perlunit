package Test::Unit::tests::OverrideTestCase;
use strict;

# Test class used in SuiteTest

use base qw(Test::Unit::tests::OneTestCase);

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {}, $class;
    my $a_test_case = $self->SUPER::new($name);
    return bless $a_test_case, $class;
}

sub test_case {
}

1;
