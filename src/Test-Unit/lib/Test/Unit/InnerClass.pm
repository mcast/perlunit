package Test::Unit::InnerClass;

use strict;

use vars qw($HOW_OFTEN);

# we have a problem here to generate unique class names
# to avoid name clashes if we are used several times

$HOW_OFTEN = 0 unless defined $HOW_OFTEN;
$HOW_OFTEN++;

{
    my $i = 0;
    sub make_inner_class_name {
        my $class = shift;
        my $base_class = shift;
        return $base_class . "::_Load${HOW_OFTEN}_ANON" . $i++;
    }
    
    sub make_inner_class {
        my $class = shift;
        my $base_class = shift;
        my $method = (ref($_[0]) eq 'HASH') ? 'make_inner_class_with_coderefs' :
                                              'make_inner_class_with_text';
        $class->$method($base_class, @_);
    }
    
    sub make_inner_class_with_text {
        my ($class, $base_class, $extension_text, @constructor_args) = @_;
        $extension_text =~ s/(\s*\n)+\z//m; # trim trailing blank lines
            $i++;
        my $inner_class_name = $class->make_inner_class_name($base_class);
        my $code = <<EOEVAL;
package $inner_class_name;
use base qw($base_class);

$extension_text
EOEVAL
        chop $code;
        
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

    sub make_inner_class_with_coderefs {
        my($class, $base_class, $method_hash, @constructor_args) = @_;
        my $inner_class_name = $class->make_inner_class_name($base_class);
        eval qq{package $inner_class_name; use base qw($base_class)};
        die $@ if $@;

        foreach my $method (keys %$method_hash) {
            no strict 'refs';
            *{"$inner_class_name\::$method"} = $method_hash->{$method};
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
