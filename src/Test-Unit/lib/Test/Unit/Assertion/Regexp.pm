package Test::Unit::Assertion::Regexp;

use strict;
use base qw/Test::Unit::Assertion/;

sub new {
    my $class = shift;
    my $regex = shift;

    bless \$regex, $class;
}

sub do_assertion {
    my $self = shift;
    my $target = shift;
    $target =~ $$self ||
        $self->fail("$target did not match /$$self/");
}

1;
