use strict;

# ------------------------------------------------ 
package TornDown;

use vars '@ISA';
@ISA = qw(Test::Unit::TestCase);

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {_TornDown => 0}, $class;
    my $aTestCase = $self->SUPER::new($name);
    return bless $aTestCase, $class;
}

sub tearDown {
    my $self = shift;
    $self->{_TornDown} = 1;
}

sub tornDown {
    my $self = shift;
    return $self->{_TornDown};
}

sub runTest {
    my $self = shift;
    my $e = new Test::Unit::ExceptionError();
    die $e;
}

# ------------------------------------------------ 
package WasRun;
#use TestCase;
use vars qw(@ISA);
@ISA=qw(Test::Unit::TestCase);

sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {_WasRun => 0}, $class;
    my $aTestCase = $self->SUPER::new($name);
    return bless $aTestCase, $class;
}

sub runTest {
    my $self = shift;
    $self->{_WasRun} = 1;
}

sub wasRun {
    my $self = shift;
    return $self->{_WasRun};
}

# ------------------------------------------------ 
package tests::TestTest;

#use TestCase;
use vars qw(@ISA);
@ISA=qw(Test::Unit::TestCase);

# helper to emulate Java inner class syntax feature
# clever, eh

{
    my $i = 0;
    sub makeInnerClass {
	my ($class, $extensionText, @constructorArgs) = @_;
	$i++;
	eval  "package $class" . "::" ."Anonymous$i;"
	    . "use vars qw(\@ISA); \@ISA = qw($class);"
		. $extensionText;
	no strict 'refs';
	return ("$class" . "::" . "Anonymous$i")->new(@constructorArgs);
	}
} 
   
sub new {
    my $class = shift;
    my ($name) = @_;
    my $self = bless {}, $class;
    my $aTestCase = $self->SUPER::new($name);
    return bless $aTestCase, $class;
}
    
sub verifyError {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->runCount() == 1);
    $self->assert($result->failureCount() == 0);
    $self->assert($result->errorCount() == 1);
}

sub verifyFailure {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->runCount() == 1);
    $self->assert($result->failureCount() == 1);
    $self->assert($result->errorCount() == 0);
}

sub verifySuccess {
    my $self = shift;
    my ($test) = @_;
    my $result = $test->run();
    $self->assert($result->runCount() == 1);
    $self->assert($result->failureCount() == 0);
    $self->assert($result->errorCount() == 0);
}

# test subs

sub testCaseToString {
    my $self = shift;
    $self->assert($self->toString() eq "testCaseToString(tests::TestTest)");
}

sub testError {
    my $self = shift;
    my $error = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "error"); 
sub runTest {
    my $self = shift;
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verifyError($error);
}

sub testFail {
    my $self = shift;
    my $fail = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "fail"); 
sub runTest {
    my $self = shift;
    fail();
}
EOIC
    $self->verifyError($fail);
}

sub testFailure {
    my $self = shift;
    my $failure = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "failure"); 
sub runTest {
    my $self = shift;
    $self->assert(0);
}
EOIC
    $self->verifyFailure($failure);
}
    
sub testFailureException {
    my $self = shift;
    eval {
	$self->fail();
    };
    my $exception = $@;
    if ($exception->isa("Test::Unit::ExceptionFailure")) {
	return;
    }
    $self->fail();
}

sub testRunAndTearDownFails {
    my $self = shift;
    my $fails = makeInnerClass("TornDown", <<'EOIC', "fails");
sub tearDown {
    my $self = shift;
    $self->SUPER::tearDown();
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub runTest {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verifyError($fails);
    $self->assert($fails->tornDown());
}

sub testRunnerPrinting {
    my $self = shift;
    $self->assert("1.05" eq (1050 / 1000));
}

sub testSetupFails {
    my $self = shift;
    my $fails = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "fails"); 
sub setUp {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub runTest {
}
EOIC
    $self->verifyError($fails);
}

sub testSuccess {
    my $self = shift;
    my $success = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "success"); 
sub runTest {
    my $self = shift;
    $self->assert(1);
}
EOIC
    $self->verifySuccess($success);
}

sub testTearDownAfterError {
    my $self = shift;
    my $fails = makeInnerClass("TornDown", "", "fails");
    $self->verifyError($fails);
    $self->assert($fails->tornDown());
}

sub testTearDownFails {
    my $self = shift;
    my $fails = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "fails"); 
sub tearDown {
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
sub runTest {
}
EOIC
    $self->verifyError($fails);
}

sub testTearDownSetupFails {
    my $self = shift;
    my $fails = makeInnerClass("TornDown", <<'EOIC', "fails");
sub setUp {
    my $self = shift;
    my $e = Test::Unit::ExceptionError->new();
    die $e;
}
EOIC
    $self->verifyError($fails);
    $self->assert(not $fails->tornDown());
}

sub testWasNotSuccessful {
    my $self = shift;
    my $failure = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "fail"); 
sub runTest {
    my $self = shift;
    $self->fail();
}
EOIC
    my $result = $failure->run();
    $self->assert($result->runCount() == 1);
    $self->assert($result->failureCount() == 1);
    $self->assert($result->errorCount() == 0);
    $self->assert(not $result->wasSuccessful());
}

sub testWasRun {
    my $self = shift;
    my $test = WasRun->new("");
    $test->run();
    $self->assert($test->wasRun());
}

sub testWasSuccessful {
    my $self = shift;
    my $success = makeInnerClass("Test::Unit::TestCase", <<'EOIC', "success"); 
sub runTest {
    my $self = shift;
    $self->assert(1);
}
EOIC
    my $result = $success->run();
    $self->assert($result->runCount() == 1);
    $self->assert($result->failureCount() == 0);
    $self->assert($result->errorCount() == 0);
    $self->assert($result->wasSuccessful());
}

1;
