.PHONY: zip clean

zip: db.lua
	docker run --rm -it -v "$$PWD:/addon" -u `id -u`:`id -g` ghcr.io/ferronn-dev/addonmaker

clean:
	rm -f OlliverrsTravels.* *.tmp *.out db.lua

db.lua: db.py
	python3 db.py > db.lua

test.out: zip
	bash -c "set -o pipefail && lua test.lua 2>&1 | tee test.tmp"
	mv test.tmp test.out
