
=head2 XXXX

A TestSuite loader that can reload classes.

=cut

package junit::util::ReloadingTestSuiteLoader;
use TestSuiteLoader;
use vars qw(@ISA);
@ISA=qw(TestSuiteLoader);
