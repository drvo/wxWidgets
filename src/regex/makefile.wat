#!/binb/wmake.exe
#
# File:		makefile.wat
# Author:	Julian Smart
# Created:	1998
#
# Makefile : Builds REGEX library for Watcom C++, WIN32

WXDIR = ..\..
EXTRACPPFLAGS=-DPOSIX_MISTAKE

!include $(WXDIR)\src\makewat.env

WXLIB = $(WXDIR)\lib

LIBTARGET   = $(WXLIB)\regex.lib

OBJECTS= &
		regcomp.o &
		regexec.o &
		regerror.o &
		regfree.o

all:        $(OBJECTS) $(LIBTARGET)

$(LIBTARGET) : $(OBJECTS)
    %create tmp.lbc
    @for %i in ( $(OBJECTS) ) do @%append tmp.lbc +%i
    wlib /b /c /n /p=512 $^@ @tmp.lbc

clean:
    -erase *.obj
    -erase $(LIBTARGET)
    -erase *.pch
    -erase *.err
    -erase *.lbc

cleanall:   clean

