use v6;
use PokeEnv::Entity::Agent;

class PokeEnv::Entity::RandomAgent is PokeEnv::Entity::Agent {
	method act() {
		my $dir = <N S E W>.roll;
		my $result = self.move($dir);
		if !$result {
			$.loc.grid.get($.loc.adjacent($dir)).interact(self);
		}
	}
}

# vim: ft=perl6
