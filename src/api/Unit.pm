use strict;

# ------------------------------------------------ 
package Test::Unit::Test;
use constant DEBUG => 1;

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
package Test::Unit::Assert;
use constant DEBUG => 1;

sub assert {
    my $self = shift;
    print ref($self) . "::assert() called\n" if DEBUG;
    my ($condition, $message) = @_;
    $message = "Assertion failed: " . $message;
    $self->fail($message) unless $condition;
}

sub fail {
    my $self = shift;
    print ref($self) . "::fail() called\n" if DEBUG;
    my ($message) = @_;
    carp $message;
}


# ------------------------------------------------ 
package Test::Unit::TestCase;
use constant DEBUG => 1;
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
    $self->tearDown();
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
package Test::Unit::TestFailure;
use constant DEBUG => 1;

sub new {
    my $class = shift;
    my ($test, $exception);
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
    return $self->failedTest()->toString() . ": " . $self->thrownException;
}

# ------------------------------------------------ 
package Test::Unit::TestResult;
use constant DEBUG => 1;

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
    my ($test, $exception) = @_;
    push @{$self->errors()}, Test::Unit::TestFailure->new($test, $exception);
    for my $e (@{$self->listeners()}) {
	$e->addError($test, $exception);
    }
}

sub addFailure {
    my $self = shift;
    my ($test, $exception) = @_;
    push @{$self->failures()}, Test::Unit::TestFailure->new($test, $exception);
    for my $e (@{$self->listeners()}) {
	$e->addFailure($test, $exception);
    }
}

sub addListener {
    my $self = shift;
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
    unless (eval { $test->runBare() }) {
	my $exception = $@;
	if ($exception =~ /^Assertion failed: /) {
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
    return (testFailures() == 0) && (testErrors() == 0);
}

# ------------------------------------------------ 
package Test::Unit::TestSuite;
use constant DEBUG => 1;
use vars qw(@ISA);
@ISA=qw(Test::Unit::Test);

sub new {
    my $class = shift;
    my ($name) = @_;
    
    my @_Tests = ();
    my $self;
    
    if (defined($name)) {
	# create_suite here
    } else {
	$self = {
	    _Tests => \@_Tests,
	    _Name => $name,
	};
    }
    
    bless $self, $class;
}

sub addTest {
    my $self = shift;
    my ($test) = @_;
    push @{$self->tests()}, $test;
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
	last if $result.shouldStop();
	$e->run($result);
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

1;
