use Test;
use TestUtils::Utils;
use SimNet::Net;
use SimNet::Frames;

my $verbNetwork = SimNet::Network.new('frames/verbs.in');
my $nounNetwork = SimNet::Network.new('frames/nouns.in');

my %hash = EVAL(open('pruned.in').slurp);
say "Test Run: ";
testRun(%hash{0}, $verbNetwork, $nounNetwork, True);

# vim: ft=perl6
