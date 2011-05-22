
=head2 XXXX

A <code>TestResult</code> collects the results of executing
a test case. It is an instance of the Collecting Parameter pattern.
The test framework distinguishes between <i>failures</i> and <i>errors</i>.
A failure is anticipated and checked for with assertions. Errors are
unanticipated problems like an <code>ArrayIndexOutOfBoundsException</code>.

sees:

=over 4

=item *

Test

=back

=cut

package junit::framework::TestResult;
use Object;
use vars qw(@ISA);
@ISA=qw(Object);

=head2 XXXX

Adds an error to the list of errors. The passed in exception
caused the error.

=cut

sub addError {
}

=head2 XXXX

Adds a failure to the list of failures. The passed in exception
caused the failure.

=cut

sub addFailure {
}

=head2 XXXX

Registers a TestListener

=cut

sub addListener {
}

=head2 XXXX

Returns a copy of the listeners.

=cut

sub cloneListeners {
}

=head2 XXXX

Informs the result that a test was completed.

=cut

sub endTest {
}

=head2 XXXX

Gets the number of detected errors.

=cut

sub errorCount {
}

=head2 XXXX

Returns an Enumeration for the errors

=cut

sub errors {
}

=head2 XXXX

Gets the number of detected failures.

=cut

sub failureCount {
}

=head2 XXXX

Returns an Enumeration for the failures

=cut

sub failures {
}

=head2 XXXX

Runs a TestCase.

=cut

sub run {
}

=head2 XXXX

Gets the number of run tests.

=cut

sub runCount {
}

=head2 XXXX

Runs a TestCase.

=cut

sub runProtected {
}

=head2 XXXX

Gets the number of run tests.
deprecateds:

=over 4

=item *

use <code>runCount</code> instead

=back

=cut

sub runTests {
}

=head2 XXXX

Checks whether the test run should stop

=cut

sub shouldStop {
}

=head2 XXXX

Informs the result that a test will be started.

=cut

sub startTest {
}

=head2 XXXX

Marks that the test run should stop.

=cut

sub stop {
}

=head2 XXXX

Gets the number of detected errors.
deprecateds:

=over 4

=item *

use <code>errorCount</code> instead

=back

=cut

sub testErrors {
}

=head2 XXXX

Gets the number of detected failures.
deprecateds:

=over 4

=item *

use <code>failureCount</code> instead

=back

=cut

sub testFailures {
}

=head2 XXXX

Returns whether the entire test was successful or not.

=cut

sub wasSuccessful {
}
