package Test::Unit::Exception;
use strict;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($message) = @_;
    
    $message = '' unless defined($message);
    $message = ref($class) . ": " . $message . "\n";

    my $i = 0;
    my $stacktrace = '';
    my ($pack, $file, $line, $subname, $hasargs, $wantarray);
    
    while (($pack, $file, $line, $subname, 
	    $hasargs, $wantarray) = caller(++$i)) {
	$stacktrace .= "Level $i: in package '$pack', file '$file', at line '$line', sub '$subname'\n";
    }
    
    bless { _message => $message, _stacktrace => $stacktrace }, $class;
}

sub stacktrace {
    my $self = shift;
    return $self->{_stacktrace};
}

sub get_message {
    my $self = shift;
    return $self->{_message};
}

sub to_string {
    my $self = shift;
    return $self->get_message() . $self->stacktrace();
}

1;

=head1 NAME

    Test::Unit::Exception - unit testing framework exception class

=head1 SYNOPSIS

    # this class is not intended to be used directly 

=head1 DESCRIPTION

    This class is used by the framework to communicate the result
    of assertions, which will throw an instance of a subclass
    of this class in case of errors or failures.

=head1 AUTHOR

    Copyright (c) 2000 Christian Lemburg, <lemburg@acm.org>.

    All rights reserved. This program is free software; you can
    redistribute it and/or modify it under the same terms as
    Perl itself.

    Thanks go to the other PerlUnit framework people: 
    Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

    - Test::Unit::Assert
    - Test::Unit::ExceptionError
    - Test::Unit::ExceptionFailure

=cut
