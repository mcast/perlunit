# AlwaysPassTestCase.pm
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

package UnitTests::AlwaysPassTestCase;

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

UnitTests::AlwaysPassTestCase -

=head1 SYNOPSIS

=head2 Object Creation

 $always_pass_test_case = UnitTests::AlwaysPassTestCase->new();
=cut
=head2 new

 Title     : new
 Usage     : $always_pass_test_case = UnitTests::AlwaysPassTestCase->new();
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::AlwaysPassTestCase object
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

    my $a = 1;

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

    my $a = 2;
    my $b = 2;

    return ( $self->assert_equals( \$a, \$b, __LINE__, __FILE__ ) );
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

    my $a = 9;
    my $b = 9;

    return ( $self->assert_equals( \\\$a, \\\$b, __LINE__, __FILE__ ) );
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

    my @a = ( 'ruby', 'diamond', [ 'pearl', 'emerald', 'topaz' ], 'sapphire' );
    my @b = ( 'ruby', 'diamond', [ 'pearl', 'emerald', 'topaz' ], 'sapphire' );

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

    $gem = 'diamond';
    $jewel = 'diamond';
    my %a = ( red => [ 'ruby', 'garnet' ], green => 'emerald', blue => 'sapphire',
        clear => \$gem );
    my %b = ( red => [ 'ruby', 'garnet' ], green => 'emerald', blue => 'sapphire',
        clear => \$jewel );

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

    my $text = "gacttta";
    my $pattern = "\^[gact]*\$";

    return ( $self->assert_matches( $test, $pattern, __LINE__, __FILE__ ) );
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

    my $results = UnitTests::UnitTestResults->new( "alwayspass" );
    my $suite = UnitTests::UnitTestSuite->new( "alwayspass" );
    $suite->build_suite( $self );
    $suite->run( $results );
#    open  $fh, ">unit.log";
    $results->print_failures( $fh );
#    close $fh;
}
1;
__END__
