use v6;
use SimNet::Frames;

module SimNet::Net;

class SimNet::Network {
	has 	%.master is rw;
	has	$!MAX_DIFF = 2;
	method new($path) {
		my $ret = self.bless();
		$ret.load($path);
		$ret;
	}

	method load($path) {
		%.master = loadFrames(open($path).slurp, self);
		self.buildNet;
	}

	method buildNet() {
		for %.master.keys -> $key {
			my $frame = %.master{$key};
			for %.master.keys -> $checkKey {
				if !($checkKey ~~ $key) {
					my $diffCount = 0;
					my $checkFrame = %.master{$checkKey};
					for $frame.data.keys -> $slot {
						if $slot ne "isa" && $slot ne "diff" && (!($checkFrame.data{$slot}:exists) || !($checkFrame.data{$slot} ~~ %.master{$slot})) {
							$diffCount++;
						}
					}
					if $diffCount <= $!MAX_DIFF {
						$frame.put("diff", $checkFrame);
					}
				}
			}
		}
	}
}

# vim: ft=perl6
