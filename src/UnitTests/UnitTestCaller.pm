# UnitTestCaller.pm
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

package UnitTests::UnitTestCaller;

require 5.003;

use Carp;
use UnitTests::AssertionFailure;
use UnitTests::UnitTestResults;
use UnitTests::UnitTestCase;
require Exporter;
@ISA         = qw( UnitTests::UnitTestCase Exporter);
@EXPORT      = qw();
## POD-formatted documentation

=head1 NAME

UnitTests::UnitTestCaller - bioperl test caller object

=head1 SYNOPSIS

=head2 new

 Title     : new
 Usage     : $unit_test_caller = UnitTests::UnitTestCaller->new(
           :     "method", $test_object, $method );
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::UnitTestSuite object
 Argument  :


=cut

#-----------------------------------------------------------------------



sub new
{
    my ( $class, $name, $test_object ) = @_;
    if( $name !~ /^test_\S+$/ ) {
        croak "test name must start with \"test\"";
    }
    my $self = {};
    bless $self, ref( $class ) || $class;
    $self->{ '_name' } = $name;
    $self->{ '_test_object' } = $test_object;
    return $self;
}

=head2 name

 Title     : name()
 Usage     :
 Function  : Return the name of the test case
           :
 Returns   : Name of the test case
 Argument  : None

=cut

sub name
{
    my $self = shift;




    return $self->{ '_name' };
}

=head2 run_test

 Title     : run_test()
 Usage     :
 Function  : Run the test case.
           :
 Returns   :
 Argument  : None

=cut

sub run_test
{
    my $self = shift;
    my $test_object;
    my $pack;
    my $name;

    $name = $self->name();
    $test_object = $self->{ '_test_object' };
    $pack = ref( $test_object );
    return ( &{"$pack\::$name"}( $test_object ));
}
1;
__END__

