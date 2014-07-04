use v6;

my %directions = 'N' => [0, -1], 'E' => [1, 0], 'S' => [0, 1], 'W' => [-1, 0];

class PokeEnv::Location {
	has	Int	$.x;
	has	Int	$.y;
	has		$.dir is rw;
	has		$.grid;
	
	method new($x, $y, $grid, $dir) {
		self.bless(:$x, :$y, :$grid, :$dir);
	}

	method adjacent($dir) {
		my $newX = %directions{$dir}[0] + $.x;
		my $newY = %directions{$dir}[1] + $.y;
		PokeEnv::Location.new($newX, $newY, $.grid, $dir);
	}	

	method setDirection($dir) {
		if %directions.exists($dir) {
			$.dir = $dir;
		}
	}

	method WHICH() {
		"PokeEnv::Location|($.x,$.y) in grid { $.grid.ident; }";
	}
}

class PokeEnv::BoundedGrid {
	has 	Int	$.width;
	has	Int	$.height;
	has		%.contents{PokeEnv::Location};
	has		$.ident;

	method new($x, $y) {
		self.bless(:width($x), :height($y), :ident(self.WHICH));
	}

	method put($loc, $ent) {
		%.contents{$loc} = $ent;
	}
	
	method rem($loc) {
		%.contents{$loc}:delete;
	}
	
	multi method get($x, $y) {
		my $loc = PokeEnv::Location.new(+$x, +$y, self, "N");
		self.get($loc);
	}

	multi method get($loc) {
		if %.contents{$loc}:exists {
			%.contents{$loc};
		} else {
			Nil;
		}
	}

	method isLegal($loc) {
		$loc.x >= 0 && $loc.y >= 0 && $loc.x < $.width && $loc.y < $.height;
	}
	
	method isOpen($loc) {
		!(%.contents{$loc}:exists);
	}

	method dump() {
		my $out = "\t";
		for (0 .. $.width - 1) -> $c { $out ~= "$c\t"; }
		say $out;
		for (0 .. $.height - 1) -> $r {
			$out = "$r\t";
			for (0 .. $.width - 1) -> $c {
				my $loc = PokeEnv::Location.new($r, $c, self, 'N');
				if (%.contents{$loc}:exists) {
					$out ~= self.get($loc).type ~ "\t";
				} else { $out ~= "\t"; }
			}
			say $out;
		}
	}
}

# vim: ft=perl6
