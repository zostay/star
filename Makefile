PARROT_VER = 4.6.0
PARROT_REL = supported/$(PARROT_VER)
NQP_VER    = 2012.08
RAKUDO_VER = 2012.08

DISTDIR = rakudo-star-$(VERSION)
BUILD_DIR   = $(DISTDIR)/build
SRC_DIR     = src

PARROT      = parrot-$(PARROT_VER)
PARROT_TGZ  = $(PARROT).tar.gz
PARROT_SRC  = $(SRC_DIR)/$(PARROT_TGZ)
PARROT_DIR  = $(DISTDIR)/$(PARROT)

NQP         = nqp-$(NQP_VER)
NQP_TGZ     = $(NQP).tar.gz
NQP_SRC     = $(SRC_DIR)/$(NQP_TGZ)
NQP_DIR     = $(DISTDIR)/$(NQP)

RAKUDO      = rakudo-$(RAKUDO_VER)
RAKUDO_TGZ  = $(RAKUDO).tar.gz
RAKUDO_SRC  = $(SRC_DIR)/$(RAKUDO_TGZ)
RAKUDO_DIR  = $(DISTDIR)/$(RAKUDO)


## If you add a module here, don't forget to update MODULES
## in skel/tools/build/Makefile.in to actually install it
MODULES_DIR = $(DISTDIR)/modules

DISTTARGETS = \
  $(PARROT_SRC) \
  $(NQP_SRC) \
  $(RAKUDO_SRC) \

dist: version_check $(DISTDIR) $(DISTTARGETS)

version_check:
	@[ -n "$(VERSION)" ] || ( echo "\nTry 'make release VERSION=yyyy.mm'\n\n"; exit 1)

always:

$(DISTDIR): always
	mkdir -p $(DISTDIR)
	echo $(VERSION) >$(DISTDIR)/VERSION
	cp -av skel/. $(DISTDIR)

$(PARROT_DIR): $(PARROT_SRC)
	tar -C $(DISTDIR) -xvzf $(PARROT_SRC)

$(PARROT_SRC):
	mkdir -p $(SRC_DIR)
	wget http://ftp.parrot.org/releases/$(PARROT_REL)/$(PARROT_TGZ) -o $(PARROT_SRC)

$(NQP_DIR): $(NQP_TGZ)
	tar -C $(DISTDIR) -xvzf $(NQP_TGZ)

$(NQP_SRC):
	mkdir -p $(SRC_DIR)
	wget --no-check-certificate https://github.com/downloads/perl6/nqp/$(NQP_TGZ) -o $(NQP_SRC)

$(RAKUDO_DIR): $(RAKUDO_TGZ)
	tar -C $(DISTDIR) -xvzf $(RAKUDO_TGZ)
	
$(RAKUDO_SRC):
	mkdir -p $(SRC_DIR)
	wget --no-check-certificate https://github.com/downloads/rakudo/rakudo/$(RAKUDO_TGZ) -o $(RAKUDO_SRC)

$(MODULES_DIR): always
	mkdir -p $(MODULES_DIR)
	cd $(MODULES_DIR); for repo in $(MODULES); do git clone $$repo.git; done
	# cd $(MODULES_DIR)/yaml-pm6; git checkout rakudo-star-1
	cd $(MODULES_DIR)/panda; git checkout 04b67556b56edd0c4599fc20c9c7e49a292b0cc1

star-patches:
	[ ! -f build/$(VERSION)-patch.pl ] || DISTDIR=$(DISTDIR) perl build/$(VERSION)-patch.pl

$(DISTDIR)/MANIFEST:
	touch $(DISTDIR)/MANIFEST
	find $(DISTDIR) -name '.git' -prune -o -type f -print | sed -e 's|^[^/]*/||' | sort >$(DISTDIR)/MANIFEST

release: dist tarball

tarball:
	perl -ne 'print "$(DISTDIR)/$$_"' $(DISTDIR)/MANIFEST |\
	    tar -zcv -T - -f $(DISTDIR).tar.gz
