NAME = in_the_shadows


GODOT = Godot_v4.7.2-stable_linux.x86_64
BLENDER = blender-5.2.1-linux-x64

all: deps
	@echo 'run if you want'
	@echo 'alias godot=$(CURDIR)/deps/godot'
	@echo 'alias blender=$(CURDIR)/deps/blender'

deps : deps/$(GODOT) deps/$(BLENDER)

deps/$(GODOT) :
	mkdir -p deps && cd deps \
	&& wget https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/$(GODOT).zip \
	&& unzip $(GODOT).zip \
	&& rm $(GODOT).zip \
	&& ln -sf $(GODOT) godot

deps/$(BLENDER) :
	mkdir -p deps && cd deps \
	&& wget https://ftp.nluug.nl/graphics/blender/release/Blender5.2/$(BLENDER).tar.xz \
	&& tar -xf $(BLENDER).tar.xz \
	&& rm $(BLENDER).tar.xz \
	&& ln -sf $(BLENDER)/blender blender

clean:


fclean: clean
	-rm -r deps

re: fclean all

.PHONY: deps clean all fclean