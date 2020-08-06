MODULE_big = plschemeu
OBJS = plscheme.o
DATA = plschemeu--1.0.sql plschemeu-dataconv.scm plschemeu-init.scm
EXTENSION = plschemeu
REGRESS = plschemeu
EXTRA_CLEAN = exceptions.h
PGFILEDESC = "PL/schemeu - Scheme (Guile) language extension"
PG_CONFIG = pg_config
PG_CPPFLAGS = -DMODULE_DIR=\"$(shell $(PG_CONFIG) --sharedir)/extension/\"
SHLIB_LINK += -lguile-2.2

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# Automatically generate an exception type for each errcode in errcodes.txt
plscheme.o: exceptions.h
ERRCODES_TXT = $(shell $(PG_CONFIG) --sharedir)/errcodes.txt
exceptions.h: $(ERRCODES_TXT)
	awk '                                                             \
      BEGIN {                                                         \
        print "/* Automatically generated from $<.  Do not edit! */"; \
        num_exceptions = 0;                                           \
      }                                                               \
      /^[0-9]/ {                                                      \
        errcode = $$3;                                                \
        exception = $$4;                                              \
        gsub("_", "-", exception);                                    \
        printf("DEFINE_EXCP(\"%s\", %s);\n", exception, errcode);     \
        num_exceptions++;                                             \
      }                                                               \
      END {                                                           \
        printf("#define NUM_EXCEPTIONS %s\n", num_exceptions);        \
      }' < $< > $@
