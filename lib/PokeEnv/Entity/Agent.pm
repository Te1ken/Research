use v6;
need PokeEnv::Entity::Entity;

class PokeEnv::Entity::Agent is PokeEnv::Entity::Entity {
	method move_to($dest) {
		$.loc.grid.rem($.loc);
		$dest.grid.put($dest, self);
		$.loc = $dest;
	}

	method move($dir) {
		my $targ = $.loc.adjacent($dir);
		my $grid = $.loc.grid;
		say $grid.isLegal($targ);
		if $grid.isLegal($targ) && $grid.isOpen($targ) {
			self.move_to($targ);
			True;
		} else {
			False;
		}
	}

	method turn($dir) {
		$.loc.dir = $dir;
	}

	method act() {}
}

class PokeEnv::Entity::FrameAgent is PokeEnv::Entity::Agent {
	has	$.simnet;
}

# vim: ft=perl6
