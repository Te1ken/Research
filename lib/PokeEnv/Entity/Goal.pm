use v6;
use PokeEnv::Entity::Entity;

class PokeEnv::Entity::Goal is PokeEnv::Entity::Entity {
	has	$.activated is rw;
	has	$.world is rw;
	has	%.log;
#	has	@.log;
	method new($loc, $type, $id, $args, $world) {
		my $worker = callsame;
		$worker.world = $world;
		$world.register($worker);
		for 0..^9 {
			my $x = $worker.loc.x + 1 - floor($_/3);
			my $y = $worker.loc.y + 1 - floor($_%3);
			$worker.log{$x ~ " " ~ $y} = False;
			#push $worker.log, False;
		}
		$worker.reset;
		$worker.activated = False;
		$worker;
	}

	method reset() {
=begin comment
		for 0..^@.log.elems {
			@.log[$_] = False;
		}
		@.log[4] = True;
=end comment
		for %.log.keys {
			%.log{$_} = False;
		}
		%.log{$.loc.x ~ " " ~ $.loc.y} = True;
	}

	method interact($agent) {
		if $.activated {
			say "MISSION ACCOMPLISHED!";
			$!world.stop("success");
			#$agent.memory>>.id.say;
		}
	}

	method updateState($world) {
		if $.activated {
			return;
		}
		my $found = False;
#		say "1: " ~ now;
=begin comment
		for 0..^@.log.elems {
			my $x = $.loc.x + 1 - floor($_/3);
			my $y = $.loc.y + 1 - floor($_%3);
#			say "$x $y";
			if !($x == $.loc.x && $y == $.loc.y) {
				my $grid = $.loc.grid; # 15
				my $check = $grid.get($x, $y); # 27
				if $check ~~ PokeEnv::Entity::Agent { # 18
					$found = True;
					@.log[$_] = True;
				}
			}
		}
=end comment
		for $.world.agents {
			my $dist = exp(.5, exp(2, $_.loc.x - $.loc.x) + exp(2, $_.loc.y - $.loc.y));
			if $dist < 2 {
				%.log{$_.loc.x ~ " " ~ $_.loc.y} = True;
				$found = True;
			}
		}
#		say "2: " ~ now;
		if !($found) {
			self.reset;
			return;
		}
		$found = True;
		for %.log.values {
			if !($_) {
				$found = False;
				return;
			}
		}
		if $found {
			$.activated = True;
		}
	}
}

# vim: ft=perl6
