use v6;
use Test;
use SimNet::Net;
use SimNet::Frames;
use PokeEnv::Entity::Agent;
use PokeEnv::IO::WorldBuilder;
use PokeEnv::Grid;

my %verbFrames = loadFrames(open('frames/verbs.in').slurp);
my $verbNetwork = SimNet::Network.new(%verbFrames);
my %nounFrames = loadFrames(open('frames/nouns.in').slurp);
my $nounNetwork = SimNet::Network.new(%nounFrames);

my $world = import("world.in");
my $grid = $world.getLevel("overworld").getLayer("active");
my $loc = PokeEnv::Location.new(1, 1, $grid, "S");
my $frameagent = PokeEnv::Entity::FrameAgent.new($verbNetwork, $nounNetwork, $loc, "FrameAgent", 15, @(()), $world);
$grid.put($loc, $frameagent);
$world.spawn_agent($frameagent);

$world.run;

# vim: ft=perl6
