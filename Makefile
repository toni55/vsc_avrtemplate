
TARGET   = testprojekt
MCU      = atmega328p
PROGR    = avrispmkii
F_CPU    = 16000000

# Debugging format.
#     Native formats for AVR-GCC's -g are dwarf-2 [default] or stabs.
#     AVR Studio 4.10 requires dwarf-2.
#     AVR [Extended] COFF format requires stabs, plus an avr-objcopy run.
DEBUG = dwarf-2

# List any extra directories to look for include files here.
#     Each directory must be seperated by a space.
#     Use forward slashes for directory separators.
#     For a directory that has spaces, enclose it in quotes.
EXTRAINCDIRS =

CC       = avr-gcc
OBJCOPY  = avr-objcopy
AVRDUDE  = avrdude
SIZE 	 = avr-size

CFLAGS = -g$(DEBUG)
CFLAGS += -DF_CPU=$(F_CPU)UL
CFLAGS += -Wall -Werror -Os -std=c99
CFLAGS += -funsigned-char
CFLAGS += -funsigned-bitfields
CFLAGS += -fpack-struct
CFLAGS += -fshort-enums
CFLAGS += -Wstrict-prototypes
# CFLAGS += -mshort-calls
# CFLAGS += -fno-unit-at-a-time
# CFLAGS += -Wundef
# CFLAGS += -Wunreachable-code
# CFLAGS += -Wsign-compare
CFLAGS += -Wa,-adhlns=$(<:%.c=$(OBJDIR)/%.lst)
CFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))

PFLAGS   = -B1

SRCDIR   = .
OBJDIR   = obj
BINDIR   = bin

SOURCES  := $(wildcard $(SRCDIR)/*.c)
HEADERS  := $(wildcard $(SRCDIR)/*.h)
OBJECTS  := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

complete: clean all program

all: $(BINDIR)/$(TARGET).hex

$(BINDIR)/$(TARGET).elf: $(OBJECTS) | $(BINDIR)
	$(CC) -mmcu=$(MCU) $(CFLAGS) -o $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS) | $(OBJDIR)
	$(CC) -c -mmcu=$(MCU) $(CFLAGS) -o $@ $<

$(OBJDIR):
	@mkdir $(OBJDIR)

$(BINDIR):
	@mkdir $(BINDIR)

$(BINDIR)/%.hex: $(BINDIR)/%.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
	@echo.
	@echo $(MCU)
	@echo ==================================================================
	@$(SIZE) --target=elf32-avr $(BINDIR)/$(TARGET).elf
	@echo ==================================================================
	@echo.

program: $(BINDIR)/$(TARGET).hex
	$(AVRDUDE) -c $(PROGR) -P usb -p $(MCU) $(PFLAGS) -U flash:w:$<

clean:
ifeq ($(OS),Windows_NT)
	@rmdir /s /q $(OBJDIR)
	@rmdir /s /q $(BINDIR)
else
	@rm -f $(OBJDIR)/*.*
	@rm -f $(BINDIR)/*.*
	@rm -rf $(OBJDIR)
	@rm -rf $(BINDIR)
endif


# Create object files directory
#$(shell mkdir $(OBJDIR) 2>/dev/null)


# Include the dependency files.
#-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)


# Listing of phony targets.
.PHONY : all build clean program
