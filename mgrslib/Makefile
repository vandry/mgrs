OBJ=mgrs.o utm.o ups.o tranmerc.o polarst.o

all: libmgrs.a

libmgrs.a: $(OBJ)
	$(AR) cr $@ $(OBJ)

clean:
	rm -f $(OBJ) libmgrs.a
