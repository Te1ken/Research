use v6;

module SimNet::Frames;

sub recursiveGet($slot, @queue, %visited) {
	if @queue.elems > 0 {
		my $frame = @queue.shift;
		if !(%visited{$frame}:exists) {
			%visited{$frame} = True;
			my @ret = $frame.get($slot, False);
			if @ret[0] ~~ :!defined {
				recursiveGet($slot, @queue, %visited);
			} elsif @ret[0] ~~ "enqueue" {
				@queue.push(@ret[1]);
				recursiveGet($slot, @queue, %visited);
			} else {
				@ret[1];
			}
		} else {
			recursiveGet($slot, @queue, %visited);
		}
	} else {
		False;
	}
}

class SimNet::Frame { ... };

class SimNet::FrameInstance is SimNet::Frame {
	has	@.params;
	method new(%data, $id) {
		self.bless(:%data, :$id, :params(self.findParams));
	}

	method distill() {
		my @seq = ();
		if %.data{"sequence"}.elems ~~ 1 {
			push @seq, self;
		} else {
			for %.data{"sequence"} {
				my $instance = %.frames{$_}.instantiate;
				push @seq, $instance.distill;
			}
		}
		@seq;
	}

	method set($pair) {
		%.data{$pair.key} = $pair.value;
		my $index = 0;
		my $found = False;
		while $index < @.params.elems && !($found) {
			if @.params[$index] ~~ $pair.key {
				$found = True;
				@.params.splice($index,1);
			}
			$index++;
		}
		say "Should have no $pair :" ~ @.params;
	}

	method defaultTo($value) {
		for @.params -> $key {
			%.data{$key} = $value;
		}
	}

	method findParams() {
		my @list = ();
		for %.data.keys -> $key {
			if %.data{$key}.elems == 0 {
				push @list, $key;
			}
		}
		@list;
	}
}

class SimNet::Frame {
	has	%.frames;
	has	%.data;
	has	$.id is rw;

	method new(%frames) {
		self.bless(:%frames);
	}

	method clear() {
		%.data{}:delete;
	}

	method instantiate() {
		my $instance = SimNet::FrameInstance.new(%.data, $.id);
	}

	method get($slot, $first=True) {
		if $first {
			my %visited{SimNet::Frame};
			recursiveGet($slot, [self], %visited);
		} elsif %.data{$slot}:exists {
			("result", %.data{$slot});
		} elsif !(%.data{"isa"}:exists) || %.data{"isa"}.elems == 0 {
			Nil;
		} else {
			("enqueue", %.data{"isa"}[0]);
		}	
	}

	method put($key, $val, $overwrite=False) {
		if !(%.data{$key}:exists) || $overwrite {
			%.data{$key} = @(());
		}
		if !($val.WHICH.Str ~~ m/^'Str|'/ && $val.chars == 0) {
			push %.data{$key}, $val;
		} 
	}
	
	method fromString($frame, $overwrite=True) {
		if $overwrite {
			self.clear;
		}
		my @framereqs = ();
		my regex id { \d+ };
		my regex frameref { '|<'\d+'>|' };
		my regex valid { :i <[a..z]+[0..9]>+ };
		my regex pair { <&valid>'=>'(<&frameref>|<&valid>)? };
		my $id = +(($frame ~~ m/<&id>/).Str);
		$.id = $id;
		my @pairs = (m:g/<&pair>/ given $frame)>>.Str;
		for @pairs -> $pair {
			my ($key, $value) = $pair.split('=>');
			if $value ~~ m/<&frameref>/ {
				push @framereqs, $key => $value;
			} else {
				self.put($key, $value, False);
			}
		}
		($id, @framereqs);
	}

	method WHICH() {
		"SimNet::Frame|$.id";
	}
}

sub loadFrames($input) is export {
	my $str = $input.subst(rx/'#'.*?'#'|\r?\n/, ' ', :g);
	$str = $str.subst(rx/\s+/, ' ', :g).trim-trailing.chomp;
	my @list = $str.split(' ');
	my %framedex;
	my @unsatisfied;
	for @list {
		my $frame = SimNet::Frame.new(%framedex);
		my ($id, @reqs) = $frame.fromString($_);
		%framedex{$id} = $frame;
		if @reqs[0]:exists {
			push @unsatisfied, [$id, [@reqs]];
		}
	}
	for @unsatisfied -> @sub {
		my $id = @sub[0];
		for @sub[1] -> @pairs {
			for @pairs {
				%framedex{$id}.put($_.key, %framedex{($_.value ~~ m/\d+/).Str}); 
			}
		}
	}
	%framedex;
}

# vim: ft=perl6
