# UnitTestResults.pm
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

package UnitTests::UnitTestResults;

require 5.003;

use Carp;
use UnitTests::AssertionFailure;
require Exporter;
@ISA         = qw( Exporter);
@EXPORT      = qw();
## POD-formatted documentation

=head1 NAME

UnitTests::UnitTestResults - bioperl test results object

=head1 SYNOPSIS

=head2 Object initialization

UnitTests::UnitTestResults->_initialize();
=cut
=head2 _initialize

 Title     : _initialize
 Usage     : UnitTests::UnitTestResults->_initialize();
 Function  : initialize a new object.
 Example   : See usage
 Returns   :
 Argument  :


=cut

sub _initialize
{

    my $self = shift;
    $self->{ '_failures' } = [];
    $self->{ '_errors' } = [];
    $self->{ '_warnings' } = [];
}

=head2 Object Creation

 $unit_test_results = UnitTests::UnitTestResults->new();
=cut
=head2 new

 Title     : new
 Usage     : $unit_test_results = UnitTests::UnitTestResults->new();
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::UnitTestResults object
 Argument  :


=cut

#-----------------------------------------------------------------------



sub new
{
    my $class = shift;
    my $self = {};
    bless $self, ref( $class ) || $class;
    $self->_initialize();
    return $self;
}

=head2 get_failures

 Title     : get_failures()
 Usage     :
 Function  : Return the list of assertion failures
           :
 Returns   : List of failures
 Argument  : None

=cut

sub get_failures
{
    my $self = shift;




 #may require disambiguation
    return @{$self->{ '_failures' } };
}

=head2 get_errors

 Title     : get_errors()
 Usage     :
 Function  : Return the list of errors
           :
 Returns   : List of errors
 Argument  : None

=cut

sub get_errors
{
    my $self = shift;




 #may require disambiguation
    return @{$self->{ '_errors' } };
}

=head2 get_warnings

 Title     : get_warnings()
 Usage     :
 Function  : Return the list of warnings
           :
 Returns   : List of warnings
 Argument  : None

=cut

sub get_warnings
{
    my $self = shift;




 #may require disambiguation
    return @{$self->{ '_warnings' } };
}

=head2 count_failures

 Title     : count_failures()
 Usage     :
 Function  : Returns the number of assertion failures
           :
 Returns   : number of failures
 Argument  : none

=cut

sub count_failures
{
    my $self = shift;

    return scalar @{ $self->{ '_failures' } };
}

=head2 count_errors

 Title     : count_errors()
 Usage     :
 Function  : Returns the number of errors
           :
 Returns   : number of errors
 Argument  : none

=cut
sub count_errors
{
    my $self = shift;

    return scalar @{ $self->{ '_errors' }  };
}

=head2 count_warnings

 Title     : count_warnings()
 Usage     :
 Function  : Returns the number of warnings
           :
 Returns   : number of warnings
 Argument  : none

=cut
sub count_warnings
{
    my $self = shift;

    return scalar @{ $self->{'_warnings' } };
}

=head2 add_failure

 Title     : add_failure()
 Usage     :
 Function  : Add a failure to the list of assertion failures
           :
 Returns   :
 Argument  : failure

=cut

sub add_failure
{
    my ( $self, $failure ) = @_;




    push @{ $self->{ '_failures' } }, ( $failure );
}

=head2 add_error

 Title     : add_error()
 Usage     :
 Function  : Add an error to the list of errors
           :
 Returns   :
 Argument  : error

=cut

sub add_error
{
    my ( $self, $error ) = @_;




    push @{ $self->{ '_errors' } }, ( $error );
}

=head2 add_warning

 Title     : add_warning()
 Usage     :
 Function  : Add a warning to the list of warnings
           :
 Returns   :
 Argument  : warning

=cut

sub add_warning
{
    my ( $self, $warning ) = @_;




    push @{ $self->{ '_warnings' } }, ( $warning );
}

=head2 was_successful

 Title     : was_successful()
 Usage     :
 Function  : Returns false if any failures or errors
           :
 Returns   :
 Argument  : none

=cut

sub was_successful
{
    my $self = shift;

    return  !{ $self->count_failures } and  !{ $self->count_errors };
}

=head2 print_failures

 Title     : print_failures()
 Usage     : print_failures
           : print_failures( $file_handle );
 Function  : Prints assertion failure messages
           :
 Returns   :
 Argument  : file handle

=cut
sub print_failures
{
    my ( $self, $fh ) = @_;
    my $failure;

    if( !$fh ) {
        $fh = *STDOUT;
    }
    foreach $failure ( @{ $self->{ '_failures' } } )
    {
        $failure->print_message( $fh );
    }
}
=head2 print_errors

 Title     : print_errors()
 Usage     : print_errors
           : print_errors( $file_handle )
 Function  : Prints error messages
           :
 Returns   :
 Argument  : file handle

=cut
sub print_errors
{
    my ( $self, $fh ) = @_;
    my $error;

    if( !$fh ) {
        $fh = *STDOUT;
    }
    foreach $error ( @{ $self->{'_errors' } } )
    {
        print $fh $error;
        print $fh "\n";
    }
}
=head2 print_warnings

 Title     : print_warnings()
 Usage     : print_warnings
           : print_warnings( $file_handle )
 Function  : Prints warning messages
           :
 Returns   :
 Argument  : file handle

=cut
sub print_warnings
{
    my ( $self, $fh ) = @_;
    my $warning;

    if( !$fh ) {
        $fh = *STDOUT;
    }
    foreach $warning ( @{ $self->{'_warnings' } } )
    {
        print $fh $warning;
        print $fh "\n";
    }
}
1;
__END__
