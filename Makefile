PARROT_VER = 4.6.0
PARROT_REL = supported/$(PARROT_VER)
NQP_VER    = 2012.08
RAKUDO_VER = 2012.08

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

DISTTARGETS = \
  $(PARROT_DIR) \
  $(NQP_DIR) \
  $(RAKUDO_DIR) \

dist: version_check $(DISTDIR) $(DISTTARGETS)

version_check:
	@[ -n "$(VERSION)" ] || ( echo "\nTry 'make release VERSION=yyyy.mm'\n\n"; exit 1)

always:

$(DISTDIR): always
	mkdir -p $(DISTDIR)
	echo $(VERSION) >$(DISTDIR)/VERSION
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

$(DISTDIR)/MANIFEST:
	touch $(DISTDIR)/MANIFEST
	find $(DISTDIR) -name '.git' -prune -o -type f -print | sed -e 's|^[^/]*/||' | sort >$(DISTDIR)/MANIFEST

release: dist tarball

tarball:
	perl -ne 'print "$(DISTDIR)/$$_"' $(DISTDIR)/MANIFEST |\
	    tar -zcv -T - -f $(DISTDIR).tar.gz
