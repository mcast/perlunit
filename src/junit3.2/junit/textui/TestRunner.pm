
=head2 XXXX

A command line based tool to run tests.
<pre>
java test.textui.TestRunner [-wait] TestCaseClass
</pre>
TestRunner expects the name of a TestCase class as argument.
If this class defines a static <code>suite</code> method it
will be invoked and the returned test is run. Otherwise all
the methods starting with "test" having no arguments are run.
<p>
When the wait command line argument is given TestRunner
waits until the users types RETURN.
<p>
TestRunner prints a trace as the tests are executed followed by a
summary at the end.

=cut

package junit::textui::TestRunner;
use TestListener;
use vars qw(@ISA);
@ISA=qw(TestListener);

=head2 XXXX

This method was created in VisualAge.
params:

=over 4

=item writer

java.io.PrintStream

=back

=cut

sub TestRunner {
}

=head2 XXXX

This method was created in VisualAge.
params:

=over 4

=item writer

java.io.PrintStream

=back

=cut

sub TestRunner {
}

=head2 XXXX

Creates the TestResult to be used for the test run.

=cut

sub createTestResult {
}

=head2 XXXX

main entry point.

=cut

sub main {
}

=head2 XXXX

Prints failures to the standard output

=cut

sub print {
}

=head2 XXXX

Prints the errors to the standard output

=cut

sub printErrors {
}

=head2 XXXX

Prints failures to the standard output

=cut

sub printFailures {
}

=head2 XXXX

Prints the header of the report

=cut

sub printHeader {
}

=head2 XXXX

Runs a suite extracted from a TestCase subclass.

=cut

sub run {
}

=head2 XXXX

Runs a single test and collects its results.
This method can be used to start a test run
from your program.
<pre>
public static void main (String[] args) {
test.textui.TestRunner.run(suite());
}
</pre>

=cut

sub run {
}

=head2 XXXX

Runs a single test and waits until the users
types RETURN.

=cut

sub runAndWait {
}

=head2 XXXX

Starts a test run. Analyzes the command line arguments
and runs the given test suite.

=cut

sub start {
}
