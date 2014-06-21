use v6;
use PokeEnv::Entity::Entity;
use PokeEnv::Grid;

class PokeEnv::Entity::Teleporter is PokeEnv::Entity::Entity {
	has $.dest is rw;
	
	method new($loc, $type, $id, $args, $world) {
		my $worker = callsame;
		my ($level_id, $layer_id, $x, $y, $dir) = split(',', $args);
		my $grid = $world.levels{$level_id}.getLayer($layer_id);
		my $targetLoc = PokeEnv::Location.new(+$x, +$y, $grid, $dir);
		$worker.dest = $targetLoc;
		$worker;
	}

	method interact($agent) {
		say "HIT A TELEPORTER!";
		$agent.move_to($.dest);
	}
}

# vim: ft=perl6
