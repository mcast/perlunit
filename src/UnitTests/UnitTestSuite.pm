# UnitTestSuite.pm
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

package UnitTests::UnitTestSuite;

require 5.003;

use Carp;
use UnitTests::AssertionFailure;
use UnitTests::UnitTestResults;
use UnitTests::UnitTest;
use UnitTests::UnitTestCaller;
use Devel::Symdump;
require Exporter;
@ISA         = qw(UnitTests::UnitTest Exporter);
@EXPORT      = qw();
## POD-formatted documentation

=head1 NAME

UnitTests::UnitTestSuite -

=head1 SYNOPSIS

 $unit_test_suite = UnitTests::UnitTestCase->new( "testsuite" );
=cut
=head2 new

 Title     : new
 Usage     : $unit_test_suite = UnitTests::UnitTestSuite->new( "suite" );
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::UnitTestSuite object
 Argument  :


=cut

#-----------------------------------------------------------------------



sub new
{
    my ( $class, $name ) = @_;
    my $self = {};
    bless $self, ref( $class ) || $class;
    $self->{ 'name' } = $name;
    $self->{ '_suite' } = {};
    return $self;
}

=head2 add_test

 Title     : add_test()
 Usage     : add_test( $caller )
 Function  : Add a test to the suite
           :
 Returns   :
 Argument  : test caller

=cut

sub add_test
{
    my ( $self, $caller ) = @_;
    my $name;




    $name = $caller->name();
    if( $name !~ /^test_\S+$/ ) {
        croak "test name must start with \"test\"";
    }
    if( $self->{ '_suite' } { $name } ) {
        carp "entry already exists";
    }
    $self->{ '_suite' }{ $name } = $caller;
}

=head2 build_custom_suite

 Title     : build_custom_suite
 Usage     : build_custom_suite( $test_module, $cases );
 Function  : Build a suite of test cases.
           :
 Returns   :
 Argument  : $test_module, $cases

=cut

sub build_custom_suite
{

    my ( $self, $module, $cases ) = @_;
    my $name;
    my $sym_dump;
    my $case;
    my $pack;
    my $caller;



    $pack = ref( $module );
    $sym_dump = Devel::Symdump->new( ( $pack ) );
    my %packages = %{ $sym_dump->{ RESULT }{ $pack }{ FUNCTIONS } };
    foreach $case ( @$cases )
    {
	if( $case =~ /^test_\S+$/ ) {
            if( { %packages }->{ $case } ) {
                $caller = UnitTests::UnitTestCaller->new( "$case", $module );
                $self->add_test( $caller );
            }
        }
    }

}

=head2 build_suite

 Title     : build_suite
 Usage     : build_suite( $test_module );
 Function  : Build a suite of test cases.
           :
 Returns   :
 Argument  : $test_module

=cut

sub build_suite
{

    my ( $self, $module ) = @_;
    my $name;
    my $sym_dump;
    my $function;
    my $pack;
    my $caller;



    $pack = ref( $module );
    $sym_dump = Devel::Symdump->new( ( $pack ) );
    my %packages = %{ $sym_dump->{ RESULT }{ $pack }{ FUNCTIONS } };
    foreach $function ( keys %packages )
    {
	if( $function =~ /^test_\S+$/ ) {
            $caller = UnitTests::UnitTestCaller->new( "$function", $module );
            $self->add_test( $caller );
        }
    }

}

=head2 run

 Title     : run()
 Usage     : run( $results )
 Function  : Run the suite of tests
           :
 Returns   :
 Argument  : Test results

=cut

sub run
{
    my ( $self, $results ) = @_;



    foreach $name ( keys %{ $self->{ '_suite' } } ) {
        print "$name\n";
	$self->{ '_suite' }{ $name }->run( $results )
    }
}
1;
__END__




