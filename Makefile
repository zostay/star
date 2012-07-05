PARROT_VER = 4.5.0
PARROT_REL = devel/$(PARROT_VER)
NQP_VER    = 2012.06.1
RAKUDO_VER = 2012.06

DISTDIR = rakudo-star-$(VERSION)
BUILD_DIR   = $(DISTDIR)/build

PARROT      = parrot-$(PARROT_VER)
PARROT_TGZ  = $(PARROT).tar.gz
PARROT_DIR  = $(DISTDIR)/$(PARROT)

NQP         = nqp-$(NQP_VER)
NQP_TGZ     = $(NQP).tar.gz
NQP_DIR     = $(DISTDIR)/$(NQP)

RAKUDO      = rakudo-$(RAKUDO_VER)
RAKUDO_TGZ  = $(RAKUDO).tar.gz
RAKUDO_DIR  = $(DISTDIR)/$(RAKUDO)


## If you add a module here, don't forget to update MODULES
## in skel/tools/build/Makefile.in to actually install it
MODULES_DIR = $(DISTDIR)/modules
MODULES = \
  git://github.com/masak/ufo \
  git://github.com/jnthn/zavolaj \
  git://github.com/masak/xml-writer \
  git://github.com/moritz/svg \
  git://github.com/moritz/Math-RungeKutta \
  git://github.com/moritz/svg-plot \
  git://github.com/moritz/Math-Model \
  git://github.com/tadzik/perl6-Term-ANSIColor \
  git://github.com/jnthn/test-mock \
  git://github.com/perlpilot/Grammar-Profiler-Simple \
  git://github.com/jnthn/grammar-debugger \
  git://github.com/moritz/json \
  git://github.com/snarkyboojum/Perl6-MIME-Base64 \
  git://github.com/cosimo/perl6-digest-md5 \
  git://github.com/tadzik/perl6-File-Tools \
  git://github.com/tadzik/panda \
  git://github.com/supernovus/perl6-http-status \
  git://github.com/moritz/perl6-http-easy \
  git://github.com/tadzik/Bailador \
  git://github.com/perl6/DBIish \
  git://github.com/ihrd/uri \
  git://github.com/cosimo/perl6-lwp-simple \
  git://github.com/bbkr/jsonrpc \
  git://github.com/perl6/Pod-To-HTML \
  git://github.com/perl6/doc \

DISTTARGETS = \
  $(PARROT_DIR) \
  $(NQP_DIR) \
  $(RAKUDO_DIR) \
  $(MODULES_DIR) \
  star-patches \
  $(DISTDIR)/MANIFEST \

dist: version_check $(DISTDIR) $(DISTTARGETS)

version_check:
	@[ -n "$(VERSION)" ] || ( echo "\nTry 'make VERSION=yyyy.mm'\n\n"; exit 1)

always:

$(DISTDIR): always
	mkdir -p $(DISTDIR)
	cp -av skel/. $(DISTDIR)
	perl build/skel-template.pl $(DISTDIR)

$(PARROT_DIR): $(PARROT_TGZ)
	tar -C $(DISTDIR) -xvzf $(PARROT_TGZ)

$(PARROT_TGZ):
	wget http://ftp.parrot.org/releases/$(PARROT_REL)/$(PARROT_TGZ)

$(NQP_DIR): $(NQP_TGZ)
	tar -C $(DISTDIR) -xvzf $(NQP_TGZ)

$(NQP_TGZ):
	wget --no-check-certificate https://github.com/downloads/perl6/nqp/$(NQP_TGZ)

$(RAKUDO_DIR): $(RAKUDO_TGZ)
	tar -C $(DISTDIR) -xvzf $(RAKUDO_TGZ)
	
$(RAKUDO_TGZ):
	wget --no-check-certificate https://github.com/downloads/rakudo/rakudo/$(RAKUDO_TGZ)

$(MODULES_DIR): always
	mkdir -p $(MODULES_DIR)
	cd $(MODULES_DIR); for repo in $(MODULES); do git clone $$repo.git; done
	# use versions before the &dir API change
	cd $(MODULES_DIR)/ufo; git checkout e889d21c3bbee0f49b3a6d8ef6a6593c6be24ac9
	cd $(MODULES_DIR)/perl6-File-Tools; git checkout 4573308b3572ad3abe47b5a685697c6e31d30a78
	cd $(MODULES_DIR)/panda; git checkout 30a73cae58bca562019250cbff76ff950c640a2c
	# cd $(MODULES_DIR)/yaml-pm6; git checkout rakudo-star-1

star-patches:
	[ ! -f build/$(VERSION)-patch.pl ] || DISTDIR=$(DISTDIR) perl build/$(VERSION)-patch.pl

$(DISTDIR)/MANIFEST:
	touch $(DISTDIR)/MANIFEST
	find $(DISTDIR) -name '.*' -prune -o -type f -print | sed -e 's|^[^/]*/||' >$(DISTDIR)/MANIFEST
	## add the two dot-files from Parrot MANIFEST
	echo "$(PARROT)/.gitignore" >>$(DISTDIR)/MANIFEST
	echo "$(PARROT)/tools/dev/.gdbinit" >>$(DISTDIR)/MANIFEST
	sort -o $(DISTDIR)/MANIFEST $(DISTDIR)/MANIFEST

release: dist tarball

tarball:
	perl -ne 'print "$(DISTDIR)/$$_"' $(DISTDIR)/MANIFEST |\
	    tar -zcv -T - -f $(DISTDIR).tar.gz
