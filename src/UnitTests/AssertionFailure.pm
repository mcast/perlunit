# AssertionFailure.pm
#
#
# MODIFICATION NOTES: See bottom of file.

# Copyright (c) 1999 Katharine Lindner
# This module is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

# IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
# SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF
# THIS CODE, EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#
# THE AUTHOR SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE.  THE CODE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
# AND THERE IS NO OBLIGATION WHATSOEVER TO PROVIDE MAINTENANCE,
# SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

package UnitTests::AssertionFailure;

require 5.003;

use Carp;
use UnitTests::AssertionFailure;
require Exporter;
@ISA         = qw( Exporter);
@EXPORT      = qw();
## POD-formatted documentation

=head1 NAME

UnitTests::AssertionFailure - bioperl test failure object

=head1 SYNOPSIS

=head2 Object Creation

 $assertion_failure = UnitTests::AssertionFailure->new();
=cut
=head2 new

 Title     : new
 Usage     : $assertion_failure = UnitTests::AssertionFailure->new(
                 $message, $line, $file );
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::AssertionFailure
 Argument  :


=cut

#-----------------------------------------------------------------------



sub new()
{
    my ( $class, $message, $line, $file ) = @_;
    my $self = {};
    bless $self, ref( $class ) || $class;
    $self->{ 'message' } = $message;
    $self->{ 'line' } = $line;
    $self->{ 'file' } = $file;
    return $self;
}

=head2 print_message

 Title     : print_message
 Usage     : print_message
           : print_message( $file_handle )
 Function  : Print a failure message
           :
 Returns   :
 Argument  : File handle

=cut

sub print_message
{
    my ( $self, $fh ) = @_;




    if( !$fh ) {
        $fh = *STDOUT;
    }
    printf $fh "%s line number is %d file is %s",  $self->{ 'message' },
        $self->{ 'line' }, $self->{ 'file' };
    print $fh "\n";
}

1;
__END__
