.PHONY : all clear movereplay

all: clear build movereplay movereplay

build:
	./halite -d "240 160" "ruby JackBot.rb" "ruby Enemy.rb"

movereplay:
	-mv replay-* replays/

clear:
	-rm replays/*
