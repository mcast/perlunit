
=head2 XXXX

A <code>TestFailure</code> collects a failed test together with
the caught exception.
sees:

=over 4

=item *

TestResult

=back

=cut

package junit::framework::TestFailure;
use Object;
use vars qw(@ISA);
@ISA=qw(Object);

=head2 XXXX

Constructs a TestFailure with the given test and exception.

=cut

sub TestFailure {
}

=head2 XXXX

Gets the failed test.

=cut

sub failedTest {
}

=head2 XXXX

Gets the thrown exception.

=cut

sub thrownException {
}

=head2 XXXX

Returns a short description of the failure.

=cut

sub toString {
}
