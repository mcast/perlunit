# UnitTest.pm
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

package UnitTests::UnitTest;

require 5.003;

use Carp;
use Devel::Symdump;
require Exporter;
@EXPORT      = qw();
## POD-formatted documentation

=head1 NAME

UnitTest - bioperl test object

=head1 SYNOPSIS

=head2 Object Creation

 $unit_test = UnitTests::UnitTest->new;
=cut
=head2 new

 Title     : new
 Usage     : $unit_test = UnitTest->new();
 Function  : The constructor for this class, returns a new object.
 Example   : See usage
 Returns   : UnitTest object
 Argument  :


=cut

#-----------------------------------------------------------------------


=head2 ## Internal methods ##

=cut

sub new()
{
    my $class = shift;
    my $self = {};
    bless $self, ref( $class ) || $class;
    $self;
}
=head2 run

 Title     : run()
 Usage     : n/a, abstract function
 Function  : Runs the test cases
           :
 Returns   : test result
 Argument  : none

=cut
sub run()
{
}
=head2 count_test_cases

 Title     : count_test_cases()
 Usage     : n/a, abstract function
 Function  : Returns the number of test cases
           :
 Returns   : number of test cases
 Argument  : none

=cut
sub count_test_cases()
{}
1;
__END__
