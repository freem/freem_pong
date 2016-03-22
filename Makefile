# make the file
#==============================================================================#
CA65 = ca65
LD65 = ld65

# input file
INPUT = src/freempong.asm

# linker scripts
LINKSCRIPT_NES = src/link_nes.cfg
LINKSCRIPT_PCE = src/link_pce.cfg

# object files
OBJECT_NES = src/freempong_nes.o
OBJECT_PCE = src/freempong_pce.o
OBJECT_NES_DEBUG = src/freempong_nes_d.o
OBJECT_PCE_DEBUG = src/freempong_pce_d.o

# output files
OUTPUT_NES = bin/freempong.nes
OUTPUT_PCE = bin/freempong.pce
OUTPUT_NES_DEBUG = bin/freempong_d.nes
OUTPUT_PCE_DEBUG = bin/freempong_d.pce

# shared flags for ca65
CA65_FLAGS_SHARED = -I src
CA65_FLAGS_DEBUG = -D__DEBUGMODE__

# specific flags for ca65
CA65_FLAGS_NES = -t nes -o $(OBJECT_NES)
CA65_FLAGS_PCE = -t pce -o $(OBJECT_PCE)

CA65_FLAGS_NES_DEBUG = -t nes -o $(OBJECT_NES_DEBUG)
CA65_FLAGS_PCE_DEBUG = -t pce -o $(OBJECT_PCE_DEBUG)

# specific flags for ld65
LD65_FLAGS_NES = -C $(LINKSCRIPT_NES) -o $(OUTPUT_NES)
LD65_FLAGS_PCE = -C $(LINKSCRIPT_PCE) -o $(OUTPUT_PCE)

LD65_FLAGS_NES_DEBUG = -C $(LINKSCRIPT_NES) -o $(OUTPUT_NES_DEBUG)
LD65_FLAGS_PCE_DEBUG = -C $(LINKSCRIPT_PCE) -o $(OUTPUT_PCE_DEBUG)

#==============================================================================#
.phony: all release debug clean nes pce nes_debug pce_debug

release: nes pce

debug: nes_debug pce_debug

all: release debug

#==============================================================================#
clean:
	$(RM) $(OBJECT_NES) $(OBJECT_PCE) $(OBJECT_NES_DEBUG) $(OBJECT_PCE_DEBUG)
	$(RM) $(OUTPUT_NES) $(OUTPUT_PCE) $(OUTPUT_NES_DEBUG) $(OUTPUT_PCE_DEBUG)

#==============================================================================#
nes:
	$(CA65) $(CA65_FLAGS_SHARED) $(CA65_FLAGS_NES) $(INPUT)
	$(LD65) $(LD65_FLAGS_NES) $(OBJECT_NES)

#------------------------------------------------------------------------------#
nes_debug:
	$(CA65) $(CA65_FLAGS_SHARED) $(CA65_FLAGS_DEBUG) $(CA65_FLAGS_NES_DEBUG) $(INPUT)
	$(LD65) $(LD65_FLAGS_NES_DEBUG) $(OBJECT_NES_DEBUG)

#==============================================================================#
pce:
	$(CA65) $(CA65_FLAGS_SHARED) $(CA65_FLAGS_PCE) $(INPUT)
	$(LD65) $(LD65_FLAGS_PCE) $(OBJECT_PCE)

#------------------------------------------------------------------------------#
pce_debug:
	$(CA65) $(CA65_FLAGS_SHARED) $(CA65_FLAGS_DEBUG) $(CA65_FLAGS_PCE_DEBUG) $(INPUT)
	$(LD65) $(LD65_FLAGS_PCE_DEBUG) $(OBJECT_PCE_DEBUG)
