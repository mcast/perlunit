package Test::Unit::Debug;

use strict;

use base 'Exporter';
use vars qw(@EXPORT_OK);
@EXPORT_OK = qw(debug debug_pkg no_debug_pkg debug_pkgs no_debug_pkgs debugged);

my %DEBUG = ();

sub debug {
    my ($package, $filename, $line) = caller();
    print STDERR @_ if $DEBUG{$package};
}

sub debug_pkg {
    $DEBUG{$_[0]} = 1;
}

sub debug_pkgs {
    $DEBUG{$_} = 1 foreach @_;
}

sub no_debug_pkg {
    $DEBUG{$_[0]} = 0;
}

sub no_debug_pkgs {
    $DEBUG{$_} = 0 foreach @_;
}

sub debugged {
    my ($package, $filename, $line) = caller();
    return $DEBUG{$_[0] || $package};
}

1;
