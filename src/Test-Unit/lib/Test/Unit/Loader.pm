package Test::Unit::Loader;

use strict;

use constant DEBUG => 0;

use FileHandle;
use Test::Unit::TestSuite;
use Test::Unit::TestCase;
use Test::Unit::UnitHarness;
use Test::Unit::Warning;

# should really do something in here about a local @INC.
sub obj_load { shift; load(@_) }

# Compiles a target.  Returns the package if successful.
sub compile {
    my $target = shift;
    print "Test::Unit::Loader::compile($target) called\n" if DEBUG;

    if ($target =~ /^\w+(::\w+)*$/) {
        compile_class($target);
        return $target;
    }
    elsif ($target =~ /\.pm$/) {
        compile_file($target);
        # In this case I need to figure out what the class was I just loaded!
        return get_package_name_from_file($target);        
    }
    else {
        return undef;
    }
}

sub compile_class {
    my $classname = shift;
    print "  Test::Unit::Loader::compile_class($classname) called\n" if DEBUG;
    # Check if the package exists already.
    {
        no strict 'refs';
        if (my @keys = keys %{"$classname\::"}) {
            print "    package $classname already exists (@keys); not compiling.\n"
                if DEBUG;
            return;
        }
    }
    # No? Try 'require'ing it
    eval "require $classname";
    die $@ if $@;
    print "    $classname compiled OK as class name\n" if DEBUG;
}

sub compile_file {
    my $file = shift;
    print "  Test::Unit::Loader::compile_file($file) called\n" if DEBUG;
    eval qq{require "$file"};
    die $@ if $@;
    print "    $file compiled OK as filename\n" if DEBUG;
}

sub load {
    my $target = shift;
    print "Test::Unit::Loader::load($target) called\n" if DEBUG;

    my $suite = load_test($target)
             || load_test_harness_test($target)
             || load_test_dir($target);
    return $suite if $suite;

    die "Couldn't load $target in any of the supported ways";
}

sub load_test {
    my $target = shift;
    print "Test::Unit::Loader::load_test($target) called\n" if DEBUG;
    my $package = compile($target);
    print "  compile returned $package\n" if DEBUG;
    return unless $package;
    my $suite = load_test_suite($package) || load_test_case($package);
    die "`$target' was not a valid Test::Unit::Test\n" unless $suite;
    return $suite;
}

sub load_test_suite {
    my $package = shift;
    print "  Test::Unit::Loader::load_test_suite($package) called\n" if DEBUG;
    if ($package->can("suite")) {
        print "  $package has a suite() method\n" if DEBUG;
        return $package->suite();
    } 
}

sub load_test_case {
    my $package = shift;
    print "  Test::Unit::Loader::load_test_case($package) called\n" if DEBUG;
    if ($package->isa("Test::Unit::TestCase")) {
        print "  $package isa Test::Unit::TestCase\n" if DEBUG;
        return Test::Unit::TestSuite->new($package);
    } 
}

sub extract_testcases {
    my $classname = shift;

    my @testcases = ();

    foreach my $method ($classname->list_tests()) {
        if ( my $a_class_instance = $classname->new($method) ) {
            push @testcases, $a_class_instance;
        }
        else {
            push @testcases, Test::Unit::Warning->new(
                "extract_testcases: Couldn't create a $classname object"
            );
        }
    }

    push @testcases, Test::Unit::Warning->new("No tests found in $classname")
        unless @testcases;

    return @testcases;
}

sub load_test_harness_test {
    my $target = shift;

    foreach my $file ("$target", "$target.t", "t/$target", "t/$target.t" ) {
        if (-r $file) {
            # are the next 3 lines really necessary?
            open(FH, $file) or next;
            my $first = <FH>;
            close(FH) or next;
            return Test::Unit::UnitHarness->new($file);
        }
    }
    return undef;
}

sub load_test_dir {
    my $test_dir = shift;
    if (-d $test_dir) {
        die "This is a test directory. I haven't implemented that.\n";
        return Test::Unit::UnitHarness::new_dir($test_dir);
    }
}

# The next bit of code is a helper function which attempts
# to identify the class we are trying to use from a '.pm'
# file. If we've reached this point, we managed to 'require'
# the file already, but we dont know the file the package was
# loaded from. Somehow I feel this information is in perl
# somwhere but if it is I dont know where...
sub get_package_name_from_file {
    my $filename = shift;
    my $real_path = $INC{$filename};
    die "Can't find $filename in @INC: $!"
      unless $real_path && open(FH, $real_path);
    while (<FH>) {
        if (/^\s*package\s+([\w:]+)/) {
            close(FH);
            return $1;
        }
    }
    die "Can't find a package in $filename";
}

1;
__END__


=head1 NAME

Test::Unit::Loader - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly.

=head1 DESCRIPTION

This class is used by the framework to load test classes into the
runtime environment.  It handles test case and test suite classes
(referenced either via their package names or the files containing
them), Test::Harness style test files, and directory names.

=head1 AUTHOR

Copyright (c) 2000 Brian Ewins.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Christian Lemburg, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::UnitHarness>

=item *

L<Test::Unit::TkTestRunner>

=back

=cut
