package Test::Unit::tests::TestInnerClass;

use base qw(Test::Unit::TestCase);
use Test::Unit::InnerClass;

sub test_inner_class_multiple_load {
    my $self = shift;
    
    $self->assert(defined($Test::Unit::InnerClass::SIGNPOST));
    
    do '../TestInnerClass.pm'; # we must load it again to check, sorry
    my $innerclass1 = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", << 'EOIC', "innerclass1");
EOIC
    do '../TestInnerClass.pm'; # require would not load it - it caches
    my $innerclass2 = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", << 'EOIC', "innerclass2");
EOIC

    $self->assert(ref($innerclass1) ne ref($innerclass2));
}

1;
