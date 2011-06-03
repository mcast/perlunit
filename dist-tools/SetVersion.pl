#! perl -i
#
# Quick hack.  Runs from dist-tools/set_VERSION.sh

use strict;
use warnings;


sub main {
  my ($vsn, $libdir, $fn) = @ARGV;
  die "Syntax: $0 <version> <libdir> <module_filename>"
    unless 3 == @ARGV && -d $libdir &&-f $fn;
  splice @ARGV, 0, 2;

  $libdir =~ s{/*$}{/};
  my $fn_pkg = fn2pkg($fn, $libdir);
  my $fn_fmt = '%-60s';

  my $done = '';
  while (<>) {
    if (/([\$*])(([\w\:\']*)\bVERSION)\b.*\=/
	# (Pattern used by my current ExtUtils::MakeMaker)
	and not /^\s*#/) {
      chomp;
      die "VERSION assignment '$_'";
    }

    if (m{^\s*package\s+([A-Za-z0-9_:]+)\s*;}) {
      my $pkg = $1;

      if ($pkg ne $fn_pkg) {
	warn sprintf("$fn_fmt skip   pkg=%s done=%s\n",
		     "$fn:", $pkg, $done);
      } elsif ($done) {
	warn sprintf("$fn_fmt skip   repeat ln#%d done=%s\n",
		     "$fn:", $., $done);
      } else {
	$_ .= qq[BEGIN {\n  \$${pkg}::VERSION = '$vsn'; # added by $0\n}\n];
	$done="ln#$.";
	warn sprintf("$fn_fmt done %s\n", "$fn:", $done);
      }
    }

    print;
  }

  if ($done) {
    return 0;
  } else {
    warn sprintf("$fn_fmt FAIL     %s not seen\n", "$fn:", $fn_pkg);
    return 1;
  }
}


sub fn2pkg {
  my ($fn, $libdir) = @_;
  my $fn_pkg = $fn;

  my $pfxlen = length($libdir);
  if (length($fn_pkg) > $pfxlen and
      substr($fn_pkg, 0, $pfxlen) eq $libdir) {
    substr($fn_pkg, 0, $pfxlen, '');
  } else {
    die "Cannot subtract prefix $libdir from $fn";
  }

  $fn_pkg =~ s{\.pm$}{}
    or die "$fn: not a module\n";

  $fn_pkg =~ s{/}{::}g;

  return $fn_pkg;
}


exit(main());
