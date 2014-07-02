use v6;
use PokeEnv::Grid;

class PokeEnv::Entity::Entity {
	has	PokeEnv::Location 	$.loc is rw;
	has	Int			$.id;
	has				$.type;

	method new($loc, $type, $id, @args = @(()), $world = Nil) {
		self.bless(:$loc, :$type, :$id);
	}
	
	method inspect() {

	}

	method interact($agent) {

	}

	method apply() {

	}

	method updateState($world) {

	}

	method step_on() {

	}
}

# vim: ft=perl6
