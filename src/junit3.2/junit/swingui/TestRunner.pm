
=head2 XXXX

A simple user interface to run tests.
Enter the name of a class with a suite method which should return
the tests to be run.
<pre>
Synopsis: java java.swingui.TestRunner [TestCase]
</pre>
TestRunner takes as an optional argument the name of the testcase class to be run.

=cut

package junit::swingui::TestRunner;
use Object;
use vars qw(@ISA);
@ISA=qw(Object);

=head2 XXXX

Creates the JUnit menu. Clients override this
method to add additional menu items.

=cut

sub createJUnitMenu {
}

=head2 XXXX

Hook to plug in a UI component on the run line

=cut

sub createRunExtension {
}

=head2 XXXX

Loads the named test suite and returns it. Errors during loading
are reported on the status line.

=cut

sub getTest {
}

=head2 XXXX

main entrypoint

=cut

sub main {
}

=head2 XXXX

runs a suite.
deprecateds:

=over 4

=item *

use runSuite() instead

=back

=cut

sub run {
}

=head2 XXXX

Starts the TestRunner

=cut

sub start {
}

=head2 XXXX

Wait until all the events are processed in the event thread

=cut

sub synchUI {
}

=head2 XXXX

Terminates the TestRunner

=cut

sub terminate {
}
