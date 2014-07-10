use v6;
use TestUtils::Utils;
use SimNet::Net;

my $mutateChance = 300;

multi sub infix:«←→»(Any $lhs, Any $rhs) {
	if (^2).roll == 0 {
		($lhs, $rhs);
	} else {
		($rhs, $lhs);
	}
}

sub toFrameCodes(@list) {
	my @ret;
	for @list { 
		push @ret, :2($_.list.Str.subst(' ', '', :g));
	}
	@ret;
}

sub toChromosome(@list) {
	my @ret;
	for @list {
		my $b2 = $_.base(2);
		my @gene;
		for ^"$b2".chars {
			@gene.push($b2.substr($_,1));
		}
		for "$b2".chars..^4 {
			@gene.unshift(0);
		}
		push @ret, @gene.item;
	}
	@ret;
}

sub getFitness(@sequence) {
	my $verbNetwork = SimNet::Network.new('frames/verbs.in');
	my $nounNetwork = SimNet::Network.new('frames/nouns.in');
	my @list = toFrameCodes(@sequence);
	my $fitness = @list.elems;
	for @list {
		if $_ != 0 {
			$fitness--;
		}
	}
	my $exitcode = testRun(@list, $verbNetwork, $nounNetwork);
	if $exitcode ~~ "timeout" {
		$fitness = 1;
	}
	$fitness;
}

sub getFitnesses(@population) {
	my @fitnesses;
	my $sum = 0;
	for ^@population.elems {
		@fitnesses[$_] = getFitness(@population[$_]) + $sum;
		$sum = @fitnesses[$_];
	}
	($sum, @fitnesses);
}

sub select2($check, @fitnesses) {
	for ^@fitnesses.elems {
		if $check < @fitnesses[$_] {
			return $_;
		}
	}
}

sub select(@population, $max, @fitnesses) {
	my $p1 = select2((^$max).roll, @fitnesses);
	my $p2 = $p1;
	while $p2 ~~ $p1 {
		$p2 = select2((^$max).roll, @fitnesses);
	}
	return $p1 ←→ $p2;
}

# splice between genes (one splice per individual)
sub cross1(@p1, @p2) {
	# Do we want to cross on the individual level or the chromosome level?
	# One chromosome = One action
	# TODO
	say "cross1";
}

# splice within genes (one splice per gene)
sub cross2(@p1, @p2) {
	# TODO
	say "cross2";
}

# splice anywhere (one splice per individual)
sub cross3(@p1 is copy, @p2 is copy) {
	my $division = (0..@p1.elems).roll;
	say "1";
	say "p1: " ~ @p1.elems;
	my @ret = @p1.splice(0, $division);
	say "2";
	say "p2: " ~ @p2.elems;
	say "div: $division";
	push @ret, @p2.splice($division, @p2.elems - $division);
	say "3";
	for ^(@ret.elems % 4) {
		@ret.splice($_, 4, (@ret[$_..^$_+4]).item);
	}
	say "4";
	@ret;
}

sub mutate(@individual is rw) {
	for ^@individual.elems {
		if (^$mutateChance).roll == 0 {
			@individual[$_] = abs(@individual[$_] - 1);
		}
	}
	@individual;
}

sub generation(@population) {
	my @gen;
	my ($max, @fitnesses) = getFitnesses(@population);
	for ^@population.elems {
		my ($p1, $p2) = select(@population, $max, @fitnesses);
#		¿(&cross1, &cross2, &cross3), @population[$p1].item, @population[$p2].item¿;
		push @gen, mutate(cross3(@population[$p1], @population[$p2]));
	}
	@gen;
}

sub expand($len, @list is copy) {
	for ^$len {
		push @list, 0;
	}
	@list;
}

sub evolve($sayFreq, @pop, :$count=Inf) is export {
	my @chromoPop;
	my $len = [max] @pop».elems;
#	say expand($len, @pop[1]);
	for @pop {
		push @chromoPop, toChromosome(expand($len, $_).list).item;
	}
	for ^$count -> $iter {
		if $iter % $sayFreq == 0 {
			say "Generation $iter";
			for ^@chromoPop.elems {
				say "$_: " ~ toFrameCodes(@chromoPop[$_]).perl;
			}
		}
		@chromoPop = generation(@chromoPop);
	}
	@chromoPop;
}

# vim: ft=perl6
