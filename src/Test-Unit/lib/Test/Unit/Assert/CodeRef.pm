package Test::Unit::Assert::CodeRef;

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

sub do_assert {
    my $self = shift;
    die Test::Unit::ExceptionFailure->new("$self\->('". join("', '", @_). "') failed.")
        unless $$self->(@_);
                                     
}

sub to_string {
    my $self = shift;
    $deparser ||= B::Deparse->new("-p");
    return join '', "sub ", $deparser->coderef2text($$self);
}

1;
