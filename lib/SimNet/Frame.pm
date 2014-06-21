use v6;

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
		} else {
			%visited{self} = True;
			if %.data{$slot}:exists {
				["result", %.data{$slot}];
			} elsif !%.data{"isa"}:exists {
				[Nil];
			} else {
				["enqueue", %.data{"isa"}];
			}
		}
	}

	method put($key, $val, $overwrite=False) {
		if !%.data{$key}:exists {
			%.data{$key} = ();
		}
		push %.data{$key}, $val;
	}
	
	method fromString($str, $overwrite=True) {
		
	}
}

# vim: ft=perl6
