#!/usr/bin/perl -w

use strict;

use Test::Unit::TkTestRunner;

warn "$0 is deprecated, please use punit-tk\n"
  unless $ENV{PERLUNIT_DEPRECATIONS_ACK};

exit Test::Unit::TkTestRunner::main(@ARGV);
