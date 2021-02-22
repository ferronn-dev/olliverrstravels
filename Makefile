.PHONY: zip clean

zip:
	docker run --rm -it -v "$$PWD:/addon" -u `id -u`:`id -g` ghcr.io/ferronn-dev/addonmaker

clean:
	rm -f OlliverrsTravels.* db.lua
