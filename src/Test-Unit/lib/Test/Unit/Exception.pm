package Test::Unit::Exception;
use Carp;
use strict;
use constant DEBUG => 0;

use Error;
use base 'Error';

sub stacktrace {
    my $self = shift;
    warn "Stacktrace is deprecated and no longer works"
}

sub get_message {
    my $self = shift;
    $self->text;
}

sub hide_backtrace {
    my $self = shift;
    $self->{_hide_backtrace} = 1;
}

sub stringify {
    my $self = shift;
    my $str .= "${\($self->object)} " if $self->object;
    $str    .= ($self->text || 'Died');
    return $str;
}

sub to_string {
    my $self = shift;
    $self->stringify;
}

1;
__END__

=head1 NAME

Test::Unit::Exception - unit testing framework exception class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to communicate the result of
assertions, which will throw an instance of a subclass of this class
in case of errors or failures.

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as
Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

Thanks for patches go to:
Matthew Astley.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assert>

=item *

L<Test::Unit::ExceptionError>

=item *

L<Test::Unit::ExceptionFailure>

=back

=cut
