use v6;
use PokeEnv::World;
use PokeEnv::Grid;
use PokeEnv::Entity::Entity;
use PokeEnv::Entity::Wall;
use PokeEnv::Entity::Teleporter;
use PokeEnv::Entity::Agent;
use PokeEnv::Entity::RandomAgent;

module PokeEnv::IO::WorldBuilder;

sub addLevel(@line, $world) {
	my ($pref, $level_id, $width, $height) = @line;
	$width = +$width;
	$height = +$height;
	my $level = PokeEnv::Level.new($width, $height, $level_id);
	$world.addLevel($level);
	$level;
}

sub addLayer(@line, $world) {
	my ($pref, $level, $name) = @line;
	my $lev = $world.getLevel($level);
	my $layer = PokeEnv::BoundedGrid.new($lev.width, $lev.height);
	$lev.addLayer($name, $layer);
	$layer;
}

sub addEntity(@line, $world, $uid) {
	my ($pref, $type, $level, $layer, $x, $y, $dir, @rest) = @line;
	my $grid = $world.getLevel($level).getLayer($layer);
	my $loc = PokeEnv::Location.new(+$x, +$y, $grid, $dir);
	my $ent;
	EVAL '$ent = PokeEnv::Entity::' ~ $type ~ '.new($loc, $type, $uid, @rest, $world);';
	$grid.put($loc, $ent);
	$ent;
}

sub addAgent(@line, $world, $uid) {
	my ($pref, $type, $level, $layer, $x, $y, $dir, @rest) = @line;
	my $grid = $world.getLevel($level).getLayer($layer);
	my $loc = PokeEnv::Location.new(+$x, +$y, $grid, $dir);
	my $agent;
	EVAL '$agent = PokeEnv::Entity::' ~ $type ~ '.new($loc, $type, $uid, @rest, $world);';
	$grid.put($loc, $agent);
	$world.spawn_agent($agent);
	$agent;
}

sub import($f) is export {
	my $file = open $f;
	my @lines = $file.lines;
	$file.close;
	my $world = PokeEnv::World.new();
	my $entCount = 0;
	for @lines -> $l {
		my @decomp = $l.words;
		if @decomp[0] eq "LEVEL" {
			addLevel(@decomp, $world);
		} elsif @decomp[0] eq "LAYER" {
			addLayer(@decomp, $world);
		} elsif @decomp[0] eq "ENTITY" {
			addEntity(@decomp, $world, $entCount);
			$entCount++;
		} elsif @decomp[0] eq "AGENT" {
			addAgent(@decomp, $world, $entCount);
			$entCount++;
		}
	}
	$world;
}

# vim: ft=perl6
