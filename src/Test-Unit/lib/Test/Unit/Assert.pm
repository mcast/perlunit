package Test::Unit::Assert;
use strict;
use constant DEBUG => 0;

sub assert {
    my $self = shift;
    print ref($self) . "::assert() called\n" if DEBUG;
    my ($condition, $message) = @_;
    $self->fail($message) unless $condition;
}

sub fail {
    my $self = shift;
    print ref($self) . "::fail() called\n" if DEBUG;
    my ($message) = @_;
    die Test::Unit::ExceptionFailure->new($message);
}

1;
__END__

=head1 NAME

    Test::Unit::Assert - unit testing framework assertion class

=head1 SYNOPSIS

    # this class is not intended to be used directly, 
    # normally you get the functionality by subclassing from 
    # Test::Unit::TestCase

    use Test::Unit::TestCase;
   
    # more code here ...
    
    $self->assert($your_condition_here);

=head1 DESCRIPTION

    This class is used by the framework to assert boolean conditions
    that determine the result of a given test. Normally, it is not
    used directly, but you get the functionality by subclassing from 
    Test::Unit::TestCase.

=head1 AUTHOR

    Copyright (c) 2000 Christian Lemburg, <lemburg@acm.org>.

    All rights reserved. This program is free software; you can
    redistribute it and/or modify it under the same terms as
    Perl itself.

    Thanks go to the other PerlUnit framework people: 
    Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

    - Test::Unit::TestCase
    - Test::Unit::Exception
    - The framework self-testing suite (Test::Unit::tests::AllTests)

=cut
