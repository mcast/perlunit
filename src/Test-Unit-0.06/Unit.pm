package Test::Unit;

use strict;
use vars qw($VERSION);

$VERSION = '0.06';

# Preloaded methods go here.

# class data - private

my $_testcase_number = 0; # for generating default names for testcases

# class methods - public

sub assert($$) {
    my $pkg = shift;
    unless (shift()) {
	no strict 'vars'; # sneaky way to communicate with caller
	$_results{ok} = 0;
	${$_results{failures}}{$_current_testcase} =
	    sprintf("assert() failed in package '%s', file '%s', line %s", 
		    caller());  
    }
}

sub new {
    my $pkg = shift;
    my $self = { @_ };

    if (not (exists $self->{name})) {
	$self->{name} = "Testcase " . ++$_testcase_number;
    }
    $self->{_suite} = {};
    $self->{_results} = {};

    bless($self, $pkg);
    
    if (exists $self->{test}) {
	my $user_test = $self->{test};
	$self->{test} = sub { 
	    no strict 'vars'; # sneaky way to communicate with assert()
	    local $_current_testcase = $self->name(); 
	    local %_results = %{ $self->_get_results() }; 
	    $user_test->(); 
	    $self->_set_results(\%_results);
	};
    }

    return $self;
}

sub create_suite {
    my $pkg = shift;
    my $properties = { @_ };
    my $test_package_name;
    
    if (not exists $properties->{package}) {
	$test_package_name = caller();
    } else {
	$test_package_name = $properties->{package};
    }
    delete($properties->{package});

    if (not exists $properties->{name}) {
	$properties->{name} = $test_package_name;
    }
    
    my $testcase = $pkg->new(%{$properties});

    no strict 'refs';
    my @candidates = grep /^test/, keys %{"$test_package_name" . "::"};
    for my $c (@candidates) {
	if (defined(&{$test_package_name . "::" . $c})) {
	    my $name = $test_package_name . "::" . $c;
	    my %props = (name => $name,
			 test => \&{$test_package_name . "::" . $c},
			 );
	    if (exists $properties->{setup}) {
		$props{setup} =  $properties->{setup};
	    }
	    if (exists $properties->{teardown}) {
		$props{teardown} =  $properties->{teardown};
	    }
	    $testcase->add($pkg->new(%props));
	}
    }

    return $testcase;
}

# object methods - public

sub name {
    my $self = shift;
    return $self->{name};
}

sub run {
    my $self = shift;
    $self->_run();
    $self->_report_results();
}

sub add {
    my $self = shift;
    my ($testcase) = @_;
    $self->{_suite}->{$testcase->name()} = $testcase;
}

# object methods - private

sub _run {
    my $self = shift;
    $self->_runtest();
    if (exists $self->{_suite}) {
	for my $t (sort keys %{$self->{_suite}}) {
	    $self->{_suite}->{$t}->_run();
	}
    }
}
    
sub _runtest {
    my $self = shift;

    $self->_init_results();
    
    $self->{setup}->() if exists $self->{setup};
    $self->{test}->() if exists $self->{test};
    $self->{teardown}->() if exists $self->{teardown};
    
    $self->_record_results();
}

# this results thingie should really be a separate object

sub _get_results {
    my $self = shift;
    return $self->{_results};
}

sub _set_results {
    my $self = shift;
    my $state = shift;
    $self->{_results} = $state;
}

sub _init_results {
    my $self = shift;
    my %_results = ( tests => 0, ok => 1, failures => {}, );
    $self->_set_results(\%_results);
}

sub _record_results {
    my $self = shift;
    return unless exists $self->{test};

    my %_results = %{ $self->_get_results() };
    if ($_results{ok}) {
	print ".";
    } else {
	print "F";
    }
    ++$_results{tests};
    $self->_set_results(\%_results);
}

sub _accumulate_results {
    my $self = shift;

    my %_results = %{ $self->_get_results() };
    
    if (exists $self->{_suite}) {
	for my $t (sort keys %{$self->{_suite}}) {
	    my %subres = %{ $self->{_suite}->{$t}->_accumulate_results() };
	    $_results{tests} += $subres{tests};
	    $_results{ok} = ($_results{ok} && $subres{ok}) ? 1 : 0;
	    for my $st (sort keys %{ $subres{failures} }) {
		$_results{failures}->{$st} = $subres{failures}->{$st};
	    }
	}
    }
    
    $self->_set_results(\%_results);

    return $self->_get_results();
}

sub _report_results {
    my $self = shift;
    my %_results = %{ $self->_accumulate_results() };
    
    if (not (keys %{$_results{failures}})) {
	printf("\nOK (%d %s)\n", $_results{tests}, 
	       $_results{tests} == 1 ? "test" : "tests");
    } else {
	my $n_failures = scalar(keys %{ $_results{failures} });
	printf("\n!!!FAILURES!!!\nTest Results:\nRun: %d Failures: %d\n",
	       $_results{tests}, $n_failures);
	printf("There %s %d %s:\n", 
	       $n_failures == 1 ? "was" : "were",
	       $n_failures,
	       $n_failures == 1 ? "failure" : "failures");
	my $n = 0;
	for my $t (sort keys %{$_results{failures}}) {
	    printf("%d) Testcase '%s': %s\n", 
		   ++$n,
		   $t,  
		   $_results{failures}->{$t});
	}
    }
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Test::Unit - Simple Framework for Unit Testing

=head1 SYNOPSIS

  use Test::Unit;

  # the lazy way

  sub test_ok { Test::Unit->assert(1 == 1) };
  sub test_fail { Test::Unit->assert(23 == 42) };
  Test::Unit->create_suite()->run(); 

  # the convenient way to provide test fixture

  my $setup = sub { print STDERR "Creating fixture ...\n" };
  my $teardown = sub { print STDERR "Cleaning up ...\n" };
  Test::Unit->create_suite(setup => $setup, 
			   teardown => $teardown)->run();

  # the detailed way

  my $test_ok = sub { Test::Unit->assert(1 == 1) };
  my $test_fail = sub { Test::Unit->assert(23 == 42) };
  my $testcase_ok = new Test::Unit(name => "Testcase 1",
				test => $test_ok,
				setup => $setup,
				teardown => $teardown,
				);
  $testcase_ok->run(); 
  my $testcase_fail = new Test::Unit(name => "Testcase 2",
				test => $test_fail,
				setup => $setup,
				teardown => $teardown,
				);
  $testcase_fail->run();
  $testcase_ok->add($testcase_fail);
  $testcase_ok->run(); 

=head1 DESCRIPTION

Test::Unit provides a simple framework for convenient unit testing.

You test a given unit (a script, a module, whatever) by creating 
a new Test::Unit object and configuring this object with three
subroutine references: the test to run, a setup to provide
resources you need for the test, and a corresponding teardown of
the resources created in the setup routine. You may omit any of
these.

You can build trees of test suites by adding Test::Unit objects
to each other by calling the add() method. A Test::Unit object
will run all tests for all Test::Unit objects added to it.

For convenience, you can automatically build a test suite for a 
given package by calling Test::Unit->create_suite(). This 
will build a test case for each subroutine in the package given
that has a name starting with "test" and pack them all together
into one Test::Unit object for easy testing. If you dont give
a package name to Test::Unit->create_suite(), the current package
is taken as default.

Test output is one status line (a "." for every successful test run,
or an "F" for any failed test run, to indicate progress), one result
line ("OK (n tests)" or "!!!FAILURES!!!"), and possibly many lines 
reporting detailed error messages for any failed tests.

=item B<assert()>

    Verify if a condition holds. No options. Must be called via
    the package name.

    Example:

    Test::Unit->assert(1 == 1);


=item B<new()>

    Create new Test::Unit objects. Options are:
    
    name:     A name for the testcase.
    test:     A reference to a subroutine that does the testing
              for the testcase. Will often call Test::Unit->assert().
    setup:    A reference to a subroutine that prepares resources 
              needed for testing. The subroutine will be called for 
              each test case in a suite.
    teardown: A reference to a subroutine that cleans up 
              resources used for testing. The subroutine will be 
              called for each test case in a suite.
    
    Examples:
    
    my $obj = Test::Unit->new(test => $test);

    my $obj = Test::Unit->new(name => $name, 
			      test => $test, 
			      setup => $setup, 
			      teardown => $teardown,
			      );


=item B<create_suite()>

    Create a new Test::Unit object that contains testcases for all 
    subroutines in the package given that have names starting with
    "test". Options are:
    
    package:  The package to test. Defaults to the current package.
    name:     A name for the testcase.
    test:     A reference to a subroutine that does the testing
              for the testcase. Will often call Test::Unit->assert().
    setup:    A reference to a subroutine that prepares resources 
              needed for testing. The subroutine will be called for 
              each test case in a suite.
    teardown: A reference to a subroutine that cleans up 
              resources used for testing. The subroutine will be 
              called for each test case in a suite.
    
    Examples:
    
    my $obj = Test::Unit->create_suite();
    
    my $obj = Test::Unit->create_suite(package => $pkg,
				       name => $name, 
				       test => $test, 
				       setup => $setup, 
				       teardown => $teardown,
				       );

=item B<run()>

    Call a Test::Unit object to run its tests. No Options.

    Example:
    
    my $obj = Test::Unit->create_suite();
    $obj->run();


=item B<add()>

    Add a Test::Unit object to the test suite of another Test::Unit
    object. The object that is called with this method will
    perform its own test first, then it will call its children
    to perform their tests. 

    Example:

    my $parent = Test::Unit->create_suite();
    my $child1 = Test::Unit->new(name => "child2", test => $child2_test);
    my $child2 = Test::Unit->new(name => "child2", test => $child2_test);
    $parent->add($child1);
    $parent->add($child2);
    $parent->run(); # will also run $child1 and $child2
    

=head1 AUTHOR

Christian Lemburg <lemburg@acm.org>

=head1 SEE ALSO

Refactoring. Improving The Design Of Existing Code. 
Martin Fowler. Addison-Wesley, 1999.

http://www.xProgramming.com/

=cut
