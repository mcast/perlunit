use strict;

package ATestCase;

require './Unit.pm';

use vars qw(@ISA);
@ISA = qw(Test::Unit::TestCase);

sub testPrintOK {
    my $self = shift;
    print "Testing OK ...\n";
    $self->assert(42 == 42);
}

sub testPrintFAIL {
    my $self = shift;
    print "Testing FAIL ...\n";
    $self->assert(23 == 42);
}

sub setUp {
    my $self = shift;
    print "Hello world!\n";
}

sub tearDown {
    my $self = shift;
    print "Leaving again ...\n";
}

