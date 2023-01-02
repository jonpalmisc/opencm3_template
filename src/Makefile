PROJECT		= template

DEVICE		= stm32f411ret6u
OOCD_FILE	= board/st_nucleo_f4.cfg

CFILES		= main.c

# ===------------------------------------------------------------------------===

OPENCM3_DIR	?= ../vendor/libopencm3

include $(OPENCM3_DIR)/mk/genlink-config.mk
include ../mk/base.mk
include $(OPENCM3_DIR)/mk/genlink-rules.mk
