package Test::Unit::Assertion;

use strict;

sub fail {
    my $self = shift;
    my $message = join '', @_;
    my $exception = Test::Unit::ExceptionFailure->new($message);
    $exception->hide_backtrace;
    die $exception;
}

sub do_assertion {
    require Carp;
    Carp::croak("$_[0] forgot to override do_assertion");
}

sub new {
    require Carp;
    Carp::croak("$_[0] forgot to override new");
}

1;
