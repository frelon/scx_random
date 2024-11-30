BPFTOOL     ?= /usr/sbin/bpftool
LIBBPF      ?= /usr/lib64/libbpf.so.1
CC_ARGS     ?= -g -O2 -Wall -Wno-compare-distinct-pointer-types
BPF_CC_ARGS ?= -g -O2 -Wall -Wno-compare-distinct-pointer-types -D__TARGET_ARCH_x86_64 -mcpu=v3 -I ./
CC           = clang

.PHONY: all
all: scx_random 

scx_random: scx_random.bpf.skel.h
	$(CC) $(CC_ARGS) -o scx_random scx_random.c $(LIBBPF)

scx_random.bpf.skel.h: scx_random.bpf.o
	./bpftool_build_skel $(BPFTOOL) scx_random.bpf.o scx_random.bpf.skel.h scx_random.bpf.subskel.h

scx_random.bpf.o: vmlinux.h
	$(CC) $(BPF_CC_ARGS) -target bpf -c scx_random.bpf.c -o scx_random.bpf.o

vmlinux.h:
	$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

.PHONY: clean
clean:
	rm -f scx_random
	rm -f scx_random.bpf.skel.h
	rm -f scx_random.bpf.subskel.h
	rm -f scx_random.bpf.l1o
	rm -f scx_random.bpf.l2o
	rm -f scx_random.bpf.l3o
	rm -f scx_random.bpf.o
