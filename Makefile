NAME = in_the_shadows

GODOT = Godot_v4.7.2-stable_linux.x86_64

all: deps
	@echo 
	@echo 'run: alias godot=./deps/godot'

deps : deps/$(GODOT)

deps/$(GODOT) :
	mkdir -p deps && cd deps \
	&& wget https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/$(GODOT).zip \
	&& unzip $(GODOT).zip \
	&& rm $(GODOT).zip \
	&& ln -sf $(GODOT) godot

clean:


fclean: clean
	-rm -r deps

re: fclean all

.PHONY: deps clean all fclean