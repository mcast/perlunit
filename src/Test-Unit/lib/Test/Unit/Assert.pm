package Test::Unit::Assert;
use strict;
use constant DEBUG => 0;

sub assert {
    my $self = shift;
    print ref($self) . "::assert() called\n" if DEBUG;
    my ($condition, $message) = @_;
    $self->fail($message) unless $condition;
}

sub fail {
    my $self = shift;
    print ref($self) . "::fail() called\n" if DEBUG;
    my ($message) = @_;
    die Test::Unit::ExceptionFailure->new($message);
}

1;
