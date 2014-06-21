use v6;
#use lib "/home/Phoenix/workspace/Research/PokeEnv/lib";
use PokeEnv::IO::WorldBuilder;

sub MAIN() {
	my $world = import("world.in");
	for (0 .. 3) {
		$world.run;
		$world.dump;
	}
}
