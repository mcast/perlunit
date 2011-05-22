
=head2 XXXX

The standard test suite loader. It can only load the same class once.

=cut

package junit::util::StandardTestSuiteLoader;
use TestSuiteLoader;
use vars qw(@ISA);
@ISA=qw(TestSuiteLoader);

=head2 XXXX

Uses the system class loader to load the test class

=cut

sub load {
}

=head2 XXXX

Uses the system class loader to load the test class

=cut

sub reload {
}
