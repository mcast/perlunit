#!/usr/local/bin/perl -w
use strict;

package XUnit;

=head1 NAME

XUnit - a port of Kent Beck's object oriented unit test package.

=head1 SYNOPSIS

    # Subclass XUnit;
    #
    package Foo;
    use XUnit;
    use vars qw(@ISA);
    @ISA = qw(XUnit);
    
    # Create one or more routines whose names match /^test./
    #
    sub test_bar { 
       my ($self, $baz) = @_;
       $self->assert(2+2 == 4);                 # Die unless 2+2 == 4
       $self->deny($baz =~ /gern/ && 14 > 42);  # Die if condition is true
       my $w = warning { ... };                  # Trap and return warnings
    }
   
    # Optionally create a set_up routine to create a test environment and
    # a tear_down routine to free any resources the setup uses.
    #
    sub set_up { ... }
    sub tear_down { ... }


    $suite = Foo->suite;             # Create a test suite with all the
                                    #    Foo:test... routines

                         - or -

    $suite = XUnit::Suite->new  # Create an empty test suite
    $suite->add_test("test_bar");     # and add routines one by one
    $suite->add_test("test_baz");

    $result = $suite->run;           # Run all tests and record defects

    if ($result->has_passed) {...}

    @defects = $result->defects      # List of errors and failures
    @errors = $result->errors        # Just errors (deaths and warnings)
    @failures = $result->failures    # Just failures (e.g. assert false)

    print $result->brief_report     # Names and location of unsuccessful tests
    print $result->full_report      # ...as above, and also full error messages

    $success_count = $result->successes
    $run_count = $result->runs

=head1 DESCRIPTION

This is a port of SUnit 2.3 (TBD: Recycle comments from SUnit here.)

=cut

require 5.003;
require Exporter;
use overload '""' => \&as_string;

use vars qw(@EXPORT @ISA $VERSION);
@EXPORT = qw(exception warnings);
@ISA = qw(Exporter);
$VERSION = '0.01';

# XUnit routine to trap warnings
#
# Calling is non-OO so that we can use prototypes. E.g.
#
#     $w = warnings { my $x; $y = $x+2 };
#
# instead of
#
#     $w = $self->warnings(sub { my $x; $y = $x+2 });

sub warnings (&) {
   my ($a_block) = @_;
   my $warnings = "";
   local $SIG{__WARN__} = sub { $warnings .= $_[0] };
   &$a_block;
   return $warnings;
}

# XUnit methods for signaling

sub failure_signal { goto &XUnit::Signal::failure_signal }
sub warning_signal { goto &XUnit::Signal::warning_signal }
sub death_signal   { goto &XUnit::Signal::death_signal }

# XUnit methods for asserting
 
sub assert {
   my $self = shift;
   my $a_boolean = shift;
   unless ($a_boolean) {
      @_ or @_ = caller;
      my ($file_name, $line_number) = @_[1,2];
      my $assertion = $self->_find_assertion($file_name, $line_number);
      die $self->failure_signal($assertion, @_);
   }
}

sub _find_assertion {
   my ($self, $file_name, $line_number) = @_;
   my $line;
   if (open SOURCE, "<$file_name") {
      my $j;
      for ($j =0; $j != $line_number; $j++) {
         defined($line = <SOURCE>) or last; 
      }
   }
   close SOURCE;

   defined($line) && $line =~ /\bassert/
      or return "[Can't find assertion in source code]";

   $line =~ s/^\s+//; 
   $line =~ s/\s+$//;

   return $line;
}

sub deny {
   my ($self, $a_boolean) = @_;
   $self->assert(! $a_boolean, caller);
}

# XUnit methods for running

sub debug {
    ref $_[0] or goto &_Debug;
    my ($self) = @_;
    $self->run_case;
}

sub run {
    ref $_[0] or goto &_Run;
    my ($self, $result) = @_;
    $result ||= XUnit::Result->new;
    $result->run_case($self);
    return $result;
}

sub run_case {
   my $self = shift;
   my $method = $self->{TestMessage};

   local $SIG{__WARN__} = sub {
      die $self->warning_signal($_[0], caller);
   };

   local $SIG{__DIE__} = sub {
      die $self->death_signal($_[0], caller);
   };

   eval {
      $self->set_up;
      $self->$method();
   };
   my $error = $@;
   eval { $self->tear_down };

   $error ||= @_; 
   die $error if $error;

   return $self;
}  
   
sub set_up { return $_[0] }

sub tear_down { return $_[0] }

# XUnit methods for printing

sub as_string { return $_[0]->{TestMessage} }

# XUnit class methods for instance creation

sub _Debug {
   my ($class, $a_symbol) = @_;
   $class->selector($a_symbol)->debug;
}

sub _Run {
   my ($class, $a_symbol) = @_;
   $class->selector($a_symbol)->run;
}

sub selector {
   my ($class, $routine_name) = @_;
   $routine_name =~ /::/ or $routine_name = $class."::".$routine_name;
   bless {TestMessage => $routine_name}, $class;
}

sub suite {
   my ($class) = @_;
   $class = ref $class if ref $class;
   my $result = XUnit::Suite->new;
   my $method;
   foreach $method ($class->_all_tests) {
      $result->add_test($class->selector($method));
   }
   return $result;
}

sub _all_tests {
   my($class) = @_ ;
   $class = ref $class if ref $class;
   my @tests;
   no strict;
   while (($key,$val) = each(%{*{"$class\::"}})) {
      defined $val or next;
      local(*ENTRY) = $val;
      if (defined *ENTRY{CODE} && $key =~ /^test./) {
         push @tests, "$class\::$key";
      }
   }
   return @tests;
}

package XUnit::Result;
use overload '""' => \&as_string;

# XUnit::Result class methods for instance creation

sub new {
   my ($class) = @_;
   bless {RunCount => 0, Defects => []}, $class;
}

# XUnit::Result methods for accessing

sub successes {
   return $_[0]->runs - $_[0]->defects;
}

sub runs { return $_[0]->{RunCount} }

sub defects { return @{$_[0]->{Defects}} }
sub errors { return grep { $_->is_error } $_[0]->defects }
sub failures { return grep { $_->is_failure } $_[0]->defects }

# XUnit::Result methods for running

sub run_case {
   my ($self, $a_test_case) = @_;
   $$self{RunCount}++;
   eval { $a_test_case->run_case };
   if ($@) { push @{$self->{Defects}}, XUnit::Signal->new($@) }
}

# XUnit::Result methods for printing

sub as_string {
   my ($self) = @_;
   my $string = $self->runs." run, ".$self->failures." failed, "
              .$self->errors." errors.";
   $string =~ s/1 errors/1 error/;
   return $string;
}

sub brief_report {
   my ($self) = @_;
   return map { $_->brief_report } $self->defects;
}

sub full_report {
   my ($self) = @_;
   return map { $_->full_report } $self->defects;
}

# XUnit::Result methods for testing

sub has_passed {
   my ($self) = @_;
   return $self->successes == $self->runs;
}

package XUnit::Suite;

# XUnit::Suite class methods for instance creation

sub new {
   my ($class) = @_;
   bless [], $class;
}

# XUnit::Suite methods for accessing

sub add_test {
   my ($self, $test) = @_;
   push @$self, $test;
}

sub tests { return @{$_[0]} }

# XUnit::Suite methods for running

sub run {
   my ($self, $result) = @_;
   $result ||= XUnit::Result->new;
   my $test;
   foreach $test (@$self) {
      $test->run($result);
   }
   return $result;
}

package XUnit::Signal;

use Carp;
use overload '""' => \&as_string;

use vars qw($_SIGNAL_TAG $_DIED $_WARNED $_FAILED);
   *_SIGNAL_TAG =  \"\cG";
   *_DIED =        \"Died";
   *_WARNED =      \"Warned";
   *_FAILED =      \"Failed";

# Since Perl doesn't support |die $object| until 5.005 (where it's documented
# to be undocumented and experimental), we do some strange things here.  The
# actual items passed to |die| will be strings, with fields separated by
# $_SIGNAL_TAG.i
#
# After we're finished dying and propagating the deaths, we can use the new()
# method and pass it the $@ we retrieve from eval { ... }.  The new() method
# breaks out the fields and puts them into a blessed hash.

# XUnit::Signal class methods for instance creation

sub new {
   my ($class, $signal_string) = @_;
   
   my ($kind, $test, $package, $file_name, $line_number, @rest) =
      split($_SIGNAL_TAG, $signal_string);

   @rest or return $class->
      new(death_signal("Unknown", $signal_string, caller));
             
   return bless {
         Kind => $kind,
         Test => $test,
         FromPackage => $package,
         FileName => $file_name,
         Line => $line_number,
         Description => join("", @rest)
      },
      $class;
}

# XUnit::Signal methods for accessing

sub kind { return $_[0]->{Kind} }
sub test { return $_[0]->{Test} }
sub from_package { return $_[0]->{FromPackage} }
sub filename { return $_[0]->{FileName} }
sub line { return $_[0]->{Line} }
sub description { return $_[0]->{Description} }

sub is_failure { return $_[0]->kind eq $_FAILED }
sub is_error { return $_[0]->kind eq $_DIED || $_[0]->kind eq $_WARNED }

# XUnit::Signal methods for printing

sub brief_report {
   my ($self) = @_;
   return "$$self{Kind}: $$self{Test} at $$self{FileName} line $$self{Line}\n";
}

sub full_report {
   my ($self) = @_;
   return $self->brief_report . "\t" . $$self{Description}
}

sub as_string { return $_[0]->full_report }

# XUnit::Signal non-OO routines for creating signal strings
#

sub failure_signal { return tagged_signal($_FAILED, @_) }
sub warning_signal { return tagged_signal($_WARNED, @_) }
sub death_signal   { return tagged_signal($_DIED, @_) }

sub tagged_signal {

   my ($faux_pas, $test, $description, $package, $file_name, $line_number) = @_;

   # Don't re-tag a tagged signal
   #
   return $description if $description =~ /^\w+$_SIGNAL_TAG/o;

   foreach (\$package, \$file_name, \$line_number) { defined $$_ or $$_ = "??" }

   chomp $description;
   $description .= "\n";

   return join($_SIGNAL_TAG,
      $faux_pas,
      "$test",
      $package,
      $file_name,
      $line_number,
      $description
      );
}

1;
