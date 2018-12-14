NAME = zfs-prune-snapshots
MAN_SECTION ?= 1

PREFIX ?= /usr/local

MANPAGE = $(NAME).$(MAN_SECTION)

.PHONY: all
all:
	@echo 'nothing to do'

.PHONY: man
man: man/$(MANPAGE)
man/$(MANPAGE): man/$(NAME).md
	md2man-roff $^ > $@

.PHONY: clean
clean:
	rm -f man/$(MANPAGE)

.PHONY: install
install:
	install -d $(DESTDIR)/$(PREFIX)/bin
	install -d $(DESTDIR)/$(PREFIX)/share/man/man$(MAN_SECTION)
	install -m 0755 $(NAME) $(DESTDIR)/$(PREFIX)/bin/$(NAME)
	install -m 0644 man/$(MANPAGE) $(DESTDIR)/$(PREFIX)/share/man/man$(MAN_SECTION)/$(MANPAGE)

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)/$(PREFIX)/bin/$(NAME)
	rm -f $(DESTDIR)/$(PREFIX)/share/man/man$(MAN_SECTION)/$(MANPAGE)

.PHONY: check
check:
	awk 'length($$0) > 80 { exit(1); }' $(NAME)
	shellcheck $(NAME)
