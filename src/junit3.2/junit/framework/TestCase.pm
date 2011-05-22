
=head2 XXXX

A test case defines the fixture to run multiple tests. To define a test case<br>
1) implement a subclass of TestCase<br>
2) define instance variables that store the state of the fixture<br>
3) initialize the fixture state by overriding <code>setUp</code><br>
4) clean-up after a test by overriding <code>tearDown</code>.<br>
Each test runs in its own fixture so there
can be no side effects among test runs.
Here is an example:
<pre>
public class MathTest extends TestCase {
protected double fValue1;
protected double fValue2;

public MathTest(String name) {
super(name);
}

protected void setUp() {
fValue1= 2.0;
fValue2= 3.0;
}
}
</pre>

For each test implement a method which interacts
with the fixture. Verify the expected results with assertions specified
by calling <code>assert</code> with a boolean.
<pre>
protected void testAdd() {
double result= fValue1 + fValue2;
assert(result == 5.0);
}
</pre>
Once the methods are defined you can run them. The framework supports
both a static type safe and more dynamic way to run a test.
In the static way you override the runTest method and define the method to
be invoked. A convenient way to do so is with an anonymous inner class.
<pre>
Test test= new MathTest("add") {
public void runTest() {
testAdd();
}
};
test.run();
</pre>
The dynamic way uses reflection to implement <code>runTest</code>. It dynamically finds
and invokes a method.
In this case the name of the test case has to correspond to the test method
to be run.
<pre>
Test= new MathTest("testAdd");
test.run();
</pre>
The tests to be run can be collected into a TestSuite. JUnit provides
different <i>test runners</i> which can run a test suite and collect the results.
A test runner either expects a static method <code>suite</code> as the entry
point to get a test to run or it will extract the suite automatically.
<pre>
public static Test suite() {
suite.addTest(new MathTest("testAdd"));
suite.addTest(new MathTest("testDivideByZero"));
return suite;
}
</pre>
sees:

=over 4

=item *

TestResult

=item *

TestSuite

=back

=cut

package junit::framework::TestCase;
use Assert;
use vars qw(@ISA);
@ISA=qw(Assert);

=head2 XXXX

the name of the test case

=cut

private final String fName;

=head2 XXXX

Constructs a test case with the given name.

=cut

sub TestCase {
}

=head2 XXXX

Counts the number of test cases executed by run(TestResult result).

=cut

sub countTestCases {
}

=head2 XXXX

Creates a default TestResult object

sees:

=over 4

=item *

TestResult

=back

=cut

sub createResult {
}

=head2 XXXX

Gets the name of the test case.

=cut

sub name {
}

=head2 XXXX

A convenience method to run this test, collecting the results with a
default TestResult object.

sees:

=over 4

=item *

TestResult

=back

=cut

sub run {
}

=head2 XXXX

Runs the test case and collects the results in TestResult.

=cut

sub run {
}

=head2 XXXX

Runs the bare test sequence.
exceptions:

=over 4

=item *

Throwable if any exception is thrown

=back

=cut

sub runBare {
}

=head2 XXXX

Override to run the test and assert its state.
exceptions:

=over 4

=item *

Throwable if any exception is thrown

=back

=cut

sub runTest {
}

=head2 XXXX

Sets up the fixture, for example, open a network connection.
This method is called before a test is executed.

=cut

sub setUp {
}

=head2 XXXX

Tears down the fixture, for example, close a network connection.
This method is called after a test is executed.

=cut

sub tearDown {
}

=head2 XXXX

Returns a string representation of the test case

=cut

sub toString {
}
