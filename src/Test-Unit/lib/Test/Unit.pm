use strict;

# ------------------------------------------------ 
package Test::Unit::Test;
use constant DEBUG => 0;

use Carp;

sub countTestCases {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::countTestCases";
}

sub run {
    my $self = shift;
    my $class = ref($self);
    croak "call to abstract method ${class}::run";
}

# ------------------------------------------------ 
package Test::Unit::Exception;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($message) = @_;
    
    my $i = 0;
    my $stacktrace = '';
    my ($pack, $file, $line, $subname, $hasargs, $wantarray);
    
    $stacktrace = ref($class) . ": " . $message . "\n";
    while (($pack, $file, $line, $subname, 
	    $hasargs, $wantarray) = caller($i++)) {
	$stacktrace .= "Level $i: in package '$pack', file '$file', at line '$line', sub '$subname'\n";
    }
    
    bless { stacktrace => $stacktrace }, $class;
}

sub stacktrace {
    my $self = shift;
    return $self->{stacktrace};
}

# ------------------------------------------------ 
package Test::Unit::ExceptionFailure;
use vars qw(@ISA);
@ISA=qw(Test::Unit::Exception);

# ------------------------------------------------ 
package Test::Unit::ExceptionError;
use vars qw(@ISA);
@ISA=qw(Test::Unit::Exception);

# ------------------------------------------------ 
package Test::Unit::Assert;
use constant DEBUG => 0;

sub assert {
    my $self = shift;
    print ref($self) . "::assert() called\n" if DEBUG;
    my ($condition, $message) = @_;
    $self->fail($message) unless $condition;
}

sub fail {
    my $self = shift;
    print ref($self) . "::fail() called\n" if DEBUG;
    my ($message) = @_;
    die Test::Unit::ExceptionFailure->new($message);
}


# ------------------------------------------------ 
package Test::Unit::TestFailure;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($test, $exception) = @_;
    bless { 
	_FailedTest => $test,
	_ThrownException => $exception,
    }, $class;
}

sub failedTest {
    my $self = shift;
    return $self->{_FailedTest};
}

sub thrownException {
    my $self = shift;
    return $self->{_ThrownException};
}

sub toString {
    my $self = shift;
    return $self->failedTest()->toString() . 
	$self->thrownException()->stacktrace();
}

# ------------------------------------------------ 
package Test::Unit::TestCase;
use constant DEBUG => 0;
# use Assert;
use vars qw(@ISA);
@ISA=qw(Test::Unit::Assert Test::Unit::Test);

sub new {
    my $class = shift;
    my ($name) = @_;
    bless { _name => $name }, $class;
}

sub countTestCases {
    my $self = shift;
    return 1;
}

sub createResult {
    my $self = shift;
    return Test::Unit::TestResult->new();
}

sub name {
    my $self = shift;
    return $self->{_name};
}

sub run {
    my $self = shift;
    print ref($self) . "::run() called\n" if DEBUG;
    my $result = createResult();
    $self->_run($result);
    return $result;
}

sub _run {
    my $self = shift;
    print ref($self) . "::_run() called\n" if DEBUG;
    my ($result) = @_;
    $result->run($self);
    return $result;
}

sub runBare {
    my $self = shift;
    print ref($self) . "::runBare() called\n" if DEBUG;
    $self->setUp();
    eval {
	$self->runTest();
    };
    my $exception = $@;
    $self->tearDown();
    if ($exception) {
	print ref($self) . "::_runBare() propagating exception\n" if DEBUG;
	if (ref($exception) ne "Test::Unit::ExceptionFailure") {
	    $exception = Test::Unit::ExceptionError->new($exception);
	}
	die $exception; # propagate exception
    }
}

sub runTest {
    my $self = shift;
    print ref($self) . "::runTest() called\n" if DEBUG;
    my $class = ref($self);
    my $method = $self->name();
    no strict 'refs';
    print "Should now call $class\:\:$method\n" if DEBUG;
    if (defined &{$class . "::" . $method}) {
	&{$class . "::" .$method}($self);
    } else {
	$self->fail("Method $method not found");
    }
}

sub setUp {
}

sub tearDown {
}

sub toString {
    my $self = shift;
    my $class = ref($self);
    return $self->name() . "(" . $class . ")";
}

# ------------------------------------------------ 
package Test::Unit::TestResult;
use constant DEBUG => 0;

sub new {
    my $class = shift;

    my @_Failures = ();
    my @_Errors = ();
    my @_Listeners = ();
    my $_RunTests = 0;
    my $_Stop = 0;

    bless { 
	_Failures => \@_Failures,
	_Errors => \@_Errors,
	_Listeners => \@_Listeners,
	_RunTests => $_RunTests,
	_Stop => $_Stop,
    }, $class;
}

sub addError { 
    my $self = shift;
    print ref($self) . "::addError() called\n" if DEBUG;
    my ($test, $exception) = @_;
    push @{$self->errors()}, Test::Unit::TestFailure->new($test, $exception);
    for my $e (@{$self->listeners()}) {
	$e->addError($test, $exception);
    }
}

sub addFailure {
    my $self = shift;
    print ref($self) . "::addFailure() called\n" if DEBUG;
    my ($test, $exception) = @_;
    push @{$self->failures()}, Test::Unit::TestFailure->new($test, $exception);
    for my $e (@{$self->listeners()}) {
	$e->addFailure($test, $exception);
    }
}

sub addListener {
    my $self = shift;
    print ref($self) . "::addListener() called\n" if DEBUG;
    my ($listener) = @_;
    push @{$self->listeners()}, $listener;
}

# change cloneListeners() to listeners()
sub listeners {
    my $self = shift;
    return $self->{_Listeners};
}
 
sub endTest {
    my $self = shift;
    for my $e (@{$self->listeners()}) {
	$e->endTest();
    }
}

sub errorCount {
    my $self = shift;
    return scalar @{$self->{_Errors}};
}

sub errors {
    my $self = shift;
    return $self->{_Errors};
}
 
sub failureCount {
    my $self = shift;
    return scalar @{$self->{_Failures}};
}

sub failures {
    my $self = shift;
    return $self->{_Failures};
}
 
sub run {
    my $self = shift;
    print ref($self) . "::run() called\n" if DEBUG;
    my ($test) = @_;
    $self->startTest($test);
    eval { 
	$test->runBare(); 
    };
    my $exception = $@;
    if ($exception) {
	print ref($self) . "::run() caught exception: $exception\n" if DEBUG;
	if (ref($exception) eq "Test::Unit::ExceptionFailure") {
	    $self->addFailure($test, $exception);
	} else {
	    $self->addError($test, $exception);
	}
    }
    $self->endTest($test);
} 

# I put runProtected() into run() above

sub runCount {
    my $self = shift;
    return $self->{_RunTests};
}

sub shouldStop {
    my $self = shift;
    return $self->{_Stop};
}
    
sub startTest {
    my $self = shift;
    my ($test) = @_;
    $self->{_RunTests}++;
    for my $e (@{$self->listeners()}) {
	$e->startTest($test);
    }
}

sub stop {
    my $self = shift;
    $self->{_Stop} = 1;
}

sub wasSuccessful {
    my $self = shift;
    return ($self->failureCount() == 0) && ($self->errorCount() == 0);
}

sub toString {
    my $self = shift;
    my $class = ref($self);
    print $class . "::toString() called\n" if DEBUG;
}

# ------------------------------------------------ 
package Test::Unit::TestSuite;
use constant DEBUG => 0;
use vars qw(@ISA);
@ISA=qw(Test::Unit::Test);

sub new {
    my $class = shift;
    my ($name) = @_;
    
    my @_Tests = ();
    my $self = {
	_Tests => \@_Tests,
	_Name => $name,
    };
    bless $self, $class;
    print ref($self) . "::new() called\n" if DEBUG;
    
    if (defined($name)) {
	no strict 'refs';
	my @candidates = grep /^test/, keys %{"$name" . "::"};
	for my $c (@candidates) {
	    if (defined(&{$name . "::" . $c})) {
		my $method = $name . "::" . $c;
		$self->addTestMethod($method);
	    }
	}
    } else {
	$self->addTest($self->warning("No tests found in $class"));
    }

    return $self;
}

sub addTest {
    my $self = shift;
    my ($test) = @_;
    push @{$self->tests()}, $test;
}

sub addTestMethod {
    my $self = shift;
    my ($testMethod) = @_;
    my ($class, $method) = ($testMethod =~ m/^(.*)::(.*)$/);
    no strict 'refs';
    my $aTestCaseSubClassInstance = "$class"->new($method);
    unless ($aTestCaseSubClassInstance) {
	$self->addTest($self->warning("addTestMethod: Could not call $class"."::"."new()"));
	return;
    }
    push @{$self->tests()}, $aTestCaseSubClassInstance;
}
 
sub countTestCases {
    my $self = shift;
    my $count = 0;
    for my $e (@{$self->tests()}) {
	$count += $e->countTestCases();
    }
    return $count;
}

sub run {
    my $self = shift;
    print ref($self) . "::run() called\n" if DEBUG;
    my ($result) = shift;
    for my $e (@{$self->tests()}) {
	last if $result->shouldStop();
	print ref($e) . "::_run(\$result) should be called\n" if DEBUG;
	$e->_run($result);
    }
}
    
sub testAt {
    my $self = shift;
    my ($index) = @_;
    return $self->tests()->[$index];
}

sub testCount {
    my $self = shift;
    return scalar @{$self->tests()};
}

sub tests {
    my $self = shift;
    return $self->{_Tests};
}

sub toString {
    my $self = shift;
    return $self->{_Name};
}

sub warning {
    my $self = shift;
    my ($message) = @_;
    return Test::Unit::TestCase->new("warning")->fail($message);
}

# ------------------------------------------------ 
package Test::Unit::TestRunner;
use constant DEBUG => 0;
use vars qw(@ISA);

@ISA = qw(Test::Unit::TestListener); # abstract interface needed here?

sub new {
    my $class = shift;
    my ($filehandle) = @_;
    $filehandle = \*STDOUT unless $filehandle;
    bless { _PrintStream => $filehandle }, $class;
}

sub printStream {
    my $self = shift;
    return $self->{_PrintStream};
}

sub _print {
    my $self = shift;
    my (@args) = @_;
    local *FH = *{$self->printStream()};
    print FH @args;
}

sub addError {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("E");
}
	
sub addFailure {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("F");
}

sub createTestResult {
    my $self = shift;
    return Test::Unit::TestResult->new();
}
	
sub doRun {
    my $self = shift;
    my ($suite, $wait) = @_;
    my $result = $self->createTestResult();
    $result->addListener($self);
    my $startTime = time();
    $suite->run($result);
    my $endTime = time();
    my $runTime = $endTime - $startTime;
    $self->_print("\nTime: ", $runTime, "\n");

    $self->printResult($result);
    
    if ($wait) {
	print "<RETURN> to continue"; # go to STDIN any case
	<STDIN>;
    }
    if (not $result->wasSuccessful()) {
	exit(-1);
    }
    exit(0);		
}

sub endTest {
    my $self = shift;
    my ($test) = @_;
}

sub extractClassName {
    my $self = shift;
    my ($classname) = @_;
    if ($classname =~ /^Default package for/) {
	# do something more sensible here
    }
    return $classname;
}

sub main {
    my $self = shift;
    my $aTestRunner = Test::Unit::TestRunner->new();
    $aTestRunner->start(@_);
}

sub printResult {
    my $self = shift;
    my ($result) = @_;
    $self->printHeader($result);
    $self->printErrors($result);
    $self->printFailures($result);
}

sub printErrors {
    my $self = shift;
    my ($result) = @_;
    if ($result->errorCount() != 0) {
	if ($result->errorCount == 1) {
	    $self->_print("There was ", $result->errorCount(), " error:\n");
	} else {
	    $self->_print("There were ", $result->errorCount(), " errors:\n");
	}
	my $i = 0; 
	for my $e (@{$result->errors()}) {
	    $i++;
	    $self->_print($i, ") ", $e->toString());
	}
    }
}

sub printFailures {
    my $self = shift;
    my ($result) = @_;
    if ($result->failureCount() != 0) {
	if ($result->failureCount == 1) {
	    $self->_print("There was ", $result->failureCount(), " failure:\n");
	} else {
	    $self->_print("There were ", $result->failureCount(), " failures:\n");
	}
	my $i = 0; 
	for my $e (@{$result->failures()}) {
	    $i++;
	    $self->_print($i, ") ", $e->toString());
	}
    }
}

sub printHeader {
    my $self = shift;
    my ($result) = @_;
    if ($result->wasSuccessful()) {
	$self->_print("\n", "OK", " (", $result->runCount(), " tests)");
    } else {
	$self->_print("\n", "!!!FAILURES!!!", "\n",
		      "Test Results:\n",
		      "Run: ", $result->runCount(), 
		      " Failures: ", $result->failureCount(),
		      " Errors: ", $result->errorCount(),
		      "\n");
    }
}

sub run {
    my $self = shift;
    my ($class) = @_;
    $self->_run(Test::Unit::TestSuite->new($class));
}
	
sub _run {
    my $self = shift;
    my ($test) = @_;
    my $aTestRunner = Test::Unit::TestRunner->new();
    $aTestRunner->doRun($test, 0);
}

sub runAndWait {
    my $self = shift;
    my ($test) = @_;
    my $aTestRunner = Test::Unit::TestRunner->new();
    $aTestRunner->doRun($test, 1);
}

sub start {
    my $self = shift;
    my (@args) = @_;

    my $testCase = "";
    my $wait = 0;

    for (my $i = 0; $i < @args; $i++) {
	if ($args[$i] eq "-wait") {
	    $wait = 1;
	} elsif ($args[$i] eq "-c") {
	    $testCase = $self->extractClassName($args[++$i]);
	} elsif ($args[$i] eq "-v") {
	    print "PerlUnit, draft version\n";
	} else {
	    $testCase = $args[$i];
	}
    }
    if ($testCase eq "") {
	print "Usage TestRunner.pl [-wait] testCaseName, where name is the name of the TestCase class", "\n";
	exit(-1);
    }

    eval "require $testCase" 
	or die "Suite class " . $testCase . " not found: $@";
    no strict 'refs';
    my $suite = "$testCase"->new();
    my $suiteMethod = \&{"$testCase" . "::" . "suite"};
    if ($suiteMethod) {
	$suite = Test::Unit::TestSuite->new($testCase);
    }
    $self->doRun($suite, $wait);
}

sub startTest {
    my $self = shift;
    my ($test) = @_;
    $self->_print(".");
}

# ------------------------------------------------ 
1;
