
=head2 XXXX

A Decorator to set up and tear down additional fixture state.
Subclass TestSetup and insert it into your tests when you want
to set up additional state once before the tests are run.

=cut

package junit::extensions::TestSetup;
use TestDecorator;
use vars qw(@ISA);
@ISA=qw(TestDecorator);

=head2 XXXX

Sets up the fixture. Override to set up additional fixture
state.

=cut

sub setUp {
}

=head2 XXXX

Tears down the fixture. Override to tear down the additional
fixture state.

=cut

sub tearDown {
}
