
=head2 XXXX

A custom class loader which enables the reloading
of classes for each test run. The class loader
can be configured with a list of package paths that
should be excluded from loading. The loading
of these packages is delegated to the system class
loader. They will be shared across test runs.
<p>
The list of excluded package paths is specified in
a properties file "excluded.properties" that is located in
the same place as the TestCaseClassLoader class.
<p>
<b>Known limitation:</b> the TestCaseClassLoader cannot load classes
from jar files.

=cut

package junit::util::TestCaseClassLoader;
use ClassLoader;
use vars qw(@ISA);
@ISA=qw(ClassLoader);

=head2 XXXX

	private String[] fPathItems;

=cut


=head2 XXXX

	private String[] fExcluded= { "com.sun.", "sun."};

=cut


=head2 XXXX

	static final String EXCLUDED_FILE= "excluded.properties";
	/**

=head2 XXXX

Constructs a TestCaseLoader. It scans the class path
and the excluded package paths

=cut

sub TestCaseClassLoader {
}

=head2 XXXX

Locate the given file.
returns:

=over 4

=item *

Returns null if file couldn't be found.

=back

=cut

sub locate {
}
