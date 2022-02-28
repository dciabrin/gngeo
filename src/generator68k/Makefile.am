## Process this file with automake to produce Makefile.in

noinst_PROGRAMS = def68k$(EXEEXT) gen68k$(EXEEXT)

## stage one - create iibs, funcs and proto header files from def68k.def

AM_CPPFLAGS = -I../ -I.

gcc_build_verbose = $(gcc_build_verbose_$(V))
gcc_build_verbose_ = $(gcc_build_verbose_$(AM_DEFAULT_VERBOSITY))
gcc_build_verbose_0 = @echo "  HCC    $@";

def68k_SOURCES = def68k.c tab68k2.c

def68k.stamp: def68k$(EXEEXT) def68k.def
	$(AM_V_GEN)./def68k$(EXEEXT) 2>&1 >/dev/null && touch def68k.stamp

def68k-proto.h def68k-funcs.h def68k-iibs.h : def68k.stamp

cpu68k.c gen68k.c : def68k-proto.h def68k-funcs.h def68k-iibs.h

## stage two - create cpu C files and create library

gen68k_SOURCES = gen68k.c tab68k2.c
gen68k_DEPENDENCIES = def68k-iibs.h def68k-proto.h def68k-funcs.h def68k

noinst_LIBRARIES = libgenerator68k.a
libgenerator68k_a_SOURCES = cpu68k.c reg68k.c registers.h diss68k.c \
                            mem68k.h generator.h cpu68k.h compile.h \
                            tab68k.c cpu68k-inline.h reg68k.h

libgenerator68k_a_LIBADD = cpu68k-0.o cpu68k-1.o cpu68k-2.o cpu68k-3.o \
                          cpu68k-4.o cpu68k-5.o cpu68k-6.o cpu68k-7.o \
                          cpu68k-8.o cpu68k-9.o cpu68k-a.o cpu68k-b.o \
                          cpu68k-c.o cpu68k-d.o cpu68k-e.o cpu68k-f.o #compile.o


libgenerator68k_a_DEPENDENCIES = cpu68k-0.o cpu68k-1.o cpu68k-2.o cpu68k-3.o \
                          cpu68k-4.o cpu68k-5.o cpu68k-6.o cpu68k-7.o \
                          cpu68k-8.o cpu68k-9.o cpu68k-a.o cpu68k-b.o \
                          cpu68k-c.o cpu68k-d.o cpu68k-e.o cpu68k-f.o \
                          def68k-iibs.h #compile.o

EXTRA_DIST = def68k.def compile.cg ccg/alpha ccg/asm-i386.h ccg/asm-sparc.h \
             ccg/asm-ppc.h ccg/asm-cache.h ccg/asm-common.h ccg/ccg.c \
             ccg/insns-i386.h ccg/insns-ppc.h ccg/insns-sparc.h

MOSTLYCLEANFILES = ${BUILT_SOURCES}
CLEANFILES = def68k.stamp gen68k.stamp

def68k.o gen68k.o tab68k2.o : %.o : %.c
	$(gcc_build_verbose)$(CC_FOR_BUILD) -c $< -o $@ -I .. -I ../.. -I . `sdl2-config --cflags` -Umain -Dmain=main

def68k$(EXEEXT) : def68k.o tab68k2.o
	$(gcc_build_verbose)$(CC_FOR_BUILD) def68k.o tab68k2.o -o $@

gen68k$(EXEEXT) : gen68k.o tab68k2.o
	$(gcc_build_verbose)$(CC_FOR_BUILD) gen68k.o tab68k2.o -o $@

CPU_SOURCE = cpu68k-0.c  cpu68k-1.c  cpu68k-2.c  cpu68k-3.c  \
	     cpu68k-4.c  cpu68k-5.c  cpu68k-6.c  cpu68k-7.c  \
	     cpu68k-8.c  cpu68k-9.c  cpu68k-a.c  cpu68k-b.c  \
	     cpu68k-c.c  cpu68k-d.c  cpu68k-e.c  cpu68k-f.c

CPU_OBJ    = cpu68k-0.o  cpu68k-1.o  cpu68k-2.o  cpu68k-3.o  \
	     cpu68k-4.o  cpu68k-5.o  cpu68k-6.o  cpu68k-7.o  \
	     cpu68k-8.o  cpu68k-9.o  cpu68k-a.o  cpu68k-b.o  \
	     cpu68k-c.o  cpu68k-d.o  cpu68k-e.o  cpu68k-f.o

gen68k.stamp : gen68k$(EXEEXT)
	$(AM_V_GEN)./gen68k$(EXEEXT) 2>&1 >/dev/null &&	touch gen68k.stamp

# use a stamp file so gen68k isnt invoked repeatedly for every file
$(CPU_SOURCE) : gen68k.stamp

$(CPU_OBJ) : %.o : %.c
	$(AM_V_CC)$(COMPILE) -c $< -o $@

