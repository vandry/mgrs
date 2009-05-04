SDK=/opt/iphonedev
BINPREF=/bin/arm-apple-darwin9-
CC=$(SDK)$(BINPREF)gcc
LD=$(CC)
AR=$(SDK)$(BINPREF)ar
LDFLAGS=-Lmgrslib -lobjc \
	-framework CoreFoundation \
	-framework CoreGraphics \
	-framework GraphicsServices \
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

GENERATED_GRAPHICS=MGRS.app/bg_normal.png MGRS.app/numeric_keyboard_normal.png \
	MGRS.app/numeric_keyboard_disabled.png \
	MGRS.app/numeric_keyboard_pressed.png \
	MGRS.app/alpha1_keyboard_normal.png \
	MGRS.app/alpha1_keyboard_disabled.png \
	MGRS.app/alpha1_keyboard_pressed.png \
	MGRS.app/alpha2_keyboard_normal.png \
	MGRS.app/alpha2_keyboard_disabled.png \
	MGRS.app/alpha2_keyboard_pressed.png

OBJ=MGRSapp.o

all: MGRS.app/MGRS $(GENERATED_GRAPHICS)

package:
	DPKG_DATADIR=`pwd`/dpkg.d dpkg-buildpackage -us -uc -rfakeroot -aiphoneos-arm -tiphoneos-arm

MGRS.app/MGRS: MGRS
	CODESIGN_ALLOCATE=$(SDK)$(BINPREF)codesign_allocate ldid -S MGRS && cp MGRS MGRS.app

MGRS.app/%.png: %.svg
	rsvg $< $@

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
	rm -f $(OBJ) MGRS MGRS.app/MGRS $(GENERATED_GRAPHICS)
	$(MAKE) -C mgrslib clean

MGRSapp.o: MGRSapp.m MGRSapp.h

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o: %.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
