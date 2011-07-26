package Test::Memory::Usage;
# ABSTRACT: Test::Memory::Usage needs a more meaningful abstract
use strict;
use warnings;

use Memory::Usage;
use Test::Builder;
use vars qw( $Test $mu );

BEGIN {
    $Test = Test::Builder->new;

    $mu = Memory::Usage->new;
    $mu->record('Memory::Usage test starting');
};

sub _make_plan {
    if (my $plan = $Test->has_plan) {
        $Test->plan( tests => $plan + 2 );
    }
    else {
        $Test->no_plan;
    }
}

sub _percentage_growth {
    my ($start, $end) = @_;
    return sprintf('%.1f%%',( ($end * 1.0) / ($start * 1.0) ) * 100);
}

sub _growth_ok {
    my ($memory_name, $state_index) = @_;

    my $start = $mu->state->[ 0]->[$state_index];
    my   $end = $mu->state->[-1]->[$state_index];
    # we're 'ok' as long as we haven't grown more than 10%
    my $ok =
        $end < ($start * 1.10);
    $Test->ok($ok, "${memory_name} memory usage acceptable");
    $ok or $Test->diag(
        "${memory_name} memory usage grew from $start to $end ("
        . _percentage_growth($start, $end)
        . ')'
    );
    return $ok;
}

sub memory_virtual_ok {
    return _growth_ok('virtual', 2);
}

sub memory_rss_ok {
    return _growth_ok('RSS', 3);
}

END {
    $mu->record('Memory::Usage test completed');
    _make_plan;
    memory_virtual_ok;
    memory_rss_ok;
}

1;
# vim: ts=8 sts=4 et sw=4 sr sta
