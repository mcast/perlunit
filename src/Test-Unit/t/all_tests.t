#!/usr/bin/perl -w

use strict;

use Test::Unit::HarnessUnit;

use lib 't/tlib', 'tlib';

my $testrunner = Test::Unit::HarnessUnit->new();
$testrunner->start("AllTests");
