SHELL:=/bin/bash
.DEFAULT_GOAL := all

.PHONY: all
all: background i3blocks/cpu

i3blocks/cpu: cpu/src/*.rs
	cd cpu && cargo build --release
	cp cpu/target/release/cpu i3blocks

%: src/cmd/%.go
	go build -o $@ ./$<