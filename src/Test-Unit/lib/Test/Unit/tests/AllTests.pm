package Test::Unit::tests::AllTests;

use Test::Unit::TestRunner;
use Test::Unit::TestSuite;
use Test::Unit::tests::SuiteTest;
use Test::Unit::InnerClass;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub suite {
    my $class = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Framework Tests");
    $suite->add_test(Test::Unit::TestSuite->new("Test::Unit::tests::TestTest"));
    $suite->add_test(Test::Unit::TestSuite->new("Test::Unit::tests::TestInnerClass"));
    $suite->add_test(Test::Unit::tests::SuiteTest->suite());
    return $suite;
}

1;
