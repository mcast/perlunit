#!/usr/bin/perl -w

use strict;

use Test::Unit::TestRunner;

my $testrunner = Test::Unit::TestRunner->new();
$testrunner->start(@ARGV);

