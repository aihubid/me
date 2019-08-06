

HEADERS_SEARCH_FLAGS ?= -I/usr/include


all:
	g++ ${HEADERS_SEARCH_FLAGS} -lusb-1.0 cp2130ex.cc -o libusb_example

clean:
	rm -rf libusb_example

