SDK=/opt/iphonedev
CC=$(SDK)/bin/arm-apple-darwin9-gcc
LD=$(CC)
AR=$(SDK)/bin/arm-apple-darwin9-ar
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

all: MGRS

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
