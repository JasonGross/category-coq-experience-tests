HOTT_HOTT_CONFIGURE_ARGUMENTS :=

all: HoTT/HoTT.timing megacz/coq-categories.timing megacz/coq-categories.stats

.PHONY: all clean git-clean HoTT-coq coqs coq-8.3 coq-8.4

clean:
	rm -f HoTT/HoTT.timing-raw HoTT/HoTT.timing megacz/coq-categories.timing-raw megacz/coq-categories.timing megacz/coq-categories.stats

git-clean: clean
	git submodule foreach 'git clean -xfd'

%.timing: %.timing-raw
	grep 'user' $< | grep -v 'usr/bin/time' | sed s'/\(.*\) (user: \(.*\) mem: \(.*\) ko)$$/"\1":{"user":\2, "mem":\3},/g' | tr '\n' ' ' | sed s'/^\(.*\), $$/{\1}\n/g' | tee $@

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
	cd megacz/coq-categories/build; ../../../coq/coq-8.3/bin/coq_makefile COQC = '"/usr/bin/time" -f "$$* (user: %U mem: %M ko)" $$(COQBIN)coqc' *.v > Makefile.coq

megacz/coq-categories.stats: $(megacz_coq-categories_coqfiles)
	cd megacz/coq-categories/src; find . -name "*.v" | xargs ../../../make-stats.sh | sed s'/, }/}/g' | tee ../../coq-categories.stats
