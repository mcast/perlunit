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

sub testPrintFAILwithMessage {
    my $self = shift;
    print "Testing FAILwithMessage ...\n";
    $self->assert(23 == 42, "This is a rather stupid example message. Invent a better one, please!");
}

sub testPrintERROR {
    my $self = shift;
    print "Testing ERROR ...\n";
    my $a = 0;
    my $b = 1;
    $b/$a;
}

sub setUp {
    my $self = shift;
    print "Hello world!\n";
}

sub tearDown {
    my $self = shift;
    print "Leaving again ...\n";
}

sub setUp {
    my $self = shift;
    print "Hello world!\n";
}

sub tearDown {
    my $self = shift;
    print "Leaving again ...\n";
}

