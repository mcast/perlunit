
# UnitTestCase.pm
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

package UnitTests::UnitTestCase;

require 5.003;

use Carp;
use UnitTests::AssertionFailure;
use UnitTests::UnitTestResults;
use UnitTests::UnitTest;
require Exporter;
@ISA         = qw(UnitTests::UnitTest Exporter);
@EXPORT      = qw();



sub _assert_scalar_equals( $$$$$ );
sub _assert_array_equals( $$$$$ );
sub _assert_code_equals( $$$$$ );
sub _assert_hash_equals( $$$$$ );
## POD-formatted documentation

=head1 NAME

UnitTests::UnitTestCase -

=head1 SYNOPSIS

=head2 Object Creation

 $unit_test_case = UnitTests::UnitTestCase->new( "method" );
=cut
=head2 new

 Title     : new
 Usage     : $unit_test_case = UnitTests::UnitTestCase->new( "case" );
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTests::UnitTestCase object
 Argument  :


=cut

#-----------------------------------------------------------------------



sub new
{
    my ( $class, $name ) = @_;
    my $self = {};
    bless $self, ref( $class ) || $class;
    $self->{ '_name' } = $name;
    return $self;
}

=head2 assert_condition

 Title     : assert_condition
 Usage     : assert_condition( $condition, $message, $line, $file )
 Function  : Return failure if the condition is false
           :
 Returns   : Failure
 Argument  :

=cut

sub assert_condition
{
    my ( $self, $condition, $message, $line, $file ) = @_;
    my $failure;




    if( !$condition ) {
        $failure = UnitTests::AssertionFailure->new( $message, $line,
            $file );
    }
    return $failure;
}

=head2 assert_equals

 Title     : assert_equals
 Usage     : assert_equals( $expected, $actual, $line, $file )
 Function  : Return failure if expected does not equal actual
           :
 Returns   : reference to failure object
 Argument  : $expected, $actual, $line, $file

=cut

sub assert_equals( $$$$$ )
{
    my ( $self, $expected, $actual, $line, $file ) = @_;
    my $failure;




    if( ref( $expected ) eq "ARRAY" ) {
	$failure = $self->_assert_array_equals( $expected, $actual, $line,
	    $file );
    }
    elsif( ref( $expected ) eq "CODE" ) {
	$failure = $self->_assert_code_equals( $expected, $actual, $line,
	    $file );
    }
    elsif( ref( $expected ) eq "SCALAR" ) {
        $failure = $self->assert_equals( $$expected, $$actual, $line, $file );
    }
    elsif( ref( $expected ) eq "REF" ) {
        $failure = $self->assert_equals( $$expected, $$actual, $line, $file );
    }
    elsif( not ref( $expected ) ) {
	$failure = $self->_assert_scalar_equals( $expected, $actual, $line,
	    $file );
    }
    elsif( ref( $expected ) ne "GLOB" ) {
	$failure = $self->_assert_hash_equals( $expected, $actual, $line,
	    $file );
    }
    return $failure;
}

=head2 _is_hash_or_object

 Title     : _is_hash_or_object
 Usage     : _is_hash_or_object( $item )
 Function  : Return true if hash or object
           :
 Returns   : true or false
 Argument  : $item

=cut

sub _is_hash_or_object
{

my( $self, $item ) = @_;



    my $typ = ref( $item );
    if(
        ( ref( $item ) eq "SCALAR" ) or
        ( ref( $item ) eq "ARRAY" ) or
        ( ref( $item ) eq "CODE" ) or
        ( ref( $item ) eq "GLOB" )
    ) {
        return 0;
    }
    return 1;
}


=head2 _assert_matches

 Title     : _assert_matches
 Usage     : _assert_matches( $text, $pattern, $line, $file )
 Function  : Return failure if expected does not equal actual
           :
 Returns   : reference to failure object
 Argument  : $text, $pattern, $line, $file

=cut

sub assert_matches( $$$$$ )
{
    use strict 'refs';
    my ( $self, $text, $pattern, $line, $file ) = @_;
    my $failure;
    my $message;




    if( ref( $text ) ) {
        croak( "target must be a scalar" );
    }
    if( $text !~ /$pattern/ ) {
        $message = "text $text does not match pattern $pattern";
	$failure = UnitTests::AssertionFailure->new( $message, $line,
            $file );
    }
    return $failure;
}

=head2 _assert_scalar_equals

 Title     : _assert_scalar_equals
 Usage     : _assert_scalar_equals( $expected, $actual, $line, $file )
 Function  : Return failure if expected does not equal actual
           :
 Returns   : reference to failure object
 Argument  : $expected, $actual, $line, $file

=cut

sub _assert_scalar_equals( $$$$$ )
{
    use strict 'refs';
    my ( $self, $expected, $actual, $line, $file ) = @_;
    my $failure;
    my $message;




    if( ref( $expected ) ) {
        croak( "expected value must be a scalar" );
    }
    if( $expected ne $actual ) {
        $message = "expected $expected actual $actual";
	$failure = UnitTests::AssertionFailure->new( $message, $line,
            $file );
    }
    return $failure;
}

=head2 _assert_code_equals

 Title     : _assert_code_equals
 Usage     : _assert_code_equals( $expected, $actual, $line, $file )
           : subroutine is passed by reference
           : no dereferenceing is performed
 Function  : Return failure if expected does not equal actual
           :
 Returns   : reference to failure object
 Argument  : $expected, $actual, $line, $file

=cut

sub _assert_code_equals( $$$$$ )
{
    my ( $self, $expected, $actual, $line, $file ) = @_;
    my $failure;
    my $message;




    if( ref( $expected ) ne "CODE" ) {
        croak( "expected value must be a subroutine" );
    }
    if( $expected != $actual ) {
        $message = "expected $expected actual $actual";
	$failure = UnitTests::AssertionFailure->new( $message, $line,
            $file );
    }
    return $failure;
}

=head2 _assert_array_equals

 Title     : _assert_array_equals
 Usage     : _assert_array_equals( $expected, $actual, $line, $file )
 Function  : Return failure if expected does not equal actual
           : arrays must be passed by reference
 Returns   : reference to failure object
 Argument  : $expected, $actual, $line, $file

=cut
sub _assert_array_equals( $$$$$ )
{
    my ( $self, $expected, $actual, $line, $file ) = @_;
    my $failure;
    my $message;
    my $expected_length;
    my $actual_length;
    my @actual = @$actual;
    my @expected = @$expected;
    my $i;





    if( ref( $expected ) ne "ARRAY" ) {
        croak( "expected value must be an array" );
    }
    if( ref( $actual ) ne "ARRAY" ) {
        croak( "actual value must be an array" );
    }
    if( $#expected != $#actual ) {
        $expected_length = $#expected + 1;
        $actual_length = $#actual + 1;
	$message = "expected length $expected_length actual length $actual_length";
	$failure = UnitTests::AssertionFailure->new( $message, $line,
            $file );
        return $failure;
    }
    for $i ( 0 .. $#actual ) {
	$failure = $self->assert_equals( $expected[ $i ],
            $actual[ $i ], $line, $file );
	if( $failure ) {
            return $failure;
        }
    }
    return $failure;
}

=head2 _assert_hash_equals

 Title     : _assert_hash_equals
 Usage     : _assert_hash_equals( $expected, $actual, $line, $file )
 Function  : Return failure if expected does not equal actual
           : hashes must be passed by reference
 Returns   : reference to failure object
 Argument  : $expected, $actual, $line, $file

=cut
sub _assert_hash_equals( $$$$$ )
{
    my ( $self, $expected, $actual, $line, $file ) = @_;
    my $failure;
    my $message;
    my $expected_length;
    my $actual_length;
    my %expected = %$expected;
    my %actual = %$actual;
    my $key;





    if( !$self-> _is_hash_or_object( $expected ) ) {
        croak( "expected value must be a hash or object" );
    }
    if( !$self-> _is_hash_or_object( $actual ) ){
        croak( "expected value must be a hash or object" );
    }
    $expected_length = keys( %expected );
    $actual_length = keys( %actual );
    if( $expected_length != $actual_length ) {
	$message = "expected length $expected_length actual length $actual_length";
	$failure = UnitTests::AssertionFailure->new( $message, $line,
            $file );
        return $failure;
    }
    for $key ( keys %expected ) {
	$failure = $self->assert_equals( $expected{ $key },
            $actual{ $key }, $line, $file );
	if( $failure ) {
            return $failure;
        }
    }
    return $failure;
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

=head2 setup

 Title     : setup()
 Usage     :
 Function  : Prepare for a test case
           :
 Returns   :
 Argument  : None

=cut

sub setup
{
    my $self = shift;
}

=head2 tear_down

 Title     : tear_down()
 Usage     :
 Function  : Clean up after test case
           :
 Returns   :
 Argument  : None

=cut

sub tear_down
{
    my $self = shift;
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
    my $failure;
    return $failure;
}

=head2 build_suite

 Title     : build_suite
 Usage     : build_suite
 Function  : Build a suite of test cases.
           :
 Returns   :
 Argument  : result

=head2 run

 Title     : run
 Usage     : run( TestResults *test_results )
 Function  : Run the test case.
           :
 Returns   :
 Argument  : result

=cut
sub run
{
    my(  $self, $results )  = @_;
    $self->setup();
    my $failure = $self->run_test();
    if( $failure ) {
        $results->add_failure( $failure );
    }
    $self->tear_down();



}
1;
__END__
