use lib './lib';

use Test::Unit::TestRunner;

my $testrunner = Test::Unit::TestRunner->new();
$testrunner->start("Test::Unit::tests::AllTests");
