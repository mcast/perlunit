package Test::Unit::tests::TestAssertCodeRef;
use strict;

use base qw(Test::Unit::TestCase);

sub test_case_to_string {
    my $self = shift;
    $self->coderef_assert(sub {
                              my $self = shift;
                              $self->to_string eq shift;
                          }, $self,
                          "test_noy_to_string(" . ref($self) . ")");
}




1;
