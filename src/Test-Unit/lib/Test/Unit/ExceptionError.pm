package Test::Unit::ExceptionError;
use strict;
use base qw(Test::Unit::Exception);

1;

=head1 NAME

    Test::Unit::ExceptionError - unit testing framework exception class

=head1 SYNOPSIS

    # this class is not intended to be used directly 

=head1 DESCRIPTION

    This class is used by the framework to communicate the result
    of assertions, which will throw an instance of this class
    in case of errors (that is, syntax errors and the like, not
    failed tests, as these are classified as failures).

=head1 AUTHOR

    Copyright (c) 2000 Christian Lemburg, <lemburg@acm.org>.

    All rights reserved. This program is free software; you can
    redistribute it and/or modify it under the same terms as
    Perl itself.

    Thanks go to the other PerlUnit framework people: 
    Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

    - Test::Unit::Exception
    - Test::Unit::Assert

=cut
