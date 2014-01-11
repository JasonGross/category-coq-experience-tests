HOTT_HOTT_CONFIGURE_ARGUMENTS :=

all: HoTT/HoTT.timing-raw

.PHONY: all clean git-clean

HoTT/HoTT/configure: HoTT/HoTT/autogen.sh
	cd HoTT/HoTT && ./autogen.sh

HoTT/HoTT/Makefile: HoTT/HoTT/configure
	cd HoTT/HoTT && ./configure $(HOTT_HOTT_CONFIGURE_ARGUMENTS)

HoTT/HoTT.timing-raw: HoTT/HoTT/Makefile HoTT/HoTT
	(cd HoTT/HoTT && $(MAKE) clean && $(MAKE) TIMED=1 2>&1) | tee $@

clean:
	rm -f HoTT/HoTT.timing-raw

git-clean: clean
	git submodule foreach 'git clean -xfd'
