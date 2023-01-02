# ===-- Meta ----------------------------------------------------------------===

.SUFFIXES:
.SUFFIXES: .c .S .h .o .cxx .elf .bin .list .lss

V	?=0
ifeq ($(V),0)
Q	:= @
NULL	:= 2>/dev/null
endif

# ===-- Toolchain -----------------------------------------------------------===

PREFIX		?= arm-none-eabi-
CC		= $(PREFIX)gcc
CXX		= $(PREFIX)g++
LD		= $(PREFIX)gcc
OBJCOPY		= $(PREFIX)objcopy
OBJDUMP		= $(PREFIX)objdump
OOCD		?= openocd

INCLUDES	+= $(patsubst %,-I%, . $(OPENCM3_DIR)/include)

# ===-- Flags ---------------------------------------------------------------===

OPT		?= -Os

APP_CFLAGS	+= $(OPT) -std=c99 -ggdb3 $(ARCH_FLAGS)
APP_CFLAGS	+= -fno-common -ffunction-sections -fdata-sections
APP_CFLAGS	+= -Wextra -Wshadow -Wno-unused-variable \
			-Wimplicit-function-declaration -Wredundant-decls \
			-Wstrict-prototypes -Wmissing-prototypes

APP_ASFLAGS	+= $(OPT) $(ARCH_FLAGS) -ggdb3

APP_LDFLAGS	+= -T$(LDSCRIPT) -L$(OPENCM3_DIR)/lib -nostartfiles \
			$(ARCH_FLAGS) -specs=nano.specs -Wl,--gc-sections

LDLIBS		+= -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group

# ===-- Sources -------------------------------------------------------------===

OUT		?= ../bin

OBJS		= $(CFILES:%.c=$(OUT)/%.o)
OBJS		+= $(CXXFILES:%.cxx=$(OUT)/%.o)
OBJS		+= $(AFILES:%.S=$(OUT)/%.o)

GENERATED_BINS	= $(OUT)/$(PROJECT).elf $(OUT)/$(PROJECT).bin $(LDSCRIPT)

# ===-- Patterns ------------------------------------------------------------===

.PHONY: all
all:  $(OUT)/$(PROJECT).elf  $(OUT)/$(PROJECT).bin

$(OUT)/%.o: %.c
	@printf "  CC\t  $<\n"
	@mkdir -p $(dir $@)
	$(Q)$(CC) $(APP_CFLAGS) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

$(OUT)/%.o: %.S
	@printf "  AS\t  $<\n"
	@mkdir -p $(dir $@)
	$(Q)$(CC) $(APP_ASFLAGS) $(ASFLAGS) $(CPPFLAGS) -o $@ -c $<

$(OUT)/$(PROJECT).elf: $(OBJS) $(LDSCRIPT) $(LIBDEPS)
	@printf "  LD\t  $@\n"
	$(Q)$(LD) $(APP_LDFLAGS) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $@

$(OUT)/%.bin: $(OUT)/%.elf
	@printf "  COPY\t  $@\n"
	$(Q)$(OBJCOPY) -O binary  $< $@

%.flash: $(OUT)/%.elf
	@printf "  FLASH\t$<\n"
	$(Q)(echo "halt; program $(realpath $<) verify reset" | nc -4 localhost 4444 2>/dev/null) || \
		$(OOCD) -f $(OOCD_FILE) -c "program $(realpath $<) verify reset exit" $(NULL)

-include $(OBJS:.o=.d)

# ===-- Auxiliary -----------------------------------------------------------===

.PHONY: clean
clean:
	@rm -rf $(OUT) $(GENERATED_BINS)

.PHONY: flash
flash: $(PROJECT).flash
