use v6;
use Test;
use SimNet::Net;
use SimNet::Frames;
use PokeEnv::Entity::Agent;
use PokeEnv::IO::WorldBuilder;
use PokeEnv::Grid;

my %verbFrames = loadFrames(open('frames/verbs.in').slurp);
my $verbNetwork = SimNet::Network.new(%verbFrames);
my %nounFrames = loadFrames(open('frames/nouns.in').slurp);
my $nounNetwork = SimNet::Network.new(%nounFrames);

my $count = 0;

sub testRun(@list is copy) {
	$count++;
	say $count ~ ": " ~ time ~ "(" ~ @list.elems ~ ")";
	my $world = import("world.in");
	my $grid = $world.getLevel("overworld").getLayer("active");
	my $loc = PokeEnv::Location.new(1, 1, $grid, "S");
	my $frameagent = PokeEnv::Entity::FrameAgent.new($verbNetwork, $nounNetwork, $loc, "FrameAgent", 15, @list, $world);
	$grid.put($loc, $frameagent);
	$world.spawn_agent($frameagent);

	$world.run(@list.elems);
	say $world.exitcode;
	$world.exitcode;
}

sub pick_prune(@list is copy, $l, $pos) {
	if $l < 1 {
		return @list;
	}
	say "Data: $l $pos " ~ @list.elems;
	my @replacement;
	for 0..^$l {
		push @replacement, 0;
	}
	my @pulled = @list.splice($pos, $l, @replacement);
	if testRun(@list) ~~ "success" {
		@list.splice($pos, $l);
	} else {
		for 0..^@pulled.elems {
			@list[$_ + $pos] = @pulled[$_];
		}
	}

	if $l >= @list.elems {
		pick_prune(@list, floor(@list.elems / 2), 0);
	} elsif ($pos + $l) + $l >= @list.elems {
		pick_prune(@list, floor($l / 2), 0);
	} else {
		pick_prune(@list, $l, $pos + $l);
	}
}

my %hash = EVAL(open('testdata.in').slurp);

for %hash.keys {
	say %hash{$_}.list.elems;
}

for %hash.keys -> $rid {
#say pick_prune(%hash{1}.list);
	$count = 0;
	say "Sequence $rid";
	%hash{$rid} = pick_prune(%hash{$rid}.list, %hash{$rid}.list.elems - 1, 0);
}

say %hash;

# vim: ft=perl6
