# NeverPassTestCase.pm
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

package UnitTests::NeverPassTestCase;

require 5.003;

use Carp;
use UnitTests::AssertionFailure;
use UnitTests::UnitTestResults;
use UnitTests::UnitTest;
use UnitTests::UnitTestCase;
use UnitTests::UnitTestCaller;
use UnitTests::UnitTestSuite;
require Exporter;
@ISA         = qw(UnitTests::UnitTestCase Exporter);
@EXPORT      = qw();
## POD-formatted documentation

=head1 NAME

UnitTests::NeverPassTestCase -

=head1 SYNOPSIS

=head2 Object Creation

 $never_pass_test_case = UnitTests::NeverPassTestCase->new();
=cut
=head2 new

 Title     : new
 Usage     : $never_pass_test_case = UnitTests::NeverPassTestCase->new();
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::NeverPassTestCase object
 Argument  :


=cut

#-----------------------------------------------------------------------



sub new
{
    my $class = shift;
    my $self = {};
    bless $self, ref( $class ) || $class;
    return $self;
}

=head2 test_condition

 Title     : test_condition()
 Usage     :
 Function  : Test for a condition
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_condition
{
    my $self = shift;
    print "running test condition";

    my $a = 0;

    return ( $self->assert_condition( $a, "failed condition", __LINE__, __FILE__ ) );
}

=head2 test_scalar_equals

 Title     : test_scalar_equals()
 Usage     :
 Function  : Test for an equality between two scalars
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_scalar_equals
{
    my $self = shift;

    my $a = 0;
    my $b = 1;

    return ( $self->assert_equals( $a, $b, __LINE__, __FILE__ ) );
}

=head2 test_indirect_equals

 Title     : test_indirect_equals()
 Usage     :
 Function  : Test for an equality between two scalars passed by reference
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_indirect_equals
{
    my $self = shift;

    my $a = 8;
    my $b = 7;

    return ( $self->assert_equals( \\\$a, \\\$b, __LINE__, __FILE__ ) );
}

=head2 test_array_actual_too_big

 Title     : test_array_actual_too_big()
 Usage     :
 Function  : Test for an equal length between two arrays
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_array_actual_too_big
{
    my $self = shift;

    my @a = ( 'ruby', 'diamond', 'emerald' );
    my @b = ( 'ruby', 'diamond', 'emerald', 'sapphire' );

    return ( $self->assert_equals( \@a, \@b, __LINE__, __FILE__ ) );
}

=head2 test_array_actual_too_small

 Title     : test_array_actual_too_small()
 Usage     :
 Function  : Test for an equal length between two arrays
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_array_actual_too_small
{
    my $self = shift;

    my @a = ( 'ruby', 'diamond', 'emerald', 'sapphire' );
    my @b = ( 'ruby', 'diamond', 'emerald' );

    return ( $self->assert_equals( \@a, \@b, __LINE__, __FILE__ ) );
}

=head2 test_hash_length_equals

 Title     : test_hash_length_equals()
 Usage     :
 Function  : Test for an equal length between two hashes
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_hash_length_equals
{
    my $self = shift;


    my %a = ( red => 'ruby', green => 'emerald', blue => 'sapphire',
        clear => 'diamond' );
    my %b = ( red => 'ruby', green => 'emerald', blue => 'sapphire' );
    return ( $self->assert_equals( \%a, \%b, __LINE__, __FILE__ ) );
}

=head2 test_array_equals

 Title     : test_array_equals()
 Usage     :
 Function  : Test for an equality between two arrays
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_array_equals
{
    my $self = shift;

    my @a = ( 'ruby', 'diamond', [ 'pearl', 'emerald', 'garnet' ], 'sapphire' );
    my @b = ( 'ruby', 'zircon', [ 'pearl', 'emerald', 'garnet' ], 'sapphire' );

    return ( $self->assert_equals( \@a, \@b, __LINE__, __FILE__ ) );
}

=head2 test_hash_equals

 Title     : test_array_equals()
 Usage     :
 Function  : Test for an equality between two arrays
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_hash_equals
{
    my $self = shift;

    my %a = ( red => 'ruby', green => 'emerald', blue => 'sapphire' );
    my %b = ( red => 'garnet', green => 'emerald', blue => 'sapphire' );

    return ( $self->assert_equals( \%a, \%b, __LINE__, __FILE__ ) );
}

=head2 test_match

 Title     : test_match()
 Usage     :
 Function  : Test a string against a pattern
           :
 Returns   : Results of the test
 Argument  : None

=cut

sub test_match
{
    my $self = shift;

    my $text = "actvu";
    my $pattern = "\^[gact]*\$";

    return ( $self->assert_matches( $text, $pattern, __LINE__, __FILE__ ) );
}

=head2 invoke_suite

 Title     : invoke_suite()
 Usage     :
 Function  : create a suite of tests
           :
 Returns   :
 Argument  : None

=cut

sub invoke_suite
{
    my $self = shift;
    my $fh = *STDOUT;

    my $results = UnitTests::UnitTestResults->new( "neverpass" );
    my $suite = UnitTests::UnitTestSuite->new( "neverpass" );
    $suite->build_suite( $self );
    $suite->run( $results );
#    open  $fh, ">unit.log";
    $results->print_failures( $fh );
#    close $fh;
}
1;
__END__
