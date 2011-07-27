#!perl
use strict;
use warnings;

use Test::Most;
use Test::Memory::Usage;

my @thingy;
for (1 .. 150_000) {
    push @thingy, [ $_ ];
}

memory_usage_start;

for (1 .. 450_000) {
    push @thingy, [ $_ ];
}

ok(@thingy, 'array has elements');

memory_usage_ok(100);
done_testing;
