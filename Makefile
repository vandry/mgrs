SDK=/opt/iphonedev
BINPREF=/bin/arm-apple-darwin9-
CC=$(SDK)$(BINPREF)gcc
LD=$(CC)
AR=$(SDK)$(BINPREF)ar
LDFLAGS=-Lmgrslib -lobjc \
	-framework CoreFoundation \
	-framework Foundation \
	-framework UIKit \
	-framework Celestial \
	-framework AppSupport \
	-framework SpringBoardServices \
	-F$(SDK)/sys/System/Library/PrivateFrameworks
CFLAGS=-march=armv6 -mcpu=arm1176jzf-s -g

APPDIR=$(DESTDIR)/Applications/MGRS.app

INSTALL_DATA=MGRS.app/bg_normal.png MGRS.app/Info.plist
INSTALL_EXEC=MGRS.app/MGRS

OBJ=MGRSapp.o

all: MGRS.app/MGRS MGRS.app/bg_normal.png

package:
	DPKG_DATADIR=`pwd`/dpkg.d dpkg-buildpackage -us -uc -rfakeroot -aiphoneos-arm -tiphoneos-arm

MGRS.app/MGRS: MGRS
	CODESIGN_ALLOCATE=$(SDK)$(BINPREF)codesign_allocate ldid -S MGRS && cp MGRS MGRS.app

MGRS.app/bg_normal.png: bg_normal.svg
	rsvg bg_normal.svg $@

MGRS: $(OBJ) mgrslib/libmgrs.a
	$(LD) $(LDFLAGS) -o $@ $(OBJ) -lmgrs

install: $(INSTALL_DATA) $(INSTALL_EXEC)
	for x in $(INSTALL_DATA); do \
		install -m 0644 "$$x" $(APPDIR); \
	done; \
	for x in $(INSTALL_EXEC); do \
		install -m 0755 "$$x" $(APPDIR); \
	done; \

mgrslib/libmgrs.a:
	$(MAKE) -C mgrslib CC="$(CC)" LD="$(LD)" AR="$(AR)" CFLAGS="$(CFLAGS)"

clean:
	rm -f $(OBJ) MGRS MGRS.app/MGRS MGRS.app/bg_normal.png
	$(MAKE) -C mgrslib clean

MGRSapp.o: MGRSapp.m MGRSapp.h

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o: %.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
