package Test::Unit::Test;
use strict;
use constant DEBUG => 0;

use Carp;

sub count_test_cases {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::count_test_cases";
}

sub run {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::run";
}

1;
