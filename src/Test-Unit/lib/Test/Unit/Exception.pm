package Test::Unit::Exception;
use strict;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($message) = @_;
    
    my $i = 0;
    my $stacktrace = '';
    my ($pack, $file, $line, $subname, $hasargs, $wantarray);
    
    $message = '' unless defined($message);
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

1;
