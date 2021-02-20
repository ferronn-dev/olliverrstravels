LUAS:=$(shell python3 build.py files)

.PHONY: zip clean

zip: OlliverrsTravels.zip

clean:
	rm -f OlliverrsTravels.* *.tmp *.out db.lua

OlliverrsTravels.zip: test.out OlliverrsTravels.toc $(LUAS)
	python3 build.py zip

OlliverrsTravels.toc: build.yaml build.py
	python3 build.py toc > OlliverrsTravels.toc

db.lua: db.py
	python3 db.py > db.lua

test.out: test.lua OlliverrsTravels.toc $(LUAS)
	bash -c "set -o pipefail && lua test.lua 2>&1 | tee test.tmp"
	mv test.tmp test.out
