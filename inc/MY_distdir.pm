package MY;

use strict;
# use warnings; # avoid, and hope the caller has -w


=head1 DESCRIPTION

Intercept C<distdir> target and apply prevailing version number to
modules.

=cut

sub distdir {
  my ($self) = shift;
  my $super = $self->SUPER::distdir(@_);

  $super =~ s/^(distdir\s*:)/plain_$1/m
    or die "Cannot intercept distdir in this make fragment:\n$super";

  return ($super.
	  "# hacked on by ".__FILE__.
	  <<'MAKE_FRAG');

distdir : plain_distdir
	dist-tools/set_VERSION.sh $(VERSION) $(DISTVNAME)

MAKE_FRAG
}

1;
