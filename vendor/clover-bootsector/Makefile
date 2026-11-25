NASM ?= nasm
OUT ?= build
SRC := .

.PHONY: all clean
all: $(OUT)/boot0af $(OUT)/boot0ss $(OUT)/boot1f32 $(OUT)/boot1f32alt

$(OUT):
	mkdir -p $(OUT)

$(OUT)/boot0af: boot0.s boot0af.s | $(OUT)
	$(NASM) -f bin boot0af.s -o $@

$(OUT)/boot0ss: boot0.s boot0ss.s | $(OUT)
	$(NASM) -f bin boot0ss.s -o $@

$(OUT)/boot1f32: boot1f32.s | $(OUT)
	$(NASM) -f bin boot1f32.s -o $@

$(OUT)/boot1f32alt: boot1f32alt.s | $(OUT)
	$(NASM) -f bin boot1f32alt.s -o $@

clean:
	rm -rf $(OUT)
