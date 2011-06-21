#! perl -w

use strict;

# using the standard built-in 'Test' module (assume nothing)
use Test;
BEGIN { plan tests => 9 }

# test subjects
use Test::Unit::TestRunner;
use Test::Unit::Debug qw( debug_pkg );
use lib 't/tlib', 'tlib';

use Silencing qw( silent_debug silent_testrunner );

sub main {
  my @bigmods = qw( B B::Deparse );

  silent_debug();
  t_modsloaded(); # 2

  # Run tests - should not generate debug messages
  t_mods("precondition: bigmods not loaded", 0, @bigmods); # 1
  t_run_sometests(); # 2
  t_mods("do not run slow debug messages", 0, @bigmods); # 1

  # Test again, after making debug messages for at least enough
  # packages to pass _our_ tests
  my @debugmods = qw( Test::Unit::Assert Test::Unit::Assertion::CodeRef Test::Unit::Assertion::Exception Test::Unit::Result Test::Unit::TestCase );
  debug_pkg(@debugmods);

  t_run_sometests(); # 2
  t_mods("indicator modules list is representative", 1, @bigmods); # 1

#  inc_diag();
}


sub t_modsloaded {
  # Use a couple of our modules, to see that t_mods works
  my @mods = qw( Test::Unit::HarnessUnit Test::Unit::Runner::Terminal );
  t_mods("before load", 0, @mods);
  foreach my $mod (@mods) { eval "use $mod" }
  t_mods("before load", 1, @mods);

  # Actually it's not a fair test, because B.pm makes a bunch of
  # modules by writing their @ISA

  return ();
}

sub t_mods {
  my ($test_descr, $want_loaded, @mods) = @_;

  my @loaded = mods_loaded(@mods);
  ok(scalar @loaded, ($want_loaded ? scalar @mods : 0), $test_descr);
  print "# tested=(@mods)\n"; # diag
  print "# loaded=(@loaded)\n";

  return ();
}

sub mods_loaded {
  return grep {
    my $modfn = $_; $modfn =~ s{::}{/}g; $modfn .= '.pm';
    exists $INC{$modfn};
  } @_;
}

sub t_run_sometests {
  my $what = "RepeatableTests";

  my $runner = silent_testrunner();
  my $success = $runner->start($what);
  my $runcount = $runner->result->run_count;
  ok($runcount > 10, 1, "Sensible number of tests ($runcount)");
  ok($success, 1, "$what pass");
  foreach my $bad (@{ $runner->result->errors },
		   @{ $runner->result->failures }) {
    my $msg = "$bad\n";
    $msg =~ s/^/#   /mg;
    $msg =~ s/\A#   /# > /;
    print $msg; # diag
  }

  return ();
}

sub inc_diag {
  print "### Modules now loaded\n#\n";
  print map {"#   $_\n"} sort keys %INC;
}

main();
