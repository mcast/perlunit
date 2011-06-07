#! perl
#
# Was supposed to be just a quick hack...
#
# Runs from dist-tools/set_VERSION.sh as an in-place file editor on
# all modules in a new distdir.
#
# Also runs from Makefile as the PM_FILTER, for the sole benefit of
# Test::Unit when not building from checkout, not tarball.
#
# We cannot be a general PM_FILTER for all modules because that would
# be too late for CPAN to see them.  Also we want the filename of the
# input, and ExtUtils::Install::run_filter (v1.54) does not supply it.

use strict;
use warnings;


sub main {
  my ($vsn, $libdir, $fn) = @ARGV;
  my ($fn_pkg, $pmf_mode);

  if (3 == @ARGV && $vsn eq '--pmf') {
    # PM_FILTER mode, for source build
    undef $^I;
    (undef, $vsn, $fn_pkg) = @ARGV;
    @ARGV = (); # use STDIN
    $fn = '(PM_FILTER)';
    $pmf_mode = 1;
  } elsif (3 == @ARGV && -d $libdir && -f $fn) {
    # in-place editor mode, for distdir
    $^I = '';
    ($vsn, $libdir, $fn) = @ARGV;
    @ARGV = ($fn);
    $libdir =~ s{/*$}{/};
    $fn_pkg = fn2pkg($fn, $libdir);
  } else {
    die "Syntax: $0 { <version> <libdir> <module_filename> | --pmf <version> <module_name> }";
  }

  my $fn_fmt = '%-60s';
  my $done = '';
  while (<>) {
    if (/([\$*])(([\w\:\']*)\bVERSION)\b.*\=/
	# (Pattern used by my current ExtUtils::MakeMaker)
	and not /^\s*#/) {
      chomp;
      die "VERSION assignment '$_' not expected in input";
      # Keep *all* the VERSION assignments in the built or dist files
    }

    if (m{^\s*package\s+([A-Za-z0-9_:]+)\s*;}) {
      my $pkg = $1;

      if ($pkg ne $fn_pkg) {
	warn sprintf("$fn_fmt skip   pkg=%s done=%s\n",
		     "$fn:", $pkg, $done)
	  unless $pmf_mode;
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

  if ($done || $pmf_mode) {
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
