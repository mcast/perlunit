package WasRun;
use strict;

use base qw(Test::Unit::TestCase);

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {_WasRun => 0}, $class;
    my $a_test_case = $self->SUPER::new($name);
    return bless $a_test_case, $class;
}

sub run_test {
    my $self = shift;
    $self->{_WasRun} = 1;
}

sub was_run {
    my $self = shift;
    return $self->{_WasRun};
}

1;
