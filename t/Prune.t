use v6;
use Test;
use SimNet::Net;
use SimNet::Frames;
use PokeEnv::Entity::Agent;
use PokeEnv::IO::WorldBuilder;
use PokeEnv::Grid;
use TestUtils::Utils;
use TestData;

my %verbFrames = loadFrames(open('frames/verbs.in').slurp);
my $verbNetwork = SimNet::Network.new(%verbFrames);
my %nounFrames = loadFrames(open('frames/nouns.in').slurp);
my $nounNetwork = SimNet::Network.new(%nounFrames);

sub pick_prune(@list is copy, $l, $pos is copy) {

	if $l < 1 {
		return @list;
	} else {
		say "Data: $l $pos " ~ @list.elems;
		my @replacement;
		for 0..^$l {
			push @replacement, 0;
		}
		my @pulled = @list.splice($pos, $l, @replacement);
		if testRun(@list, $verbNetwork, $nounNetwork) ~~ "success" {
			@list.splice($pos, $l);
			$pos -= $l;
		} else {
			for 0..^@pulled.elems {
				@list[$_ + $pos] = @pulled[$_];
			}
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

#my $str = open('testdata.in').slurp;
#my %hash = EVAL($str);
my %hash = getTestHash;

say "Test run: ";
testRun(%hash{0}, $verbNetwork, $nounNetwork);
say "Real: ";
#for %hash.keys {
#	say %hash{$_}.list.elems;
#}

for %hash.keys -> $rid {
#say pick_prune(%hash{1}.list);
#	$count = 0;
	say "Sequence $rid";
	%hash{$rid} = pick_prune(%hash{$rid}.list, %hash{$rid}.list.elems - 1, 0);
}

say %hash;

# vim: ft=perl6
