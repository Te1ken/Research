use v6;
need PokeEnv::Entity::Entity;

class PokeEnv::Entity::Agent is PokeEnv::Entity::Entity {
	method move_to($dest) {
		$.loc.grid.rem($.loc);
		$dest.grid.put($dest, self);
		$.loc = $dest;
	}

	method move() {
		my $targ = $.loc.adjacent($.loc.dir);
		my $grid = $.loc.grid;
		say $grid.isLegal($targ);
		if $grid.isLegal($targ) && $grid.isOpen($targ) {
			self.move_to($targ);
			True;
		} else {
			False;
		}
	}

	method turn() {
		if $.loc.dir ~~ "N" {
			$.loc.dir = "E";
		} elsif $.loc.dir ~~ "E" {
			$.loc.dir = "S";
		} elsif $.loc.dir ~~ "S" {
			$.loc.dir = "W";
		} elsif $.loc.dir ~~ "W" {
			$.loc.dir = "N";
		}
	}

	method speak() {};

	method grasp() {
		my $targ = $.loc.adjacent($.loc.dir);
		my $grid = $.loc.grid;
		my $ent = $grid.get($targ);
		if $ent.defined {
			$ent.interact;
		} 
	}

	method propel() {}

	method act() {}
}

class PokeEnv::Entity::FrameAgent is PokeEnv::Entity::Agent {
	has	$!verbnet;
	has	$!nounnet;
	has	$!age is rw;
	has	@.memory;
	has	@.todo;
	
	method new($verbs,$nouns,$loc,$type,$id,@args,$world) {
		self.bless(:verbnet($verbs),:nounnet($nouns),:age(0));
		callwith($loc,$type,$id,@args,$world);
	}

	method selectAction() {
		if @.todo.elems ~~ 0 {
			my $act = $!verbnet.master{2}.instantiate;
			$act.set("x"=>1);
			$act.defaultTo(0);
			push @.todo, $act.distill;
		}
		@.todo.shift;
	}

	method act() {
		my $action = selectAction;
		push @.memory, $action;
		$!age++;
		say "Action: " ~ $action.id;
		if $action.id ~~ 2 {
			move;
		} elsif $action.id ~~ 3 {
			speak;
		} elsif $action.id ~~ 4 {
			grasp;
		} elsif $action.id ~~ 5 {
			propel;
		} elsif $action.id ~~ 6 {
			turn;
		}
	}
}

# vim: ft=perl6
