package Test::Unit::Assertion::Boolean;

use strict;
use base 'Test::Unit::Assertion';

sub new {
    my $class = shift;
    my $bool  = shift;

    my $self = \$bool;
    bless $self, $class;
}

sub do_assertion {
    my $self = shift;
    $self->fail(@_) unless $$self;
}

1;
