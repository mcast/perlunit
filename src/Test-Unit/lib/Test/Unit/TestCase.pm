package Test::Unit::TestCase;
use strict;
use constant DEBUG => 0;

use base qw(Test::Unit::Test);

use Test::Unit::ExceptionFailure; 
use Test::Unit::ExceptionError; 

sub new {
    my $class = shift;
    my ($name) = @_;
    bless { _name => $name }, $class;
}

sub count_test_cases {
    my $self = shift;
    return 1;
}

sub create_result {
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
    my ($result) = @_;
    $result = create_result() unless defined($result);
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

sub run_bare {
    my $self = shift;
    print ref($self) . "::run_bare() called\n" if DEBUG;
    $self->set_up();
    eval {
	$self->run_test();
    };
    my $exception = $@;
    $self->tear_down();
    if ($exception) {
	print ref($self) . "::_run_bare() propagating exception\n" if DEBUG;
	if (not $exception->isa("Test::Unit::ExceptionFailure")) {
	    $exception = Test::Unit::ExceptionError->new($exception);
	}
	die $exception; # propagate exception
    }
}

sub run_test {
    my $self = shift;
    print ref($self) . "::run_test() called\n" if DEBUG;
    my $class = ref($self);
    my $method = $self->name();
    no strict 'refs';
    print "Should now call $class\:\:$method\n" if DEBUG;
    if ($class->can($method)) {
	&{$class . "::" .$method}($self);
    } else {
	$self->fail("Method $method not found");
    }
}

sub set_up {
}

sub tear_down {
}

sub to_string {
    my $self = shift;
    my $class = ref($self);
    return $self->name() . "(" . $class . ")";
}

1;
