use lib "./";

require "./Unit.pm";

my $testrunner = Test::Unit::TestRunner->new();
$testrunner->start(@ARGV);

