#!/usr/bin/perl -w

use strict;

use Test::Unit::Debug qw(debug_pkg); # you don't need this in your tests
use Test::Unit::HarnessUnit;

#debug_pkg(qw{Test::Unit::Result});

use lib 't/tlib', 'tlib';

my $testrunner = Test::Unit::HarnessUnit->new();
$testrunner->start("AllTests");
