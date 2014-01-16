HOTT_HOTT_CONFIGURE_ARGUMENTS :=

all: timing stats

.PHONY: all clean git-clean HoTT-coq coqs coq-8.3 coq-8.4 stats timing

clean:
	rm -f HoTT/HoTT.timing-raw HoTT/HoTT.timing megacz/coq-categories.timing-raw megacz/coq-categories.timing megacz/coq-categories.stats benediktahrens/coq-fossil.timing-raw benediktahrens/coq-fossil.timing benediktahrens/coq-fossil.stats ConCaT.timing ConCaT.stats

stats: HoTT/HoTT.stats megacz/coq-categories.stats benediktahrens/coq-fossil.stats ConCaT.stats

timing: HoTT/HoTT.timing megacz/coq-categories.timing benediktahrens/coq-fossil.timing ConCaT.timing

git-clean: clean
	git submodule foreach 'git clean -xfd'

%.timing: %.timing-raw
	grep 'user' $< | grep -v 'usr/bin/time' | sed s'/\(.*\) (user: \(.*\) mem: \(.*\) ko)$$/"\1":{"user":\2, "mem":\3},/g' | tr '\n' ' ' | sed s'/^\(.*\), $$/{\1}\n/g' | tee $@

%.timing-agda: %.timing-agda-raw
	cat $< | python format-agda-times.py | tr '\n' ' ' | sed s'/, }/}/g' | tee $@

################################################################################
##                                 HoTT/HoTT                                  ##
################################################################################
HoTT/HoTT/configure: HoTT/HoTT/autogen.sh
	cd HoTT/HoTT && ./autogen.sh

HoTT/HoTT/Makefile: HoTT/HoTT/configure HoTT/coq/bin/coqc
	cd HoTT/HoTT && ./configure COQBIN=../coq/bin $(HOTT_HOTT_CONFIGURE_ARGUMENTS)

HoTT/HoTT.timing-raw: HoTT/HoTT/Makefile HoTT/HoTT
	(cd HoTT/HoTT && $(MAKE) clean && $(MAKE) TIMED=1 2>&1 | grep categories) | tee $@

HoTT/HoTT.stats:
	cd HoTT/HoTT/theories/categories; find . -name "*.v" | xargs ../../../../make-stats.sh | sed s'/, }/}/g' | tee ../../../HoTT.stats

################################################################################
##                                 HoTT/coq                                   ##
################################################################################
HoTT/coq/config/Makefile: HoTT/coq/configure
	cd HoTT/coq && ./configure -local -no-native-compiler -nodoc -coqide no

HoTT/coq/bin/coqc: HoTT/coq HoTT/coq/config/Makefile
	cd HoTT/coq && $(MAKE) coqlight

HoTT-coq: HoTT/coq/bin/coqc

################################################################################
##                               coq/coq-8.3                                  ##
################################################################################
coq/coq-8.3/config/Makefile: coq/coq-8.3/configure
	cd coq/coq-8.3 && ./configure -local -with-doc no -coqide no

coq/coq-8.3/bin/coqc: coq/coq-8.3 coq/coq-8.3/config/Makefile
	cd coq/coq-8.3 && $(MAKE)

coq-8.3: coq/coq-8.3/bin/coqc

################################################################################
##                               coq/coq-8.4                                  ##
################################################################################
coq/coq-8.4/config/Makefile: coq/coq-8.4/configure
	cd coq/coq-8.4 && ./configure -local -with-doc no -coqide no

coq/coq-8.4/bin/coqc: coq/coq-8.4 coq/coq-8.4/config/Makefile
	cd coq/coq-8.4 && $(MAKE)

coq-8.4: coq/coq-8.4/bin/coqc



################################################################################
##                                      coqs                                  ##
################################################################################
coqs: coq-8.3 coq-8.4 HoTT-coq


################################################################################
##                                  Agda                                      ##
################################################################################
Agda/configure: Agda/configure.ac
	cd Agda; autoreconf -fvi

Agda/Makefile: Agda/configure
	cd Agda; ./configure

Agda/cabal.sandbox.config:
	cd Agda; cabal sandbox init

Agda/.cabal-sandbox/bin/agda: Agda/configure Agda/cabal.sandbox.config
	cd Agda; $(MAKE)

agda: Agda/.cabal-sandbox/bin/agda

################################################################################
##                                Agda-2.3.2.2                                  ##
################################################################################

Agda-2.3.2.2/cabal.sandbox.config:
	mkdir -p Agda-2.3.2.2; cd Agda-2.3.2.2; cabal sandbox init

Agda-2.3.2.2/.cabal-sandbox/bin/agda: Agda-2.3.2.2/cabal.sandbox.config
	cd Agda-2.3.2.2; cabal install Agda-2.3.2.2

################################################################################
##                                  agda-lib                                  ##
################################################################################
agda-lib/src/%.agdai: agda-lib/src/%.agda Agda/.cabal-sandbox/bin/agda
	cd agda-lib/src; ../../Agda/.cabal-sandbox/bin/agda ${<:agda-lib/src/%=%}

agda-stdlib: agda-lib/src/Algebra.agdai agda-lib/src/Coinduction.agdai agda-lib/src/Function.agdai agda-lib/src/Induction.agdai agda-lib/src/IO.agdai agda-lib/src/Irrelevance.agdai agda-lib/src/Level.agdai agda-lib/src/Record.agdai agda-lib/src/Reflection.agdai agda-lib/src/Size.agdai agda-lib/src/Universe.agdai


################################################################################
##                                  lib-0.7                                  ##
################################################################################
lib-0.7/src/%.agdai: lib-0.7/src/%.agda Agda-2.3.2.2/.cabal-sandbox/bin/agda
	cd lib-0.7/src; ../../Agda-2.3.2.2/.cabal-sandbox/bin/agda ${<:lib-0.7/src/%=%}

agda-stdlib-0.7: lib-0.7/src/Algebra.agdai lib-0.7/src/Coinduction.agdai lib-0.7/src/Function.agdai lib-0.7/src/Induction.agdai lib-0.7/src/IO.agdai lib-0.7/src/Irrelevance.agdai lib-0.7/src/Level.agdai lib-0.7/src/Record.agdai lib-0.7/src/Reflection.agdai lib-0.7/src/Size.agdai lib-0.7/src/Universe.agdai

################################################################################
##                         compumpkin/categories                              ##
################################################################################
copumpkin_categories_files := $(shell find copumpkin/categories -name "*.agda")
copumpkin_categories_files_i := ${copumpkin_categories_files:%.agda=%.agdai}

copumpkin/categories.timing-agda-raw: agda-stdlib-0.7 Agda-2.3.2.2/.cabal-sandbox/bin/agda $(copumpkin_categories_files) insert-times.sh
	(cd copumpkin/categories; find . -name "*.agdai" | xargs rm; for i in Everything.agda $$(find . -name "*.agda" | sed s'/agda$$/agdai/g' | tr '\n' ' '); do ../../Agda-2.3.2.2/.cabal-sandbox/bin/agda "$$i" -i . -i ../../lib-0.7/src/; done) | ./insert-times.sh | tee $@

################################################################################
##                         megacz/coq-categories                              ##
################################################################################
megacz_coq-categories_coqfiles := $(shell find megacz/coq-categories/src -name \*.v)
megacz_coq-categories_allfiles := $(megacz_coq-categories_coqfiles) $(shell find megacz/coq-categories/src -name \*.hs)

megacz/coq-categories.timing-raw: $(megacz_coq-categories_allfiles) megacz/coq-categories/build/Makefile.coq coq/coq-8.3/bin/coqc
	(cd megacz/coq-categories/build; $(MAKE) -f Makefile.coq clean; $(MAKE) COQBIN=../../../coq/coq-8.3/bin/ OPT="-opt -dont-load-proofs" -f Makefile.coq Main.vo 2>&1) | tee $@

megacz/coq-categories/build/Makefile.coq: $(megacz_coq-categories_coqfiles)
	cd megacz/coq-categories; mkdir -p build
	cd megacz/coq-categories; rm -f build/*.v
	cd megacz/coq-categories; rm -f build/*.d
	cd megacz/coq-categories/build; ln -s ../src/*.v .
	cd megacz/coq-categories/build; ../../../coq/coq-8.3/bin/coq_makefile COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' *.v -o Makefile.coq

megacz/coq-categories.stats: $(megacz_coq-categories_coqfiles)
	(cd megacz/coq-categories/src; find . -name "*.v" | xargs ../../../make-stats.sh | sed s'/, }/}/g') | tee $@

################################################################################
##                      benediktahrens/coq-fossil                             ##
################################################################################
benediktahrens_coq-fossil_coqfiles := $(shell find benediktahrens/coq-fossil -name \*.v)

benediktahrens/coq-fossil.timing-raw: benediktahrens/coq-fossil/Makefile.coq coq/coq-8.3/bin/coqc
	(cd benediktahrens/coq-fossil; $(MAKE) -f Makefile.coq clean; $(MAKE) COQBIN=../../coq/coq-8.3/bin/ -f Makefile.coq 2>&1) | tee $@

benediktahrens/coq-fossil/Makefile.coq: benediktahrens/coq-fossil/Make
	cd benediktahrens/coq-fossil; ../../coq/coq-8.3/bin/coq_makefile -f Make COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M k\
o)" $$(COQBIN)coqc' -o Makefile.coq

benediktahrens/coq-fossil.stats: $(benediktahrens_coq-fossil_coqfiles)
	(cd benediktahrens/coq-fossil; find . -name "*.v" | xargs ../../make-stats.sh | sed s'/, }/}/g') | tee $@

################################################################################
##                                ConCaT                                      ##
################################################################################
concat_coqfiles := $(shell find ConCaT -name "*.v")

ConCaT.timing-raw: $(concat_coqfiles) ConCaT/Makefile.coq coq/coq-8.4/bin/coqc
	(cd ConCaT; $(MAKE) -f Makefile.coq clean; $(MAKE) COQBIN=../coq/coq-8.4/bin/ -f Makefile.coq 2>&1) | tee $@

ConCaT/Makefile.coq: $(concat_coqfiles)
	cd ConCaT; ../coq/coq-8.4/bin/coq_makefile -f Make COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' -o Makefile.coq

ConCaT.stats: $(concat_coqfiles)
	(cd ConCaT; find . -name "*.v" | xargs ../make-stats.sh | sed s'/, }/}/g') | tee $@
