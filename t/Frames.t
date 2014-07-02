use v6;
use Test;
use SimNet::Net;
use SimNet::Frames;

my %frames = loadFrames(open('frames/nouns.in').slurp);
my $network = SimNet::Network.new(%frames);
is(%frames{0}.get("color"), False, 'test 1');
is(%frames{1}.get("phase"), ('solid','liquid'), 'test 2');
is(%frames{3}.get("phase"), ('liquid'), 'test 3');
say %frames{3}.get("diff")>>.WHICH;

# vim: ft=perl6
