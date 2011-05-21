#! perl -w

use strict;

use Test::Unit::HarnessUnit;
use Test::Unit::Debug qw(debug_pkgs);

use Test;
plan(tests => 5);

use lib 't/tlib', 'tlib';
use ManyThrowsTestCase;


my $sink = new OutPlace();
eval {
    my $testrunner = Test::Unit::HarnessUnit->new($sink);
    $testrunner->start("ManyThrowsTestCase");
};


my $prob = $@ || "";
ok(ref($prob), "", "Test aborted because typed error leaked out. T:U:Result = $INC{'Test/Unit/Result.pm'}");
ok($prob, "", "Test aborted: $@");

ok(ManyThrowsTestCase::count_ran(),
   ManyThrowsTestCase::count_want_ran(),
   "Some test methods did not start");


my $out = $sink->get_all;
my @pass = $out =~ m{^ok }g;
my @fail = $out =~ m{^not ok }g;

ok(scalar @pass, ManyThrowsTestCase::count_want_pass());
ok(scalar @fail + scalar @pass, ManyThrowsTestCase::count_want_ran());

print STDERR $out;



package OutPlace;

sub new { bless [], shift }

sub print {
    my ($self, @args) = @_;
    my $txt = join " ", @args;
    $txt =~ s{^}{  OutPlace: }gm;
    push @$self, $txt;
}

sub get_all {
    my $self = shift;
    return join "", @$self;
}
