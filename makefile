CC 					= gcc
CFLAGS 		  = -Wall -Werror -O3 -I./include
BUILDDIR 		= ./build
SRCDIR 	 		= ./src
INCDIR	 		= ./include
TARGET_NAME = string8
TARGET 	 		= $(BUILDDIR)/lib$(TARGET_NAME).a

# Find source files and define corresponding object files
SRCS = $(wildcard $(SRCDIR)/*.c)
OBJS = $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(SRCS))

COMMIT =?

PREFIX 	?= /usr/local
LIBDIR	= $(PREFIX)/lib
INCLDIR	= $(PREFIX)/include

.PHONY: all clean install uninstall commit push

all: $(TARGET)

# Rule to create the static library from object files
$(TARGET): $(OBJS) | $(BUILDDIR)
	ar rcs $@ $^

# Rule to compile object files
$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	mkdir -p $@

install: $(TARGET)
	install -d $(LIBDIR)
	install -m 644 $(TARGET) $(LIBDIR)
	install -d $(INCLDIR)/$(TARGET_NAME)
	install -m 644 $(INCDIR)/*.h $(INCLDIR)/$(TARGET_NAME)/

uninstall:
	rm -f $(LIBDIR)/$(notdir $(TARGET))
	rm -rf $(INCLDIR)/$(TARGET_NAME)

commit:
	git add .
	git commit -m "$(COMMIT)"

push: commit
	git push origin main

clean:
	rm -rf $(BUILDDIR)
