#!perl
use strict;
use warnings;

use Test::Most;
use Test::Builder::Tester;
use Test::Memory::Usage;

# a global variable for us to grow
my @thingy;

# a simple sub to allow us to easily grow
sub grow_thingy {
    for (1 .. 150_000) {
        push @thingy, [ $_ ];
    }
}

# before we do anything ... grow!
grow_thingy;

test_out(
      "not ok 1 - virtual memory usage grows less than 10%\n"
    . "not ok 2 - RSS memory usage grows less than 10%\n"
    . "not ok 3 - virtual memory usage grows less than 10%\n"
    . "not ok 4 - RSS memory usage grows less than 10%\n"
    . "not ok 5 - virtual memory usage grows less than 10%\n"
    . "not ok 6 - RSS memory usage grows less than 10%\n"
    . "not ok 7 - virtual memory usage grows less than 10%\n"
    . "not ok 8 - RSS memory usage grows less than 10%\n"
    . "not ok 9 - virtual memory usage grows less than 10%\n"
    . "not ok 10 - RSS memory usage grows less than 10%\n"

    . "ok 11 - virtual memory usage grows less than 10%\n"
    . "ok 12 - RSS memory usage grows less than 10%\n"
    . "ok 13 - virtual memory usage grows less than 10%\n"
    . "ok 14 - RSS memory usage grows less than 10%\n"
    . "ok 15 - virtual memory usage grows less than 10%\n"
    . "ok 16 - RSS memory usage grows less than 10%\n"
    . "ok 17 - virtual memory usage grows less than 10%\n"
    . "ok 18 - RSS memory usage grows less than 10%\n"
    . "ok 19 - virtual memory usage grows less than 10%\n"
    . "ok 20 - RSS memory usage grows less than 10%"
);
test_fail(+10);

# loop over some action and make sure it doesn't grow
for (1 .. 5) {
    # draw a line in the sand at the start of the loop
    memory_usage_start;

    # bad growing code!
    grow_thingy;

    # end of loop - make sure we didn't grow
    memory_usage_ok(10);
}

# loop test where we don't grow at all
for (1 .. 5) {
    memory_usage_start;
    memory_usage_ok;
}

# fin
test_test( skip_err => 1, title => 'tests emit expected output');
done_testing;

