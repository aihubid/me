
AN792SW - CP2130 LibUSB Sample v1.0 Release Notes
Copyright (C) 2017 Silicon Laboratories, Inc.

This release contains the following components:

        * cp2130ex.cc
        * ReleaseNotes.TXT (this file)

KNOWN ISSUES AND LIMITATIONS
----------------------------

	1.) Only CP2130 devices are supported by this sample source. 

Dependencies
------------

1. libusb-1.0

Homebrew:

  $ brew install libusb
  
MacPorts:
  
  $ sudo port install libusb

How to build libusb_example
---------------------------

  $ make

if your header file is not found you can use the following:

  $ HEADERS_SEARCH_FLAGS=-I<location of libusb-1.0 folder> bash -c "make"

Usage
-----
     Refer to AN792 for an explanation of the source usage.

Release Dates
-------------

	AN792SW - CP2130 LibUSB Sample v1.0 - July 16, 2014

REVISION HISTORY
-----------------

version 1.0
	Initial Release

