
=head2 XXXX

A <code>TestSuite</code> is a <code>Composite</code> of Tests.
It runs a collection of test cases. Here is an example using
the dynamic test definition.
<pre>
TestSuite suite= new TestSuite();
suite.addTest(new MathTest("testAdd"));
suite.addTest(new MathTest("testDivideByZero"));
</pre>
Alternatively, a TestSuite can extract the tests to be run automatically.
To do so you pass the class of your TestCase class to the
TestSuite constructor.
<pre>
TestSuite suite= new TestSuite(MathTest.class);
</pre>
This constructor creates a suite with all the methods
starting with "test" that take no arguments.

sees:

=over 4

=item *

Test

=back

=cut

package junit::framework::TestSuite;
use Test;
use vars qw(@ISA);
@ISA=qw(Test);

=head2 XXXX

Constructs an empty TestSuite.

=cut

sub TestSuite {
}

=head2 XXXX

Constructs a TestSuite from the given class. Adds all the methods
starting with "test" as test cases to the suite.
Parts of this method was written at 2337 meters in the Hüffihütte,
Kanton Uri

=cut

sub TestSuite {
}

=head2 XXXX

Constructs an empty TestSuite.

=cut

sub TestSuite {
}

=head2 XXXX

Adds a test to the suite.

=cut

sub addTest {
}

=head2 XXXX

Counts the number of test cases that will be run by this test.

=cut

sub countTestCases {
}

=head2 XXXX

Gets a constructor which takes a single String as
its argument.

=cut

sub getConstructor {
}

=head2 XXXX


=cut

sub isPublicTestMethod {
}

=head2 XXXX


=cut

sub isTestMethod {
}

=head2 XXXX

Runs the tests and collects their result in a TestResult.

=cut

sub run {
}

=head2 XXXX

Returns the test at the given index

=cut

sub testAt {
}

=head2 XXXX

Returns the number of tests in this suite

=cut

sub testCount {
}

=head2 XXXX

Returns the tests as an enumeration

=cut

sub tests {
}

=head2 XXXX


=cut

sub toString {
}

=head2 XXXX

Returns a test which will fail and log a warning message.

=cut

sub warning {
}
