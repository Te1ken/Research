use v6;

module SimNet::Frames;

#class SimNet::Frame {...};

sub recursiveGet($slot, @queue, %visited) {
	if @queue.elems > 0 {
		my $frame = @queue.shift;
		if !%visited{$frame}:exists {
			%visited{$frame} = True;
			my @ret = $frame.get($slot);
			if @ret[0] ~~ "enqueue" {
				@queue.push(@ret[1]);
				recursiveGet($slot, @queue, %visited, False);
			} elsif @ret[0] ~~ Nil {
				recursiveGet($slot, @queue, %visited, False);
			} else {
				@ret[1];
			}
		} else {
			recursiveGet($slot, @queue, %visited, False);
		}
	} else {
		False;
	}
}

class SimNet::Frame {
	has	%.data;
	method get($slot, $first=True) {
		if $first {
			my %visited{SimNet::Frame};
			recursiveGet($slot, (self), %visited);
		} elsif %.data{$slot}:exists {
			["result", %.data{$slot}];
		} elsif !%.data{"isa"}:exists {
			[Nil];
		} else {
			["enqueue", %.data{"isa"}];
		}	
	}

	method put($key, $val, $overwrite=False) {
		if !%.data{$key}:exists || $overwrite {
			%.data{$key} = ();
		}
		push %.data{$key}, $val;
	}
	
	method fromString($frame, $overwrite=True) {
		say $frame;
		my @framereqs = ();
		my regex id { \d+ };
		my regex frameref { '|<'\d+'>|' };
		my regex valid { <[a..z]+[0..9]>+ };
		my regex pair { <&valid>'=>'(<&frameref>|<&valid>) };
		say &id.perl;
		my $id = +(($frame ~~ m/\d+/).Str);
		my @pairs = (m:g/<&pair>/ given $frame)>>.Str;
		for @pairs -> $pair {
			my ($key, $value) = $pair.split('=>');
			if $value ~~ m/<&frameref>/ {
				push @framereqs, $pair;
			} else {
				self.put($key, $value, $overwrite);
			}
		}
		($id, @framereqs);
	}
}

sub loadFrames($str) is export {
	my @list = $str.split(' ');
	my %framedex;
	my @unsatisfied;
#	say "Got this far...";
	for @list {
		my $frame = SimNet::Frame.new;
		my ($id, @reqs) = $frame.fromString($_);
		%framedex{$id} = $frame;
		push @unsatisfied, [$id, @reqs];
	}
	for @unsatisfied {
		%framedex{$_[0]}.put($_[1].key, %framedex{($_[1].value ~~ m/\d+/).Str});
	}
	%framedex;
}

# vim: ft=perl6
