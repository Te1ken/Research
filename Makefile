.PHONY: all build test install clean distclean purge

PERL6  = perl6-m
DESTDIR= 
PREFIX = /home/Phoenix/.perl6/rakudo-star-2014.04/install/languages/perl6/site
BLIB   = blib
P6LIB  = $(PWD)/$(BLIB)/lib:$(PWD)/lib:$(PERL6LIB)
CP     = cp -p
MKDIR  = mkdir -p


BLIB_COMPILED =

all build: $(BLIB_COMPILED)



test: build
	env PERL6LIB=$(P6LIB) prove -e '$(PERL6)' -r t/

loudtest: build
	env PERL6LIB=$(P6LIB) prove -ve '$(PERL6)' -r t/

timetest: build
	env PERL6LIB=$(P6LIB) PERL6_TEST_TIMES=1 prove -ve '$(PERL6)' -r t/

install: $(BLIB_COMPILED)


clean:
	rm -fr $(BLIB)

distclean purge: clean
	rm -r Makefile
