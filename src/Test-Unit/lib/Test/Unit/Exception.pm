package Test::Unit::Exception;
use strict;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($message) = @_;
    
    $message = '' unless defined($message);
    $message = ref($class) . ": " . $message . "\n";

    my $i = 0;
    my $stacktrace = '';
    my ($pack, $file, $line, $subname, $hasargs, $wantarray);
    
    while (($pack, $file, $line, $subname, 
	    $hasargs, $wantarray) = caller(++$i)) {
	$stacktrace .= "Level $i: in package '$pack', file '$file', at line '$line', sub '$subname'\n";
    }
    
    bless { _message => $message, _stacktrace => $stacktrace }, $class;
}

sub stacktrace {
    my $self = shift;
    return $self->{_stacktrace};
}

sub get_message {
    my $self = shift;
    return $self->{_message};
}

sub to_string {
    my $self = shift;
    return $self->get_message() . $self->stacktrace();
}

1;
