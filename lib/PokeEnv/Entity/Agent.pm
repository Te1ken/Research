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
			$ent.interact(self);
		} 
	}

	method propel() {}

	method act() {}
}

class PokeEnv::Entity::FrameAgent is PokeEnv::Entity::Agent {
	has	$.verbnet is rw;
	has	$.nounnet is rw;
	has	$.age is rw;
	has	@.memory;
	has	@.todo;
	
	method new($verbs,$nouns,$loc,$type,$id,@args,$world) {
		my $ret = callwith($loc,$type,$id,@(()).item,$world);
		if @args.elems > 0 {
			for @args {
				my $act = $verbs.master{$_}.instantiate;
				$act.defaultTo(0);
				push $ret.todo, $act.distill;
			}
		}
		$ret.verbnet = $verbs;
		$ret.nounnet = $nouns;
		$ret;
		#$ret.bless(:verbnet($verbs),:nounnet($nouns),:age(0));
	}

	method selectAction() {
		if @.todo.elems ~~ 0 {
			my $fetch = (2..6).roll;
			my $act = $.verbnet.master{$fetch}.instantiate;
			$act.defaultTo(0);
			push @.todo, $act.distill;
		}
		@.todo.shift;
	}

	method act() {
		my $action = self.selectAction;
		push @.memory, $action;
		$.age++;
		if $action.id ~~ 2 {
			self.move;
		} elsif $action.id ~~ 3 {
			self.speak;
		} elsif $action.id ~~ 4 {
			self.grasp;
		} elsif $action.id ~~ 5 {
			self.propel;
		} elsif $action.id ~~ 6 {
			self.turn;
		}
	}
}

# vim: ft=perl6
