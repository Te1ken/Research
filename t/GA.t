use Test;
use TestUtils::Utils;
use SimNet::Net;
use SimNet::Frames;

my %verbFrames = loadFrames(open('frames/verbs.in').slurp);
my $verbNetwork = SimNet::Network.new(%verbFrames);
my %nounFrames = loadFrames(open('frames/nouns.in').slurp);
my $nounNetwork = SimNet::Network.new(%nounFrames);

my %hash = EVAL(open('pruned.in').slurp);
say "Test Run: ";
testRun(%hash{0}, $verbNetwork, $nounNetwork, True);

# vim: ft=perl6
