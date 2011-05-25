#! /usr/bin/perl -T

use strict;
use warnings;
use CGI::Carp 'fatalsToBrowser';
use Time::HiRes qw( gettimeofday tv_interval );

=head1 DESCRIPTION

Minimal "what version is this website on?" script.

We don't have Git to do the work.  Do the bare minimum.

=cut


sub main {
    my $t0 = [ gettimeofday ];
    $ENV{PATH} = '/bin:/usr/bin';
    my $CI_RE = qr{^[a-f0-9]{40}$}i;
    my $gitdir = "$ENV{SF_PATH}/.git"; # SourceForge-specific; could trundle upwards searching

    my $head = slurp("$gitdir/HEAD");
    if ($head =~ $CI_RE) {
      # detached head - strange but OK
    } elsif ($head =~ m{^ref: (refs/[-_a-z0-9/]{1,64})$}) {
      my $branch = $1;
      if (-f "$gitdir/$branch") {
	$head = slurp("$gitdir/$branch");
	die "Bad head" unless $head =~ $CI_RE;
      } else {
	die "Packed ref lookup not implemented: $gitdir/$branch not found";
      }
    } else {
      die "Failed to detaint HEAD contents";
    }

    my $t_id = [ gettimeofday ];
    my $gen_time = tv_interval($t0, $t_id);
    print <<"OUT";
Content-type: text/html\n
<html><body>
 <a href="http://perlunit.git.sourceforge.net/git/gitweb.cgi?p=perlunit/perlunit;a=commit;h=$head"
    title="Lookup in ${gen_time}s">
   <tt>$head</tt>
 </a>
</body></html>
OUT
}

sub slurp {
    my ($fn) = @_;
    open my $fh, '<', $fn or die "Read $fn: $!";
    return <$fh>;
}

main();
