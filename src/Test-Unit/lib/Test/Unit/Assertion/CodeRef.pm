package Test::Unit::Assertion::CodeRef;

use strict;
use base qw/Test::Unit::Assertion/;

require Test::Unit::ExceptionFailure;

use Carp;

use B::Deparse;

use overload '""' => \&to_string;

my $deparser;

sub new {
    my $class       = shift;
    my $code = shift;
    croak "$class\::new needs a CODEREF" unless ref($code) eq 'CODE';
    bless \$code => $class;
}

sub do_assertion {
    my $self = shift;
    my $possible_object = shift;
    $possible_object->$$self(@_) ||
        $self->fail("$possible_object\->{$self}(" .
                    join (", ", @_) .
                    ") failed" . ($@ ? "with error $@." : "."));
}

sub to_string {
    my $self = shift;
    $deparser ||= B::Deparse->new("-p");
    return join '', "sub ", $deparser->coderef2text($$self);
}

1;
