package Test::Unit::TestFailure;
use strict;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($test, $exception) = @_;
    bless { 
	_Failed_test => $test,
	_Thrown_exception => $exception,
    }, $class;
}

sub failed_test {
    my $self = shift;
    return $self->{_Failed_test};
}

sub thrown_exception {
    my $self = shift;
    return $self->{_Thrown_exception};
}

sub to_string {
    my $self = shift;
    return $self->failed_test()->to_string() . 
	$self->thrown_exception()->stacktrace();
}

1;
