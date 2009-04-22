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

OBJ=MGRSapp.o

all: MGRS.app/MGRS

MGRS.app/MGRS: MGRS
	CODESIGN_ALLOCATE=$(SDK)$(BINPREF)codesign_allocate ldid -S MGRS && cp MGRS MGRS.app

MGRS: $(OBJ) mgrslib/libmgrs.a
	$(LD) $(LDFLAGS) -o $@ $(OBJ) -lmgrs

mgrslib/libmgrs.a:
	$(MAKE) -C mgrslib CC="$(CC)" LD="$(LD)" AR="$(AR)" CFLAGS="$(CFLAGS)"

clean:
	rm -f $(OBJ) MGRS
	$(MAKE) -C mgrslib clean

MGRSapp.o: MGRSapp.m MGRSapp.h

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o: %.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
