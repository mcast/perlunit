#!/usr/bin/perl

# These tests are MEANT to fail. I need to see the output
# of failed tests to make sure they get handled properly.
print <<END_RUN;
This should not appear in a stack trace.
1..4
This message should appear in stack trace 1.
not ok 1
This should not appear, test 2 passes.
ok 2
This should appear in stack trace 3
not ok 3
This should be the only message in stack trace 4.
not ok 4
END_RUN
