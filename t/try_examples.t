#!/usr/bin/perl -w

use strict;

use Config;
my $path_to_perl = $Config{perlpath};


# using the standard built-in 'Test' module (assume nothing)
use Test;


foreach (qw(Makefile.PL Makefile examples lib t)) {
    die("Please run 'make test' from the top-level source directory\n".
	"(I can't see $_)\n")
	unless -e $_;
}

my %skip = map { ("examples/$_") => 1 }
               qw(. .. Experimental README tester.png);
my @examples = grep { ! $skip{$_} } glob("examples/*");

my %guru_checked = (
    'examples/AnnotatedFail.pm' => <<'EGC',
...EF..
Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

!!!FAILURES!!!
Test Results:
Run: 5, Failures: 1, Errors: 1

There was 1 error:
1) examples/AnnotatedFail.pm:25 - test_BZZT(AnnotatedFail)
BZZT

Annotations:
I was just wondering what this red button did.
It said 'Do not press'
It looks very tempting
There was 1 failure:
1) examples/AnnotatedFail.pm:11 - test_witter(AnnotatedFail)
crunch

Annotations:
Well it worked up to a certain point
Then it broke with a tinkly crunch.
Test was not successful.
EXITCODE:0x100
EGC

     "examples/patch100132" => <<'EGC',
...
Time:  0 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

OK (3 tests)
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

     "examples/fail_example.pm" => <<'EGC',
Suite setup
.F.Suite teardown

Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

!!!FAILURES!!!
Test Results:
Run: 2, Failures: 1, Errors: 0

There was 1 failure:
1) examples/fail_example.pm:19 - test_fail(fail_example)
Born to lose ...

Test was not successful.
EXITCODE:0x100
EGC

     );

plan(tests => 1 + @examples);

foreach my $e (keys %guru_checked) {
    warn("Guru ".(defined $guru_checked{$e} ? 'answer' : 'excuse').
	 " exists for '$e' but there is no test file\n")
	unless grep { $_ eq $e } @examples;
}
ok((join ';', sort keys %guru_checked),
   (join ';', sort @examples),
   '%guru_checked 1:1 @examples');

# We used to warn about OSes that might not be able to do 2>&1
# redirection, but
#   a) if we get problems the tests will fail, so we fix it then
#   b) tests passed fine on "MSWin32 4.0" for REL_0_25


# warn "running examples with \$path_to_perl='$path_to_perl'\n  under \@INC=(@INC)\n  with PERL5LIB=$ENV{PERL5LIB}\n";


foreach my $e (@examples) {
    if (defined $guru_checked{$e}) {
	# get program output
        my $runner = $e =~ /\.pm$/ ? './TestRunner.pl ' : '';
        my $cmd = "$path_to_perl -I examples $runner$e 2>&1";
#        warn "cmd $cmd\n";
	my $out = `$cmd`;
	$out .= sprintf("EXITCODE:0x%X\n", $?) if $?;
	foreach ($out, $guru_checked{$e}) {
	    # mess about with start & end newlines
	    s/^\n+|\n*$/\n/gs;
	    # bin the naughty carriage returns
	    s/\r//g;
	    # we can't assume the order of tests will be the same
	    s{^([.FE]+)((?:Suite teardown)?)$}{join '', (sort '{sorted}', split //, $1), $2}em;
	    s/::Load[0-9_]+Anonymous[0-9_]+/::LOAD_ANONYMOUS_CLASSNAME/;
	    # hide things that look like CPU usage
	    s{^Time:\s+[\d\.]+\s+wallclock secs \([-\d\s\.]+usr\s+\+[-\d\s\.]+sys\s+=[-\d\s\.]+CPU\)}
	    {TIME-SUMMARY}mg;
	    # indent lines with '# ' so they're comments if the test fails
	    s/\n/\n# /g;
	}
	ok($out, $guru_checked{$e}, $e);
    } else {
	skip( (exists $guru_checked{$e}
	       ? "Skip $e: not yet checked"
	       : 0),
	      "nothing", "data at \$guru_checked{$e}");
    }
}
