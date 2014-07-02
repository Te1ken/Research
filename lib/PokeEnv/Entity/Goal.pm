use v6;
use PokeEnv::Entity::Entity;

class PokeEnv::Entity::Goal is PokeEnv::Entity::Entity {
	has	$.activated is rw;
	has	$!world is rw;
	has	%.log;
	method new($loc, $type, $id, $args, $world) {
		my $worker = callsame;
		$!world = $world;
		$world.register(self);
		for ($loc.x-1 .. $loc.x+1) -> $x {
			for ($loc.y - 1 .. $loc.y + 1) -> $y {
				%.log{[$x,$y]} = False;
			}
		}
	}

	method reset() {
		for ($loc.x - 1 .. $loc.x + 1) -> $x {
			for ($loc.y - 1 .. $loc.y + 1) -> $y {
				%.log{[$x,$y]} = False;
			}
		}
	}

	method interact($agent) {
		if $.activated {
			say "MISSION ACCOMPLISHED!";
			$!world.stop;
		}
	}

	method updateState($world) {
		if $.activated {
			return;
		}

		my $found = False;
		for %.log.keys {
			my ($x, $y) = $_.split(' ');
			my $grid = $.loc.grid;
			my $check = $grid.get($x, $y);
			if PokeEnv::Entity::Agent.ACCEPTS($check) {
				$found = True;
				%.log{$_} = True;
			}
		}

		if !($found) {
			reset;
		}

		$found = True;
		for %.log.values {
			if !($_) {
				$found = False;
			}
		}
		
		if $found {
			$.activated = True;
		}
	}
}

# vim: ft=perl6
