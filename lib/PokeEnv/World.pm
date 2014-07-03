use v6;
use PokeEnv::Entity::Agent;

class PokeEnv::Level {
	has	$.id;
	has	%.layers;
	has	$.width;
	has	$.height;
	
	method new($width, $height, $id) {
		self.bless(:$width, :$height, :$id);
	}

	method addLayer($lid, $layer) {
		%.layers{$lid} = $layer;
	}

	method hasLayer($lid) {
		%.layers{$lid}:exists;
	}
	
	method getLayer($lid) {
		%.layers{$lid};
	}

	method dump() {
		say "Level: $.id";
		for %.layers.keys {
			say "Layer: $_";
			%.layers{$_}.dump;
		}
	}
}

class PokeEnv::World {
	has	$.active is rw;
	has	$.exitcode is rw;
	has	%.levels;
	has	$.level is rw;
	has	@.agents;
	has	@.entities;

	method new() {
		self.bless(:active(True));
	}

	method run($ticks = Inf) {
		$.active = True;
		my $unpause = time - 2;
		my $count = 0;
		while $.active && $count < $ticks {
			if time >= $unpause {
				@.agents>>.act;
				@.entities>>.updateState(self);
				#self.dump;
				$unpause = time - 2;
				$count++;
			}
		}
		if $.active {
			self.stop("timeout");
		}
	}

	method stop($reason) {
		$.active = False;
		$.exitcode = $reason;
	}

	method register($entity) {
		push @.entities, $entity;
	}

	method spawn_agent($agent) {
		@.agents.push($agent);
	}

	method switch_level($level_id) {
		if %.levels{$level_id}:exists {
			$.level = %.levels{$level_id};
			$.level;
		} else {
			False;
		}
	}

	method addLevel($level, $level_id = $level.id) {
		%.levels{$level_id} = $level;
	}

	method hasLevel($level_id) {
		%.levels{$level_id}:exists;
	}

	method getLevel($level_id) {
		%.levels{$level_id};
	}

	method dump() {
		%.levels.values>>.dump;
	}
}
# vim: ft=perl6
