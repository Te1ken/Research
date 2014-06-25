use v6;
use SimNet::Frames;

my %frames = loadFrames(':0{testKey=>testVal,key2=>val2}: :1{isa=>|<0>|,name=>test}:');
say %frames{0}.get("testKey");
say %frames{1}.get("testKey");
say %frames{1}.get("jkladg");

# vim: ft=perl6
