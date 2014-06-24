use v6;
use SimNet::Frames;

my %frames = loadFrames(':0{testKey=>testVal,key2=>val2}: :1{isa=>|<1>|,name=>one}:');
say %frames{0};


# vim: ft=perl6
