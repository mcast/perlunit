package GetVersion;

use strict;
# use warnings; # avoid, and hope the caller has -w


=head1 DESCRIPTION

If we have F<.git/> then consult L<git(1)> to obtain the version from
a tag.  Fail if not available - we have no other version info.

Otherwise assume this is an unpacked dist tarball, and ask
L<ExtUtils::MakeMaker> to consult L<Test::Unit>.

=cut


sub version_pair {
  my ($called) = @_;

  if (-d ".git") {
    return (VERSION => $called->_vc_version);
  } else {
    return (VERSION_FROM => 'lib/Test/Unit.pm'), # finds $VERSION
  }
}

sub _vc_version {
  my ($called) = @_;

  my $gitvsn = `git --version 2>&1`;
  if ($?) {
    die "Cannot proceed on a development checkout without git(1)";
  }
  warn "$called: Using $gitvsn";

  my $pattern = q{--match 'v[0-9].*'};
  my $cmd = "git describe --dirty --exact-match $pattern 2>&1";
  my $dist_vsn = `$cmd`;
  chomp $dist_vsn;
  if ($?) {
    warn("  HEAD is not tagged(annotated)\n".
	 "  `$cmd` == '$dist_vsn'\n".
	 "  Making this a dev release...\n");
    $dist_vsn = $called->_git_dev_tag($pattern);
  } elsif ($dist_vsn =~ m{^v(\d+\.\d+)$}) {
    $dist_vsn = $1;
    warn "  Found v$dist_vsn\n";
  } else {
    warn "dirty?  check 'git status'" if $dist_vsn =~ /dirty/;
    die "Version '$dist_vsn' based on annotated tag matches $pattern, but I didn't like it";
  }

  return $dist_vsn;
}

sub _git_dev_tag {
  my ($called, $pattern) = @_;
  die "dev-tagged release not implemented";
}


1;
