package Test::Unit::InnerClass;

use strict;

use vars qw($SIGNPOST $HOW_OFTEN);
use Carp;

# we have a problem here to generate unique class names
# to avoid name clashes if we are used several times

if (defined($Test::Unit::InnerClass::SIGNPOST)) {
    ++$Test::Unit::InnerClass::HOW_OFTEN;
} else {
    $Test::Unit::InnerClass::SIGNPOST = 'I was here';
    $Test::Unit::InnerClass::HOW_OFTEN = 1;
}

{
    my $i = 0;

    sub next_inner_class_name {
        my $class = shift;
        return "$class\::LOAD$ {Test::Unit::InnerClass::HOW_OFTEN}_" . $i++;
    }
    
    sub make_inner_class {
        carp "make_inner_class is deprecated";
        my ($class, $extension_text, @constructor_args) = @_;
        $extension_text =~ s/(\s*\n)+\z//m; # trim trailing blank lines
        my $inner_class_name = $class->next_inner_class_name;
        my $code = <<EOEVAL;
package $inner_class_name;
use base qw($class);

$extension_text
EOEVAL
        chomp $code;
        
        eval $code;
        die <<EODIE if $@;
Failed to compile inner class: $@
Code follows:
--------- 8< --------- 8< ---------
$code
--------- 8< --------- 8< ---------
EODIE
        return $inner_class_name->new(@constructor_args);
    }
    
    sub make_coderef_inner_class {
        my($class, $extension_hash, @constructor_args) = @_;
        my $inner_class_name = $class->next_inner_class_name;
        eval qq{
                package $inner_class_name;
                use $class ();
                use base $class;
               };
        die "Compilation failed with error:\n$@" if $@;
        no strict 'refs';
        foreach my $method_name (keys %$extension_hash) {
            *{"$inner_class_name\::$method_name"} =
                $extension_hash->{$method_name};
        }
        unless (exists $ {"$inner_class_name\::"}{'super'}) {
            eval <<EOS;
                package $inner_class_name;
                sub super {
                    my \$self = shift;
                    my \$method = (caller(1))[3];
                    \$method =~ s/.*::/$class\::/;
                    \$self->\$method(\@_);
                }
EOS
            die "Compilation failed with error:\n $@" if $@;
        }
        return $inner_class_name->new(@constructor_args);
    } 
}
1;
__END__


=head1 NAME

Test::Unit::InnerClass - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to emulate the anonymous inner
classes feature of Java. It is much easier to port Java to Perl using
this class.

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

The JUnit testing framework by Kent Beck and Erich Gamma

=cut
