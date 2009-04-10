SDK=/opt/iphonedev
CC=$(SDK)/bin/arm-apple-darwin9-gcc
LD=$(CC)
AR=$(SDK)/bin/arm-apple-darwin9-ar
LDFLAGS=-Lmgrslib
CFLAGS=-march=armv6 -mcpu=arm1176jzf-s -g

OBJ=try.o

all: try

try: $(OBJ) mgrslib/libmgrs.a
	$(LD) $(LDFLAGS) -o $@ $(OBJ) -lmgrs

mgrslib/libmgrs.a:
	$(MAKE) -C mgrslib CC="$(CC)" LD="$(LD)" AR="$(AR)" CFLAGS="$(CFLAGS)"

clean:
	rm -f $(OBJ) try
	$(MAKE) -C mgrslib clean
