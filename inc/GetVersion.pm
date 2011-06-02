package GetVersion;

use strict;
# use warnings; # avoid, and hope the caller has -w

use Cwd 'getcwd';


=head1 DESCRIPTION

If we have F<.git/> then consult L<git(1)> to obtain the version from
a tag.  Fail if not available - we have no other version info.

Otherwise assume this is an unpacked dist tarball, and ask
L<ExtUtils::MakeMaker> to consult L<Test::Unit>.

=cut


sub version_pair {
  my ($called) = @_;
  die "returns a list" unless wantarray;

  my $dir = getcwd();
  warn "Find version for $dir";

  my @out =
    (-d ".git"
     ? (VERSION => $called->_vc_version)
     : (VERSION_FROM => 'lib/Test/Unit.pm') # finds $VERSION
    );

  warn "$called:   $dir is (@out)\n";
  return @out;
}

sub _vc_version {
  my ($called) = @_;

  my $gitvsn = `git --version 2>&1`;
  if ($?) {
    die "Cannot proceed on a development checkout without git(1)";
  }
  warn "  Using $gitvsn";

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

  my $old_vsn = $called->_old_dev;
  return $old_vsn if defined $old_vsn;

  my $cmd = "git describe --dirty $pattern 2>&1";
  my $dist_vsn = `$cmd`;
  chomp $dist_vsn;
  warn "  `$cmd` == '$dist_vsn'\n";

  if ($?) {
    die "Found no annotated tags on this branch - confused";
  } elsif ($dist_vsn =~ /dirty/) {
    die "Working copy is not clean (ask `git status`), I cannot tag it";

  } elsif ($dist_vsn =~ m{^v(\d+\.\d+)-(\d+)-g([a-f0-9]+)$}) {
    my ($last_rel, $numci, $rev) = ($1, $2, $3);
    $numci = 99 if $numci > 99;
    # $rev is ignored

    $dist_vsn = $called->_new_dev($last_rel, $numci);

    $cmd = "git tag dev$dist_vsn";
    system($cmd) && die "`$cmd` failed: $! / $?";

    warn "  New dev$dist_vsn\t\t(new tag, to push xor delete later)\n";

  } else {
    die "Version '$dist_vsn' based on annotated tag matches $pattern, but I didn't like it";
  }

  return $dist_vsn;
}

sub _new_dev {
  my ($called, $last_rel, $numci) = @_;

  my %devtag;
  my @devtag = `git tag -l 'dev*'`;
  chomp @devtag;
  @devtag{@devtag} = ();

  my ($n, $v) = (1);
  while (!defined $v || exists $devtag{"dev$v"}) {
    die "Dev build tag algorithm fail? v=$v n=$n" if $n>99;
    $v = sprintf("%s_%02d%02d", $last_rel, $numci, $n);
    $n++;
  }

  return $v;
}

sub _old_dev {
  my ($called, $pattern) = @_;

  my $cmd = "git describe --dirty --exact-match --match 'dev[0-9].*_*' --tags 2>&1";
  my $dist_vsn = `$cmd`;
  chomp $dist_vsn;
  warn "  `$cmd` == '$dist_vsn'\n";
  if ($?) {
    warn "  (not a previously tagged dev build)\n";
    return ();

  } elsif ($dist_vsn =~ m{^dev(\d+\.\d+_\d+)$}) {
    $dist_vsn = $1;
    warn "  Found dev$dist_vsn\n";

  } else {
    warn "dirty?  check 'git status'" if $dist_vsn =~ /dirty/;
    die "Version '$dist_vsn' looked like a previous dev build, but I didn't like it";
  }

  return $dist_vsn;
}


1;
