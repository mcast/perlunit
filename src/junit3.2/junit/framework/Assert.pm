
=head2 XXXX

A set of assert methods.

=cut

package junit::framework::Assert;

=head2 XXXX

Protect constructor since it is a static only class

=cut

sub Assert {
}

=head2 XXXX

Asserts that a condition is true. If it isn't it throws
an AssertionFailedError with the given message.

=cut

sub assert {
}

=head2 XXXX

Asserts that a condition is true. If it isn't it throws
an AssertionFailedError.

=cut

sub assert {
}

=head2 XXXX

Asserts that two doubles are equal.
params:

=over 4

=item expected

the expected value of an object

=item actual

the actual value of an object

=item delta

tolerated delta

=back

=cut

sub assertEquals {
}

=head2 XXXX

Asserts that two longs are equal.
params:

=over 4

=item expected

the expected value of an object

=item actual

the actual value of an object

=back

=cut

sub assertEquals {
}

=head2 XXXX

Asserts that two objects are equal. If they are not
an AssertionFailedError is thrown.
params:

=over 4

=item expected

the expected value of an object

=item actual

the actual value of an object

=back

=cut

sub assertEquals {
}

=head2 XXXX

Asserts that two doubles are equal.
params:

=over 4

=item message

the detail message for this assertion

=item expected

the expected value of an object

=item actual

the actual value of an object

=item delta

tolerated delta

=back

=cut

sub assertEquals {
}

=head2 XXXX

Asserts that two longs are equal.
params:

=over 4

=item message

the detail message for this assertion

=item expected

the expected value of an object

=item actual

the actual value of an object

=back

=cut

sub assertEquals {
}

=head2 XXXX

Asserts that two objects are equal. If they are not
an AssertionFailedError is thrown.
params:

=over 4

=item message

the detail message for this assertion

=item expected

the expected value of an object

=item actual

the actual value of an object

=back

=cut

sub assertEquals {
}

=head2 XXXX

Asserts that an object isn't null.

=cut

sub assertNotNull {
}

=head2 XXXX

Asserts that an object isn't null.

=cut

sub assertNotNull {
}

=head2 XXXX

Asserts that an object is null.

=cut

sub assertNull {
}

=head2 XXXX

Asserts that an object is null.

=cut

sub assertNull {
}

=head2 XXXX

Asserts that two objects refer to the same object. If they are not
the same an AssertionFailedError is thrown.
params:

=over 4

=item expected

the expected value of an object

=item actual

the actual value of an object

=back

=cut

sub assertSame {
}

=head2 XXXX

Asserts that two objects refer to the same object. If they are not
an AssertionFailedError is thrown.
params:

=over 4

=item message

the detail message for this assertion

=item expected

the expected value of an object

=item actual

the actual value of an object

=back

=cut

sub assertSame {
}

=head2 XXXX

Fails a test with no message.

=cut

sub fail {
}

=head2 XXXX

Fails a test with the given message.

=cut

sub fail {
}
