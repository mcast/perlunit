
=head2 XXXX

A tree browser for a test suite.

=cut

package junit::swingui::TestBrowser;
use JFrame;
use vars qw(@ISA);
@ISA=qw(JFrame);

=head2 XXXX

A test ended.

=cut

sub endTest {
}

=head2 XXXX

A test started.

=cut

sub startTest {
}

=head2 XXXX

Checks whether the run button should be enabled

=cut

sub checkEnableRun {
}

=head2 XXXX

Returns the TestListener for the TestTreeFrame

=cut

sub getTestListener {
}

=head2 XXXX

Runs the selected test

=cut

sub runSelection {
}

=head2 XXXX

Reloads test tree

=cut

sub reloadTestTree {
}

=head2 XXXX

Shows the test hierarchy starting at the given test

=cut

sub showTestTree {
}
