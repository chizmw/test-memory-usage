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
    . "not ok 3 - data/stack memory usage grows less than 10%\n"
    . "not ok 4 - virtual memory usage grows less than 10%\n"
    . "not ok 5 - RSS memory usage grows less than 10%\n"
    . "not ok 6 - data/stack memory usage grows less than 10%\n"
    . "not ok 7 - virtual memory usage grows less than 10%\n"
    . "not ok 8 - RSS memory usage grows less than 10%\n"
    . "not ok 9 - data/stack memory usage grows less than 10%\n"
    . "not ok 10 - virtual memory usage grows less than 10%\n"
    . "not ok 11 - RSS memory usage grows less than 10%\n"
    . "not ok 12 - data/stack memory usage grows less than 10%\n"
    . "not ok 13 - virtual memory usage grows less than 10%\n"
    . "not ok 14 - RSS memory usage grows less than 10%\n"
    . "not ok 15 - data/stack memory usage grows less than 10%\n"

    . "ok 16 - virtual memory usage grows less than 10%\n"
    . "ok 17 - RSS memory usage grows less than 10%\n"
    . "ok 18 - data/stack memory usage grows less than 10%\n"
    . "ok 19 - virtual memory usage grows less than 10%\n"
    . "ok 20 - RSS memory usage grows less than 10%\n"
    . "ok 21 - data/stack memory usage grows less than 10%\n"
    . "ok 22 - virtual memory usage grows less than 10%\n"
    . "ok 23 - RSS memory usage grows less than 10%\n"
    . "ok 24 - data/stack memory usage grows less than 10%\n"
    . "ok 25 - virtual memory usage grows less than 10%\n"
    . "ok 26 - RSS memory usage grows less than 10%\n"
    . "ok 27 - data/stack memory usage grows less than 10%\n"
    . "ok 28 - virtual memory usage grows less than 10%\n"
    . "ok 29 - RSS memory usage grows less than 10%\n"
    . "ok 30 - data/stack memory usage grows less than 10%"
);
test_fail(+15);

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

