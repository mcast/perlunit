#!/usr/local/bin/perl -w
package TestXUnit;
use strict;
use XUnit;
use vars qw(@ISA);
@ISA= qw(XUnit);

# TT methods for running

sub set_up { $_[0]->{HasSetup}= 1 }

sub has_set_up { return $_[0]->{HasSetup} }

sub test_assert {
   my ($self)= @_;
   $self->assert(1);
   $self->deny(0);
}

sub test_debug {
   my ($self)= @_;
   return $self if $self->is_in_production;
   $self->fail;
}

# TT private methods

sub die { die }

sub warn { warn }

sub fail {
    my ($self)= @_;
    $self->assert(0);
}

sub noop { return $_[0] }

sub set_run { $_[0]->{HasRun}= 1 }
sub has_run { return $_[0]->{HasRun} }

use vars qw($fail_deliberately);
sub is_in_production { return ! $fail_deliberately }
sub fail_deliberately { $fail_deliberately = 1 }

# TT methods for testing

sub test_defects {
   my ($self)= @_;
   my $suite= XUnit::Suite->new;
   my $class= ref $self;
   $suite->add_test($class->selector("die"));
   $suite->add_test($class->selector("warn"));
   $suite->add_test($class->selector("fail"));
   my $result= $suite->run;
   my ($death, $warning, $failure, $none)= $result->defects;
   $self->assert(! defined($none));
   $self->assert($death->is_error);
   $self->assert($death->brief_report =~ /::die\b/);
   $self->assert($warning->is_error);
   $self->assert($warning->brief_report =~ /::warn\b/);
   $self->assert($failure->is_failure);
   $self->assert($failure->brief_report =~ /::fail\b/);
}

sub test_die { $_[0]->_test_error("die") }
sub test_warn { $_[0]->_test_error("warn") }

sub _test_error {
   my ($self, $method)= @_;
   my $result= $self->_single_test($method);
   $self->assert($result->successes == 0);
   $self->assert($result->failures == 0);
   $self->assert($result->errors == 1);
}

sub _single_test {
   my ($self, $method)= @_;
   my $class= ref $self;
   my $case= $class->selector($method);
   my $result= $case->run;
   $self->assert($result->runs == 1);
   return $result;
}

sub test_fail {
   my ($self)= @_;
   my $result= $self->_single_test("fail");
   $self->assert($result->successes == 0);
   $self->assert($result->failures == 1);
   $self->assert($result->errors == 0);
}

sub test_ran {
   my ($self)= @_;
   my $class= ref $self;
   my $case= $class->selector("set_run");
   $case->run;
   $self->assert($case->has_set_up);
   $self->assert($case->has_run);
}

sub test_suite {
   my ($self)= @_;
   my $class= ref $self;

   my $suite= XUnit::Suite->new;
   $suite->add_test($class->selector("noop"));
   $suite->add_test($class->selector("fail"));

   my $result= $suite->run;
   $self->assert($result->runs == 2);
   $self->assert($result->successes == 1);
   $self->assert($result->failures == 1);
}

unless (caller) {
   TestXUnit->fail_deliberately if @ARGV;
   my $suite= TestXUnit->suite;
   my $results= $suite->run;
   exit 0 if $results->has_passed;
   print $results->brief_report;
   print "-------------------\n";
   print $results->full_report;
   exit 1;
}   

1;
