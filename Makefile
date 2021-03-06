HOTT_HOTT_CONFIGURE_ARGUMENTS :=

all: timing stats

.PHONY: all clean git-clean HoTT-coq coqs coq-8.3 coq-8.3pl5-foundations coq-8.4 stats timing coq-8.4-foundations foundations-files foundations-8.3-files

clean:
	rm -f HoTT/HoTT.timing-raw HoTT/HoTT.timing megacz/coq-categories.timing-raw megacz/coq-categories.timing megacz/coq-categories.stats benediktahrens/coq-fossil.timing-raw benediktahrens/coq-fossil.timing benediktahrens/coq-fossil.stats ConCaT.timing ConCaT.stats

stats: HoTT/HoTT.stats megacz/coq-categories.stats benediktahrens/coq-fossil.stats ConCaT.stats copumpkin/categories.stats

timing: HoTT/HoTT.timing megacz/coq-categories.timing benediktahrens/coq-fossil.timing ConCaT.timing copumpkin/categories.timing-agda

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
##                        coq/coq-8.3pl5-foundations                          ##
################################################################################
coq/coq-8.3pl5-foundations/config/Makefile: coq/coq-8.3pl5-foundations/configure
	cd coq/coq-8.3pl5-foundations && ./configure -local -with-doc no -coqide no

coq/coq-8.3pl5-foundations/bin/coqc: coq/coq-8.3pl5-foundations coq/coq-8.3pl5-foundations/config/Makefile
	cd coq/coq-8.3pl5-foundations && $(MAKE)

coq-8.3pl5-foundations: coq/coq-8.3pl5-foundations/bin/coqc

################################################################################
##                     encap-2/coq83patched-latest/bin/coqtop                 ##
################################################################################

coq-builder/encap-2/coq83patched-latest/bin/coqtop: coq-builder/Makefile
	cd coq-builder; $(MAKE) -C src install-coq83patched

################################################################################
##                               coq/coq-8.4                                  ##
################################################################################
coq/coq-8.4/config/Makefile: coq/coq-8.4/configure
	cd coq/coq-8.4 && ./configure -local -with-doc no -coqide no

coq/coq-8.4/bin/coqc: coq/coq-8.4 coq/coq-8.4/config/Makefile
	cd coq/coq-8.4 && $(MAKE)

coq-8.4: coq/coq-8.4/bin/coqc


################################################################################
##                         coq/coq-8.4-foundations                            ##
################################################################################
foundations_files := $(shell find DanGrayson/Foundations2 -name "*.v")
coq_8_4_foundations_files := ${foundations_files:DanGrayson/Foundations2/%=coq/coq-8.4-foundations/lib/coq/user-contrib/Foundations/%}

foundations-files: $(foundations_files) coq/coq-8.4-foundations/bin/coqc
	cd DanGrayson/Foundations2; $(MAKE) COQC=../../coq/coq-8.4-foundations/bin/coqc COQBIN=../../coq/coq-8.4-foundations/bin/ && $(MAKE) COQC=../../coq/coq-8.4-foundations/bin/coqc COQBIN=../../coq/coq-8.4-foundations/bin/ install

coq/coq-8.4-foundations/config/Makefile: coq/coq-8.4-foundations/configure
	cd coq/coq-8.4-foundations && ./configure -local -with-doc no -coqide no

coq/coq-8.4-foundations/bin/coqc: coq/coq-8.4-foundations coq/coq-8.4-foundations/config/Makefile
	cd coq/coq-8.4-foundations && $(MAKE)

coq/coq-8.4-foundations/lib/coq/user-contrib/%.v: coq/%.v
	mkdir -p "$$(dirname $@)"; cp "$<" "$@"

coq-8.4-foundations: coq/coq-8.4-foundations/bin/coqc $(coq_8_4_foundations_files)

################################################################################
##                           coq 8.3 Foundations                              ##
################################################################################
#foundations83_files := $(shell find DanGrayson/Foundations2-83 -name "*.v")
coq_8_3_foundations_files := coq-builder/encap-2/coq83patched-latest/lib/coq/user-contrib/Foundations/hlevel2/stnfsets.vo #${foundations_files:DanGrayson/Foundations2-83/%=coq-builder/encap-2/coq83patched-latest/lib/coq/user-contrib/Foundations/%}

foundations-8.3-files: coq-builder/encap-2/coq83patched-latest/bin/coqtop
	cd DanGrayson/Foundations2-83; $(MAKE) COQC=../../coq-builder/encap-2/coq83patched-latest/bin/coqc COQBIN=../../coq-builder/encap-2/coq83patched-latest/bin/ && $(MAKE) COQC=../../coq-builder/encap-2/coq83patched-latest/bin/coqc COQBIN=../../coq-builder/encap-2/coq83patched-latest/bin/ install

coq-builder/encap-2/coq83patched-latest/lib/coq/user-contrib/Foundations/hlevel2/stnfsets.vo: coq-builder/encap-2/coq83patched-latest/bin/coqtop
	cd coq-builder; $(MAKE) -C src install-Foundations2

################################################################################
##                                      coqs                                  ##
################################################################################
coqs: coq-8.3 coq-8.4 HoTT-coq coq-8.4-foundations


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
##                              Agda-2.3.2.2                                  ##
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
	(cd copumpkin/categories; find . -name "*.agdai" | xargs rm; for i in Everything.agda $$(find . -name "*.agda" | tr '\n' ' '); do ../../Agda-2.3.2.2/.cabal-sandbox/bin/agda "$$i" -i . -i ../../lib-0.7/src/; done) | ./insert-times.sh | tee $@

copumpkin/categories.stats: $(copumpkin_categories_coqfiles)
	(cd copumpkin/categories; find . -name "*.agda" | xargs ../../make-agda-stats.sh | sed s'/, }/}/g') | tee $@

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
	cd benediktahrens/coq-fossil; ../../coq/coq-8.3/bin/coq_makefile -f Make COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' -o Makefile.coq

benediktahrens/coq-fossil.stats: $(benediktahrens_coq-fossil_coqfiles)
	(cd benediktahrens/coq-fossil; find . -name "*.v" | xargs ../../make-stats.sh | sed s'/, }/}/g') | tee $@

################################################################################
##                    benediktahrens/rezk_completion                          ##
################################################################################
benediktahrens_rezk_completion_coqfiles := $(shell find benediktahrens/rezk_completion -name \*.v)
#benediktahrens_rezk_completion_foundations_files := ${foundations_files:DanGrayson/Foundations2/%=benediktahrens/rezk_completion/%}


benediktahrens/rezk_completion.timing-raw: benediktahrens/rezk_completion/Makefile.coq coq/coq-8.4-foundations/bin/coqc $(coq_8_4_foundations_files) #$(benediktahrens_rezk_completion_foundations_files)
	(cd benediktahrens/rezk_completion; $(MAKE) -f Makefile.coq clean; $(MAKE) COQBIN=../../coq/coq-8.4-foundations/bin/ -f Makefile.coq 2>&1) | tee $@

benediktahrens/rezk_completion/Makefile.coq: benediktahrens/rezk_completion/Make coq/coq-8.4-foundations/bin/coqc
	cd benediktahrens/rezk_completion; ../../coq/coq-8.4-foundations/bin/coq_makefile -f Make COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' -o Makefile.coq

benediktahrens/rezk_completion.stats: $(benediktahrens_rezk_completion_coqfiles) #$(benediktahrens_rezk_completion_foundations_files)
	(cd benediktahrens/rezk_completion; find . -name "*.v" | xargs ../../make-stats.sh | sed s'/, }/}/g') | tee $@

#benediktahrens/rezk_completion/Foundations/%.vo: coq/Foundations/%.vo
#	mkdir -p "$$(dirname $@)"; cp "$<" "$@"

################################################################################
##                      DanGrayson/rezk_completion                            ##
################################################################################
DanGrayson_rezk_completion_coqfiles := $(shell find DanGrayson/rezk_completion -name \*.v)
#DanGrayson_rezk_completion_foundations_files := ${foundations_files:DanGrayson/Foundations2/%=DanGrayson/rezk_completion/%}


DanGrayson/rezk_completion.timing-raw: DanGrayson/rezk_completion/Makefile.coq coq/coq-8.4-foundations/bin/coqc $(coq_8_4_foundations_files) #$(DanGrayson_rezk_completion_foundations_files)
	(cd DanGrayson/rezk_completion; $(MAKE) -f Makefile.coq clean; $(MAKE) COQBIN=../../coq/coq-8.4-foundations/bin/ -f Makefile.coq 2>&1) | tee $@

DanGrayson/rezk_completion/Makefile.coq: DanGrayson/rezk_completion/Make coq/coq-8.4-foundations/bin/coqc
	cd DanGrayson/rezk_completion; ../../coq/coq-8.4-foundations/bin/coq_makefile -f Make COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' -o Makefile.coq

DanGrayson/rezk_completion.stats: $(DanGrayson_rezk_completion_coqfiles) #$(DanGrayson_rezk_completion_foundations_files)
	(cd DanGrayson/rezk_completion; find . -name "*.v" | xargs ../../make-stats.sh | sed s'/, }/}/g') | tee $@

#DanGrayson/rezk_completion/Foundations/%.vo: coq/Foundations/%.vo
#	mkdir -p "$$(dirname $@)"; cp "$<" "$@"

################################################################################
##                           arxiv/rezk_completion                            ##
################################################################################
arxiv_rezk_completion_coqfiles := $(shell find arxiv/rezk -name \*.v)
#DanGrayson_rezk_completion_foundations_files := ${foundations_files:DanGrayson/Foundations2/%=DanGrayson/rezk_completion/%}

arxiv/rezk.timing-raw: arxiv/rezk/Makefile.coq coq-builder/encap-2/coq83patched-latest/bin/coqtop $(coq_8_3_foundations_files)
	(cd arxiv/rezk; $(MAKE) -f Makefile.coq clean; $(MAKE) COQBIN=../../coq-builder/encap-2/coq83patched-latest/bin/ -f Makefile.coq 2>&1) | tee $@

arxiv/rezk/Makefile.coq: arxiv/rezk/Make coq-builder/encap-2/coq83patched-latest/bin/coqtop
	cd arxiv/rezk; ../../coq-builder/encap-2/coq83patched-latest/bin/coq_makefile -f Make COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' -o Makefile.coq

arxiv/rezk.stats: $(arxiv_rezk_completion_coqfiles) #$(DanGrayson_rezk_completion_foundations_files)
	(cd arxiv/rezk; find . -name "*.v" | xargs ../../make-stats.sh | sed s'/, }/}/g') | tee $@

#arxiv/rezk/Foundations/%.vo: coq/Foundations/%.vo
#	mkdir -p "$$(dirname $@)"; cp "$<" "$@"

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
