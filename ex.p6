use v6;

class A {
	has $.b;
	method new($b) {
		self.bless(:$b);
	}
}

class B {
	has %.hash;
	method new() {
		self.bless();
	}
	method set($a, $val) {
		%.hash{$a} = $val;
	}
}

my $b = B.new();
my $a = A.new($b);
$b.set($a, "test");
say $b.hash;
