# ------------------------------------------------ 
# the quintessential call tree
# ------------------------------------------------ 

$aTestCase->run() {
    $aTestCase->_run($aTestResult) {
	$aTestResult->run($aTestCase) { # catches exception and records it
	    $aTestCase->runBare() {
		$aTestCase->_runTest() {
		    # calls method $aTestCase->name() 
		    # and propagates exception
		    # method will call Assert::assert() 
		    # to cause failure on test assertion
		    # it finds this because $aTestCase is-a Assert
		}
	    }
	}
    }
}

# ------------------------------------------------ 
# reduced interface
# ------------------------------------------------ 

# ------------------------------------------------ 
package Test;

sub countTestCases { } # abstract
sub run { }            # abstract

# ------------------------------------------------ 
package Assert;

sub assert { } # calls fail()
sub fail { }   # calls croak()

# ------------------------------------------------ 
package TestListener;

sub addError { }   # abstract
sub addFailure { } # abstract
sub endTest { }    # abstract
sub startTest { }  # abstract

# ------------------------------------------------ 
package TestCase;
use vars qw(@ISA);
@ISA=qw(Assert Test);

sub new { }
sub countTestCases { }
sub name { }
sub run { } # calls _run 
sub setUp { }
sub tearDown { }
sub toString { }

sub _createResult { }
sub _run { } # calls $aTestResult->run($self)
sub _runBare { # called back from $aTestResult->run($self)
    my $self = shift;
    $self->setUp();
    eval {
	$self->_runTest();
    };
    $self->tearDown();
}
sub _runTest { } # calls method "name()" and propagates exception

# ------------------------------------------------ 
package TestResult;

sub new { }
sub addError { }
sub addFailure { }
sub addListener { }
sub cloneListeners { } 
sub endTest { } # call endTest($aTest) on each listener
sub errorCount { }
sub errors { } 
sub failureCount { } 
sub failures { }
sub run { # calls $aTestCase->runBare() 
    my $self = shift;
    my ($aTestCase) = @_;
    unless (eval { $aTestCase->runBare(); }) {
	# determine if exception is assertion failure or error
	# and add test to the collection of failures or errors
    }
    endTest();
} # 
# I put runProtected() into run() above
sub runCount { }
sub runTests { }
sub shouldStop { }
sub startTest { } # calls startTest($aTest) on each listener
sub stop { }
sub wasSuccessful { }

# ------------------------------------------------ 
package TestSuite;
use vars qw(@ISA);
@ISA=qw(Test);

sub new { } # overloaded:
            # convenience constructor for "package::test.*" suite
            # or return empty suite
sub addTest { } 
sub countTestCases { }
sub run { } # enumerates tests in suite and 
            # calls $aTest->run($aTestResult) for each of them
sub testAt { }
sub testCount { } 
sub tests { }
sub toString { }
sub warning { } # needed?
