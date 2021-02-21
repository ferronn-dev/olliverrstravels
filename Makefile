.PHONY: zip clean

zip: db.lua
	docker run --rm -it -v "$$PWD:/addon" -u `id -u`:`id -g` ghcr.io/ferronn-dev/addonmaker

clean:
	rm -f OlliverrsTravels.* db.lua

db.lua: db.py
	python3 db.py > db.lua
