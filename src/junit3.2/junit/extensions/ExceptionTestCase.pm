
=head2 XXXX

A TestCase that expects an Exception of class fExpected to be thrown.
The other way to check that an expected exception is thrown is:
<pre>
try {
shouldThrow();
}
catch (SpecialException e) {
return;
}
fail("Expected SpecialException");
</pre>

To use ExceptionTestCase, create a TestCase like:
<pre>
new ExceptionTestCase("testShouldThrow", SpecialException.class);
</pre>

=cut

package junit::extensions::ExceptionTestCase;
use TestCase;
use vars qw(@ISA);
@ISA=qw(TestCase);

=head2 XXXX

params:

=over 4

=item name

java.lang.String

=item exception

java.lang.Class

=back

=cut

sub ExceptionTestCase {
}

=head2 XXXX

Execute the test method expecting that an Exception of
class fExpected or one of its subclasses will be thrown

=cut

sub runTest {
}
