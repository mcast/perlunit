package Test::Unit::TestResult;
use strict;
use constant DEBUG => 0;

use Test::Unit::TestFailure;

sub new {
    my $class = shift;

    my @_Failures = ();
    my @_Errors = ();
    my @_Listeners = ();
    my $_Run_tests = 0;
    my $_Stop = 0;

    bless { 
	_Failures => \@_Failures,
	_Errors => \@_Errors,
	_Listeners => \@_Listeners,
	_Run_tests => $_Run_tests,
	_Stop => $_Stop,
    }, $class;
}

sub add_error { 
    my $self = shift;
    print ref($self) . "::add_error() called\n" if DEBUG;
    my ($test, $exception) = @_;
    push @{$self->errors()}, Test::Unit::TestFailure->new($test, $exception);
    for my $e (@{$self->listeners()}) {
	$e->add_error($test, $exception);
    }
}

sub add_failure {
    my $self = shift;
    print ref($self) . "::add_failure() called\n" if DEBUG;
    my ($test, $exception) = @_;
    push @{$self->failures()}, Test::Unit::TestFailure->new($test, $exception);
    for my $e (@{$self->listeners()}) {
	$e->add_failure($test, $exception);
    }
}

sub add_listener {
    my $self = shift;
    print ref($self) . "::add_listener() called\n" if DEBUG;
    my ($listener) = @_;
    push @{$self->listeners()}, $listener;
}

# change clone_listeners() to listeners()
sub listeners {
    my $self = shift;
    return $self->{_Listeners};
}
 
sub end_test {
    my $self = shift;
    for my $e (@{$self->listeners()}) {
	$e->end_test();
    }
}

sub error_count {
    my $self = shift;
    return scalar @{$self->{_Errors}};
}

sub errors {
    my $self = shift;
    return $self->{_Errors};
}
 
sub failure_count {
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
    $self->start_test($test);
    eval { 
	$test->run_bare(); 
    };
    my $exception = $@;
    if ($exception) {
	print ref($self) . "::run() caught exception: $exception\n" if DEBUG;
	if (ref($exception) eq "Test::Unit::ExceptionFailure") {
	    $self->add_failure($test, $exception);
	} else {
	    $self->add_error($test, $exception);
	}
    }
    $self->end_test($test);
} 

# I put run_protected() into run() above

sub run_count {
    my $self = shift;
    return $self->{_Run_tests};
}

sub should_stop {
    my $self = shift;
    return $self->{_Stop};
}
    
sub start_test {
    my $self = shift;
    my ($test) = @_;
    $self->{_Run_tests}++;
    for my $e (@{$self->listeners()}) {
	$e->start_test($test);
    }
}

sub stop {
    my $self = shift;
    $self->{_Stop} = 1;
}

sub was_successful {
    my $self = shift;
    return ($self->failure_count() == 0) && ($self->error_count() == 0);
}

sub to_string {
    my $self = shift;
    my $class = ref($self);
    print $class . "::to_string() called\n" if DEBUG;
}

1;
