
=head2 XXXX

A tree model for a Test.

=cut

package junit::swingui::TestTreeModel;
use TreeModel;
use vars qw(@ISA);
@ISA=qw(TreeModel);

=head2 XXXX

Constructs a tree model with the given test as its root.

=cut

sub TestTreeModel {
}

=head2 XXXX

adds a TreeModelListener

=cut

sub addTreeModelListener {
}

=head2 XXXX

Removes a TestModelListener

=cut

sub removeTreeModelListener {
}

=head2 XXXX

Finds the path to a test. Returns the index of the test in its
parent test suite.

=cut

sub findTest {
}

=head2 XXXX

Fires a node changed event

=cut

sub fireNodeChanged {
}

=head2 XXXX

Gets the test at the given index

=cut

sub getChild {
}

=head2 XXXX

Gets the number of tests.

=cut

sub getChildCount {
}

=head2 XXXX

Gets the index of a test in a test suite

=cut

sub getIndexOfChild {
}

=head2 XXXX

Returns the root of the tree

=cut

sub getRoot {
}

=head2 XXXX

Tests if the test is a leaf.

=cut

sub isLeaf {
}

=head2 XXXX

Tests if the node is a TestSuite.

=cut

sub isTestSuite {
}

=head2 XXXX

Called when the value of the model object was changed in the view

=cut

sub valueForPathChanged {
}

=head2 XXXX

Remembers a test failure

=cut

sub addFailure {
}

=head2 XXXX

Remembers a test error

=cut

sub addError {
}

=head2 XXXX

Remembers that a test was run

=cut

sub addRunTest {
}

=head2 XXXX

Returns whether a test was run

=cut

sub wasRun {
}

=head2 XXXX

Tests whether a test was an error

=cut

sub isError {
}

=head2 XXXX

Tests whether a test was a failure

=cut

sub isFailure {
}

=head2 XXXX

Resets the test results

=cut

sub resetResults {
}
