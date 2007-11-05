package ManyThrowsTestCase;

# Test class used by t/error-compat.t

use base qw(Test::Unit::TestCase);
use Error;

{
    my $count = 0;
    sub count_ran	{ $count }
    sub _count_bump	{ $count ++ }

    sub count_want_pass	{ 2 }	# we expect two passes
    sub count_want_ran	{ 7 }	# of six test methods
}

sub test_plain_pass {
    _count_bump();
    1;
}

sub test_dies {
    _count_bump();
    die "it dies with a message";
}

sub test_error {
    _count_bump();
    throw Error::Simple("basic error type");
}

sub test_strange {
    _count_bump();
    _throw_nonstandard();
}

sub test_die_undef {
    _count_bump();
    local $SIG{__WARN__} = sub {}; # silence the inevitable warning
    die undef;
}

sub test_assert_raises {
    _count_bump();
    my $self = shift;
    $self->assert_raises("Error::StrangeType", \&_throw_nonstandard);
    $self->assert_raises("Error::ScalarException", \&_throw_scalar);
}

sub test_scalar_exception {
    _count_bump();
    _throw_scalar();
}


sub _throw_scalar {
    my $scalar = "strange message";
    my $err = bless \$scalar, "Error::ScalarException";
    die $err;
}

# This home-brewed exception doesn't support Error.pm's "catch" operator
sub _throw_nonstandard {
    my $err = bless {}, "Error::StrangeType";
    die $err;
}

1;
