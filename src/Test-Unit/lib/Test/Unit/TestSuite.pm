package Test::Unit::TestSuite;
use strict;
use constant DEBUG => 0;
use base qw(Test::Unit::Test);

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
		$self->add_test_method($method);
	    }
	}
    } else {
	$self->add_test($self->warning("No tests found in $class"));
    }

    return $self;
}

sub add_test {
    my $self = shift;
    my ($test) = @_;
    push @{$self->tests()}, $test;
}

sub add_test_method {
    my $self = shift;
    my ($test_method) = @_;
    my ($class, $method) = ($test_method =~ m/^(.*)::(.*)$/);
    no strict 'refs';
    my $a_test_case_sub_class_instance = "$class"->new($method);
    unless ($a_test_case_sub_class_instance) {
	$self->add_test($self->warning("add_test_method: Could not call $class"."::"."new()"));
	return;
    }
    push @{$self->tests()}, $a_test_case_sub_class_instance;
}
 
sub count_test_cases {
    my $self = shift;
    my $count = 0;
    for my $e (@{$self->tests()}) {
	$count += $e->count_test_cases();
    }
    return $count;
}

sub run {
    my $self = shift;
    print ref($self) . "::run() called\n" if DEBUG;
    my ($result) = shift;
    for my $e (@{$self->tests()}) {
	last if $result->should_stop();
	print ref($e) . "::_run(\$result) should be called\n" if DEBUG;
	$e->_run($result);
    }
}
    
sub test_at {
    my $self = shift;
    my ($index) = @_;
    return $self->tests()->[$index];
}

sub test_count {
    my $self = shift;
    return scalar @{$self->tests()};
}

sub tests {
    my $self = shift;
    return $self->{_Tests};
}

sub to_string {
    my $self = shift;
    return $self->{_Name};
}

sub warning {
    my $self = shift;
    my ($message) = @_;
    return Test::Unit::Test_case->new("warning")->fail($message);
}

1;
