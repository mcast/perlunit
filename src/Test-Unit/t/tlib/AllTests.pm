package AllTests;

use Test::Unit::TestRunner;
use Test::Unit::TestSuite;
use SuiteTest;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub suite {
    my $class = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Framework Tests");
    $suite->add_test(Test::Unit::TestSuite->new("TestTest"));
    $suite->add_test(SuiteTest->suite());
    $suite->add_test(Test::Unit::TestSuite->new("ListenerTest"));
    $suite->add_test(Test::Unit::TestSuite->new("BadSuitesTest"));
    return $suite;
}

1;
__END__


=head1 NAME

AllTests - unit testing framework self tests

=head1 SYNOPSIS

    # command line style use

    perl TestRunner.pl AllTests

    # GUI style use

    perl TkTestRunner.pl AllTests


=head1 DESCRIPTION

This class is used by the unit testing framework to encapsulate all
the self tests of the framework.

=head1 AUTHOR

Framework JUnit authored by Kent Beck and Erich Gamma.

Ported from Java to Perl by Christian Lemburg.

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::TestSuite>

=back

=cut
