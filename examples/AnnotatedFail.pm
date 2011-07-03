package AnnotatedFail;

use strict;

use base 'Test::Unit::TestCase';

sub test_witter {
  my ($self) = @_;
  $self->annotate("Well it worked up to a certain point\n".
		  "Then it broke with a tinkly crunch.");
  $self->fail('crunch');
}

sub test_justfine {
  my ($self) = @_;
  $self->annotate("We could make some noise here, but the test passes,\n",
		  "so it doesn't matter how big the noise is.");
}

sub test_BZZT {
  my ($self) = @_;
  $self->annotate("I was just wondering what this red button did.\n",
		  "It said 'Do not press'");
  $self->annotate("\nIt looks very tempting");
  die "BZZT";
}

sub test_ok1 {}
sub test_ok2 {}

1;
