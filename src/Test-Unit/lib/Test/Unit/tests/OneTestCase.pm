package Test::Unit::tests::OneTestCase;

# Test class used in SuiteTest

use base qw(Test::Unit::TestCase);

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {}, $class;
    my $a_test_case = $self->SUPER::new($name);
    return bless $a_test_case, $class;
}

sub no_test_case {
}

sub test_case {
}

1;
