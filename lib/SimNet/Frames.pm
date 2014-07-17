use v6;

#module SimNet::Frames;

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

class SimNet::FrameInstance { ... }

class SimNet::Frame {
	has	$.net;
	has	%.data;
	has	$.id is rw;

	method new($net) {
		self.bless(:$net);
	}

	method clear() {
		%.data{}:delete;
	}

	method instantiate() {
		SimNet::FrameInstance.new(%.data, $.id, $.net);
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
		if !($val ~~ Str && $val.chars == 0) {
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
		my regex pair { <&valid>('<'<&valid>'>')?'=>'(<&frameref>|<&valid>)? };
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

class SimNet::FrameInstance is SimNet::Frame {
	has	@.params;
	method new(%data is copy, $id, $net) {
		my $worker = self.bless(:%data, :$id, :$net);
		$worker.findParams;
		$worker;
	}

	method distill() {
		my @seq = ();
		if $.id == 0 || %.data{"sequence"}.elems ~~ 1 {
			push @seq, self;
		} else {
			say "Seems to be actually trying to distill.  Aight.";
			for %.data{"sequence"} {
				my $instance = $.net.master{$_}.instantiate;
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
		push @.params, @list;
	}

	method WHICH() {
		"SimNet::FrameInstance|$.id";
	}
}

sub loadFrames($input, $net) is export {
	my $str = $input.subst(rx/'#'.*?'#'|\r?\n/, ' ', :g);
	$str = $str.subst(rx/\s+/, ' ', :g).trim-trailing.chomp;
	my @list = $str.split(' ');
	my %framedex;
	my @unsatisfied;
	for @list {
		my $frame = SimNet::Frame.new($net);
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
