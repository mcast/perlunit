package Test::Unit::InnerClass;

use strict;

use vars qw($SIGNPOST $HOW_OFTEN);
# provide emulation of Java anonymous inner classes feature
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
    sub make_inner_class {
	my ($class, $extension_text, @constructor_args) = @_;
	$i++;
	my $classname = "Load" . $Test::Unit::InnerClass::HOW_OFTEN . "_"
	    . "Anonymous" . $i;
	eval  "package $class" . "::" . $classname . "; "
	    . "use base qw($class); " . $extension_text;
	no strict 'refs';
	return ("$class" . "::" . $classname)->new(@constructor_args);
	}
} 

1;
