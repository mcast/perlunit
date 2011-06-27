package RepeatableTests;

use strict;

use base qw(Test::Unit::TestSuite);

sub name { 'All tests which can be repeated cleanly' }

# Build the suite this way so other tests can also use our tests list
sub include_tests { qw( AssertTest InheritedSuite::Simple InheritedSuite::TestNames InheritedSuite::OverrideNew TestTest ListenerTest RunnerTest WillDie  ) }

=head1 NAME

RepeatableTests - all selftests which can be reloaded

=head1 DESCRIPTION

This is a L<Test::Unit::TestSuite> containing many of the selftests.
It is used by further tests which need "some tests to run".

The difference from L<AllTests> is that it does not contain
L<BadSuitesTest> (L<BadSuite::BadUse> or L<BadSuite::SyntaxError>),
which leave cruft in the symbol table which prevent reloading, or
L<SuiteTest> which generates warnings on repeated use.

Those issues could be fixed or plastered over, but this is pragmatic
for L<t/speed.t> and L<t/debug.t> .

Also this suite may not contain everything it could, if I missed
something.

=cut

1;
