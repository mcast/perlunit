package Test::Unit::Loader;
use strict;
use FileHandle;
use constant DEBUG => 0;

use Test::Unit::TestSuite;
use Test::Unit::TestCase;
use Test::Unit::UnitHarness;

# should really do something in here about a local @INC.
sub obj_load { shift; load(@_) }

sub load {
    my $target = shift;
    print "Test::Unit::Loader::load($target) called\n" if DEBUG;

    my $suite;
    # Is it a test class?
    if ($target =~ /^[\w:]+$/ 
        && eval "require $target"
        && ! $@) {
        # first up: is this a real test case?
        print "$target compiled OK as test class\n" if DEBUG;
        $suite = try_test_suite($target) || try_test_case($target);
    }
    elsif ($target =~ /\.pm$/ 
             && eval "require \"$target\""
             && ! $@) {
        print "$target compiled OK as filename\n" if DEBUG;
        #In this case I need to figure out what the class
        #was I just loaded!
        my $package = get_package_name_from_file($target);        
        $suite = try_test_suite($package) || try_test_case($package);
    }
    else {
        die $@;
    }
    return $suite if $suite;
    
    for my $file ("$target",
                  "$target.t",
                  "t/$target",
                  "t/$target.t" ) {
        # try it out as a test::harness type test.
        $suite = try_test_harness($file);
        return $suite if $suite;
    }
    # one last shot: is it a _directory_?
    $suite = try_test_dir($target);
    return $suite if $suite;
    die "(This error is expected) Suite class " . $target . " not found: $@";
    
}

sub try_test_case {
    my $package = shift;
    if ($package->isa("Test::Unit::TestCase")) {
        print "$package isa Test::Unit::TestCase\n" if DEBUG;
        return Test::Unit::TestSuite->new($package);
    } 
}

sub try_test_suite {
    my $package = shift;
    if ($package->can("suite")) {
        print "$package has a suite() method\n" if DEBUG;
        return $package->suite();
    } 
}

sub try_test_harness {
    my $test_case = shift;
    if (-r $test_case) {
        my $fh = new FileHandle;
        $fh->open($test_case) or return;
        my $first = <$fh>;
        $fh->close or return;
        return Test::Unit::UnitHarness->new($test_case);
    }
}

sub try_test_dir {
    my $test_case = shift;
    if (-d $test_case) {
        die "This is a test directory. I haven't implemented that.\n";
        return Test::Unit::UnitHarness::new_dir($test_case);
    }
}

# The next bit of code is a helper function which attempts
# to identify the class we are trying to use from a '.pm'
# file. If we've reached this point, we managed to 'require'
# the file already, but we dont know the file the package was
# loaded from. Somehow I feel this information is in perl
# somwhere but if it is I dont know where...
sub get_package_name_from_file {
    my $test_case = shift;
    my $fh = new FileHandle;
    my $filename;
    my $real_path = $INC{$filename};
    $fh->open($real_path) or die "Can't find $filename in @INC: $!";
    while (defined($_ = <$fh>)) {
        /^\s*package\s+([\w:]+)/ && return $1;
    }
    die "Got a $test_case but can't find a package";
}

1;
__END__


=head1 NAME

Test::Unit::Loader - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to load testcase classes into the
runtime environment. It handles testcase class names (that is, classes
inheriting from Test::Unit::TestCase), Test::Harness style test files,
and directory names.

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
