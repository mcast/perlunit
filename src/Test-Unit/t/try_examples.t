
# using the standard built-in 'Test' module (assume nothing)
use strict;
use Test;

warn("\nThe STDERR redirection may not work or may behave differently under\n".
     "your OS. This will probably cause this test to fail.\n")
    if $^O =~ /Win32/i;
# this will apply to various OSes. Is there a "capable of doing unix
# redirections" flag somewhere?

foreach (qw(Makefile.PL Makefile examples lib t)) {
    die("Please run 'make test' from the top-level source directory\n".
	"(I can't see $_)\n")
	unless -e $_;
}

my @examples = grep { $_ ne '.' && $_ ne '..' } glob "examples/*";

my %guru_checked =
    ("examples/procedural-adding-suites-example.pl" => <<'EGC',
--- Testing FooBar ---
....
Time:  0 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

OK (4 tests)
--- Testing Bar with Foo added to it ---
....
Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

OK (4 tests)
EGC

     "examples/procedural-ok-example.pl" => <<'EGC',
..
TIME-SUMMARY

OK (2 tests)
EGC

     "examples/procedural-another-package-example.pl" => <<'EGC',
..
Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

OK (2 tests)
EGC

     # setting autoflush on STDOUT & STDERR in this example will pop
     # the first line to the bottom
     "examples/procedural-fail-example.pl" => <<'EGC',
Test was not successful.
.F.
Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

!!!FAILURES!!!
Test Results:
Run: 2 Failures: 1 Errors: 0
There was 1 failure:
1) test_fail(Test::Unit::TestCase::Load1_Anonymous1)
Test::Unit::ExceptionFailure:
Born to lose ...
EGC

     "examples/patch100132" => <<'EGC',
Can't call method "run" on an undefined value at lib/Test/Unit/TestRunner.pm line 58.
EGC

     "examples/patch100132-1" => <<'EGC',
...
Time:  0 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

OK (3 tests)
EGC

     "examples/patch100132-2" => <<'EGC',
...
Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

OK (3 tests)
EGC

     );

# undef indicates things to skip
@guru_checked{map { "examples/$_" }
		  qw(CVS Experimental README tester.pl tester.png)} = ();


plan(tests => scalar @examples,
     todo  => [ grep { !defined $guru_checked{$examples[$_-1]} }
		(1 .. @examples)
	       ]);

foreach my $e (keys %guru_checked) {
    warn("Guru ".(defined $guru_checked{$e} ? 'answer' : 'excuse').
	 " exists for '$e' but there is no test file\n")
	unless grep { $_ eq $e } @examples;
}


warn "There might be problems with error redirection undef $^O"
    if grep { $^O =~ $_ } ( qr/win/i );

foreach my $e (@examples) {
    if (defined $guru_checked{$e}) {
	# get program output
	my $out = `perl -I lib -I examples $e 2>&1`;
	foreach ($out, $guru_checked{$e}) {
	    # mess about with start & end newlines
	    s/^\n+//;
	    $_ .= "\n" unless /\n$/;
	    # bin the naughty carriage returns
	    s/\r//g;
	    # indent lines with '# ' so they're comments if the test fails
	    s/\n/\n# /g;
	    # hide things that look like CPU usage
	    s{Time:\s+[\d\.]+\s+wallclock secs \([\d\s\.]+usr\s+\+[\d\s\.]+sys\s+=[\d\s\.]+CPU\)}
	    {TIME-SUMMARY}g;
	}
	ok($out, $guru_checked{$e});
    } else {
	warn "Skipping example file '$e', no guru-checked answer\n"
	    unless exists $guru_checked{$e};
	ok(0);
    }
}
