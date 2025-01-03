CC = g++
CFLAGS = -Wall -Wpedantic -Werror -std=c++11 $(shell pkg-config fuse3 --cflags) -I include/
LDFLAGS = -flto $(shell pkg-config fuse3 --libs) -l OpenCL

ifeq ($(DEBUG), 1)
	CFLAGS += -g -DDEBUG -Wall -Werror -std=c++11
else
	CFLAGS += -march=native -O2 -flto
endif

bin/vramfs: build/util.o build/memory.o build/entry.o build/file.o build/dir.o build/symlink.o build/vramfs.o | bin
	$(CC) -o $@ $^ $(LDFLAGS)

build bin:
	@mkdir -p $@

build/%.o: src/%.cpp | build
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -rf build/ bin/

.PHONY: install
install: bin/vramfs
	install -d $(DEST)/usr/local/bin/
	install bin/vramfs $(DEST)/usr/local/bin/
	install fuse3.vramfs $(DEST)/usr/local/bin/

.PHONY: uninstall
uninstall:
	$(RM) $(DEST)/usr/local/bin/fuse3.vramfs
	$(RM) $(DEST)/usr/local/bin/vramfs