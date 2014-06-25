use v6;

module SimNet::Frames;

sub recursiveGet($slot, @queue, %visited) {
	if @queue.elems > 0 {
		my $frame = @queue.shift;
#		say $frame;
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

class SimNet::Frame {
	has	%.data;
	has	$.id is rw;
	method get($slot, $first=True) {
		if $first {
			my %visited{SimNet::Frame};
			recursiveGet($slot, [self], %visited);
		} elsif %.data{$slot}:exists {
			("result", %.data{$slot});
		} elsif !(%.data{"isa"}:exists) {
			Nil;
		} else {
#			say %.data{"isa"}[0];
			("enqueue", %.data{"isa"}[0]);
		}	
	}

	method put($key, $val, $overwrite=False) {
		if !(%.data{$key}:exists) || $overwrite {
			%.data{$key} = @(());
		}
		push %.data{$key}, $val;
	}
	
	method fromString($frame, $overwrite=True) {
		my @framereqs = ();
		my regex id { \d+ };
		my regex frameref { '|<'\d+'>|' };
		my regex valid { :i <[a..z]+[0..9]>+ };
		my regex pair { <&valid>'=>'(<&frameref>|<&valid>) };
		my $id = +(($frame ~~ m/<&id>/).Str);
		$.id = $id;
		my @pairs = (m:g/<&pair>/ given $frame)>>.Str;
		for @pairs -> $pair {
			my ($key, $value) = $pair.split('=>');
			if $value ~~ m/<&frameref>/ {
				push @framereqs, $key => $value;
			} else {
				self.put($key, $value, $overwrite);
			}
		}
		($id, @framereqs);
	}

	method WHICH() {
		"SimNet::Frame|$.id";
	}
}

sub loadFrames($str) is export {
	my @list = $str.split(' ');
	my %framedex;
	my @unsatisfied;
	for @list {
		my $frame = SimNet::Frame.new;
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
