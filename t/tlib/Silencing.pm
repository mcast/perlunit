package Silencing;

use strict;

use IO::String; # more portable than /dev/null ?
use Test::Unit::TestRunner;
use Test::Unit::Debug qw( debug_to_file );

use base 'Exporter';
@Silencing::EXPORT_OK = qw( silent_debug silent_testrunner );


sub silent_testrunner {
  my $nullfh = IO::String->new;
  return Test::Unit::TestRunner->new($nullfh);
}

sub silent_debug {
  my $nullfh = IO::String->new;
  debug_to_file($nullfh);
  return ();
}

1;
