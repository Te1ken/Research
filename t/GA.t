use Test;
use AI::GA;

my %hash = EVAL(open('pruned.in').slurp);

evolve(10, %hash.values);

# vim: ft=perl6
