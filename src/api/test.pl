use strict;

package Test::Unit::Tester;

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

print "------------------------------------------------", "\n";
print "OK\n";
print "------------------------------------------------", "\n";
my $tOK = Test::Unit::Tester->new("testPrintOK");
$tOK->run();

print "------------------------------------------------", "\n";
print "FAIL\n";
print "------------------------------------------------", "\n";
my $tFAIL = Test::Unit::Tester->new("testPrintFAIL");
$tFAIL->run();

