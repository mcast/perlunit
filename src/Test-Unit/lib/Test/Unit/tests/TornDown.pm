package TornDown;

use base qw(Test::Unit::TestCase);

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {_TornDown => 0}, $class;
    my $a_test_case = $self->SUPER::new($name);
    return bless $a_test_case, $class;
}

sub tear_down {
    my $self = shift;
    $self->{_TornDown} = 1;
}

sub torn_down {
    my $self = shift;
    return $self->{_TornDown};
}

sub run_test {
    my $self = shift;
    my $e = new Test::Unit::ExceptionError();
    die $e;
}

1;
