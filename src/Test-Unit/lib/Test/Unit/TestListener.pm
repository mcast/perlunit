package Test::Unit::TestListener;
use Test::Unit::TestLoader;
use Carp;
use strict;

# we shouldnt really need this abstract class. Perl is not
# typed! However it is handy to have it barf if I forget to
# fulfil the contract that TestResult expects. - Brian.
# each of the add_ methods gets two arguments: 'test' and 'exception'.
# test is a Test::Unit::Test and exception is a
# Test::Unit::Exception. Typically you want to display
# test->name() and keep the rest as details.

sub new {
    my $class = shift;
    croak "call to abstract constructor ${class}::new";
}

sub add_error { 
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::count_test_cases";
}

sub add_failure {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::add_failure";
}
 
sub end_test {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::end_test";
}
    
sub start_test {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::start_test";
}

1;
