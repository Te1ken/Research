use SimNet::Net;
use SimNet::Frames;
use PokeEnv::IO::WorldBuilder;
use PokeEnv::Grid;

sub testRun(@list is copy, $verbs is copy, $nouns is copy, $print = False) is export {
	say now ~ " (" ~ @list.elems ~ ")";
	my $world = import("world.in");
	my $grid = $world.getLevel("overworld").getLayer("active");
	my $loc = PokeEnv::Location.new(1, 1, $grid, "S");
	my $frameagent = PokeEnv::Entity::FrameAgent.new($verbs, $nouns, $loc, "FrameAgent", 15, @list, $world);
	$grid.put($loc, $frameagent);
	$world.spawn_agent($frameagent);
	$world.run(:ticks(@list.elems), :dump($print));
	say $world.exitcode;
	$world.exitcode;
}

# vim: ft=perl6
