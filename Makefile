LUAS:=$(shell python3 build.py files)

.PHONY: all clean

all: test.out
clean:
	rm -f olliverrstravels.toc *.tmp *.out db.lua

olliverrstravels.toc: build.yaml build.py
	python3 build.py toc > olliverrstravels.toc

db.lua: db.py
	python3 db.py > db.lua

test.out: test.lua olliverrstravels.toc $(LUAS)
	bash -c "set -o pipefail && lua test.lua 2>&1 | tee test.tmp"
	mv test.tmp test.out
