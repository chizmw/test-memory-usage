package Test::Memory::Usage;
# ABSTRACT: make sure code doesn't unexpectedly eat all your memory
use strict;
use warnings;

use Memory::Usage;
use Test::Builder;
use Sub::Uplevel qw( uplevel );
use base qw( Exporter );
use vars qw( $Tester $mu $first_state_index);
our @EXPORT = qw(memory_virtual_ok memory_rss_ok memory_stack_ok memory_usage_ok memory_usage_start);

=head1 SYNOPSIS

The easiest usage pattern looks like this:

    use Test::Memory::Usage;

    # do some setup; decide that's roughly where you should be with usage
    # levels; draw your lin in the sand
    memory_usage_start;

    # do some things that you want to test as normal
    # ...
    
    # finally, make sure you haven't run away with memory
    memory_usage_ok;
    done_testing;

You can call C<memory_usage_start> as often as you like; each call moves the
reference point used for comparison with C<memory_usage_ok>:

    # loop over some action and make sure it doesn't grow
    for (1 .. 5) {
        memory_usage_start;

        # bad growing code!
    
        memory_usage_ok(10);
    }

=head1 EXPORTS

Test::Memory::Usage exports the following subs automatically:

=over 4

=item memory_usage_start

=item memory_usage_ok

=item memory_virtual_ok

=item memory_rss_ok

=item memory_stack_ok

=back

=cut

sub import {
    my $self = shift;
    $self->export_to_level( 1, $self, $_ )
        foreach @EXPORT;
}

BEGIN {
    $Tester = Test::Builder->new;
    $mu = Memory::Usage->new;
    $mu->record('Memory::Usage test starting');
};

=head1 METHODS

The module provides the following methods:

=cut

=head2 memory_usage_start

This method records the current memory usage and flags it to be used for any
growth tests later in the script.

You can call the method multiple times; each call adds a new state record and
updates makes the most recent state recorded the reference point for any
growth comparisons

This is useful if you want to compare the usage after you've performed a
certain amount of minimum setup before the area(s) of code that you want to
verify memory usage for.

=cut
sub memory_usage_start {
    $mu->record('Memory::Usage start-marker');
    # the state to use as our base point is one fewer than the number of
    # states we have
    $first_state_index = @{$mu->state} - 1;
}

=head2 memory_usage_ok($percentage_limit)

This calls the C<memory_virtual_ok()> and C<memory_rss_ok()> functions.

If not provided C<$percentage_limit> defaults to '10'.

=cut
sub memory_usage_ok {
    my $percentage_allowed = shift;
    memory_virtual_ok($percentage_allowed);
    memory_rss_ok($percentage_allowed);
    memory_stack_ok($percentage_allowed);
}

=head2 memory_virtual_ok($percentage_limit)

Runs the test to ensure that virtual memory usage hasn't grown more than
C<$percentage_limit>

This isn't usually called explicitly as most users will find
C<memory_usage_ok()> meets their testing needs.

If not provided C<$percentage_limit> defaults to '10'.

=cut
sub memory_virtual_ok {
    return _growth_ok('virtual', 2, shift);
}

=head2 memory_rss_ok($percentage_limit)

Runs the test to ensure that RSS memory usage hasn't grown more than
C<$percentage_limit>

This isn't usually called explicitly as most users will find
C<memory_usage_ok()> meets their testing needs.

If not provided C<$percentage_limit> defaults to '10'.

=cut
sub memory_rss_ok {
    return _growth_ok('RSS', 3, shift);
}

=head2 memory_stack_ok($percentage_limit)

Runs the test to ensure that data/stack memory usage hasn't grown more than
C<$percentage_limit>

This isn't usually called explicitly as most users will find
C<memory_usage_ok()> meets their testing needs.

If not provided C<$percentage_limit> defaults to '10'.

=cut
sub memory_stack_ok {
    return _growth_ok('data/stack', 2, shift);
}

sub _percentage_growth {
    my ($start, $end) = @_;
    return sprintf('%.1f%%',( ($end * 1.0) / ($start * 1.0) ) * 100);
}

sub _growth_ok {
    my ($memory_name, $state_index, $percentage_allowed) = @_;
    # which item in the state list to use for comparison; defaults to the
    # first one (when the module starts)
    # can be altered by calling memory_usage_start() in the test script
    $first_state_index ||= 0;

    # how much can the usage grow by?
    $percentage_allowed ||= 10;
    # turn the [user friendly] percentage into a number we can more easily
    # work with
    my $multiplier = 1 + ($percentage_allowed / 100.0);

    # make sure we record our (current) state; if we don't do this we might be
    # in the position where we've only got the first recorded state and it
    # looks like there's been no growth
    my $sub = [caller(1)]->[3];
    $mu->record("Memory::Usage $sub()");

    # grab some useful values
    my $state = $mu->state;
    my $start = $state->[$first_state_index]->[$state_index];
    my   $end = $state->[-1]->[$state_index];

    # we're 'ok' as long as we haven't grown more than 10%
    my $ok = $end < ($start * $multiplier);

    # 'run' the test; feedback if required
    $Tester->ok($ok, "${memory_name} memory usage grows less than $percentage_allowed%");
    $ok or $Tester->diag(
        "${memory_name} memory usage grew from $start to $end ("
        . _percentage_growth($start, $end)
        . ')'
    );
    return $ok;
}

=head1 SEE ALSO

L<Memory::Usage>

=cut

END {
    $mu->record('Memory::Usage test completed');
    memory_usage_ok
        if (not $Tester->has_plan);
}

1;
# vim: ts=8 sts=4 et sw=4 sr sta
