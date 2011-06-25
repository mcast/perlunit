#! perl -w

use strict;

# using the standard built-in 'Test' module (assume nothing)
use Test;
BEGIN { plan tests => 9 }

use Benchmark qw( :all :hireswallclock );
use Test::Unit::Debug qw( debug_pkg no_debug_pkg debug_importers debug_to_stderr );

use lib 't/tlib', 'tlib';
use Silencing qw( silent_debug silent_testrunner );
use RepeatableTests;

sub main {

  my @subject = qw( manytests debug_many postdebug );
  my %max_ratio = (manytests => 40, debug_many => 95, postdebug => 55);
  my %want_runcount = (RepeatableTests => 80);

## run them individually, for easier maintenance of work ratios?
#
#  foreach my $test (RepeatableTests->include_tests) {
#    $subject{$test} = sub { run_sometests($test, 0) };
#  }

  my ($bmset, %runcount) = do_timings(@subject, 'dummy_load'); # 2 + 3

  ok(__hash2str(\%runcount),
     __hash2str(\%want_runcount), "test suit run counts"); # 1

  # Compare measured ratios against %max_ratio         # 3
  my $busy_s = __cpusec_iter($$bmset{dummy_load});
  foreach my $test (@subject) {
    die "No limit set for test=$test" unless defined $max_ratio{$test};

    my $test_s = __cpusec_iter($$bmset{$test});
    my $test_rel = $test_s / $busy_s;

    ok($test_rel <=> $max_ratio{$test}, -1, "$test faster than $max_ratio{$test}x dummy_load");
    print "# $test = $test_s CPUsec/loop\n";
    print "# dummy_load = $busy_s CPUsec/loop\n";
    print "#     Ratio = $test_rel\n";
  }
}

sub __hash2str {
  my ($h) = @_;
  return (join ', ', map {"$_:$$h{$_}"} sort keys %$h);
}

sub __cpusec_iter {
  my ($benchmark) = @_;
  return $benchmark->cpu_p / $benchmark->iters;
}


my %runcount; # key=suitename, value=testcases per loop
sub do_timings {
  # produces N+1 "ok"s to break up the waiting

  my @subject = @_; # subroutine names to run
  my %code =
    map { ($_ => Subject->can($_) || die "No Subject::$_" ) }
      @subject;

  my $io = IO::String->new;
  my $show = sub {
    my ($intro) = @_;
    my $txt = ${ $io->string_ref };
    $txt =~ s{^}{#   }mg;
    print STDOUT "# $intro\n$txt";
    $io->truncate;
  };

  my $old_io = select $io;

  # Run first item once to a) load the code b) warm up the scheduler
  # to avoid counting CPUsec on a sleepy CPU
  my $warmup = $subject[0];
  timethis(-1, $code{$warmup});
  ok(1);
  $show->("(io, compile + cpufreq warmup)");

  my %bmset;
  foreach my $test (@subject) {
    $bmset{$test} = timethis(-4, $code{$test});
    ok(1);
    $show->("timed '$test'");
  }

  select $old_io;
  return (\%bmset, %runcount);
}

sub run_sometests {
  my ($what, $debug) = @_;

  my @all_debug = debug_importers(); # will be nil, first time round
  if ($debug) {
    silent_debug();
    debug_pkg(@all_debug);
  } else {
    debug_to_stderr();
    no_debug_pkg(@all_debug);
  }

  my $runner = silent_testrunner();
  my $success = $runner->start($what);
  my $runcount = $runner->result->run_count;

  # When the set of tests changes the timing ratio will need revising.
  #
  # Ideally we would have an individual TestCase or TestSuite per
  # hungry feature, and measure a dedicated & empty set of each
  # against dummy_load.
  #
  # If runcount changes between runs, we have weirdness.
  if (defined $runcount{$what} && $runcount{$what} != $runcount) {
    die "Runcount($what) changed $runcount{$what} -> $runcount";
  }
  $runcount{$what} = $runcount;

  return ();
}

main();



package Subject;
# Have their own package and named subroutines to assist profiling

sub manytests  { main::run_sometests("RepeatableTests", 0) }
sub debug_many { main::run_sometests("RepeatableTests", 1) }
sub postdebug  { main::run_sometests("RepeatableTests", 0) }

sub dummy_load {
  my @data = (1 .. 1000);
  @data = sort { __mashnum($a) <=> __mashnum($b) } @data;
  return $data[5];
}

sub __mashnum {
  my $n = shift;
  my $div = int($n / 77);
  return ($n % 77)*23 + ($div % 23) + int($div / 23) * 77 * 23;
}
