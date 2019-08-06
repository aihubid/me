//
//  LibraryBridge.h
//  HidUartExample
//
//  Created by Brant Merryman on 1/24/17.
//
//

#ifndef LibraryBridge_h
#define LibraryBridge_h

#include <stdio.h>

typedef enum {
   ok = 0
  ,some_error = -1
  ,timed_out = -2

} LibraryBridgeStatus;

const char * GetHidUartStatusStr(int status);

LibraryBridgeStatus GetHIDDeviceLibraryVersion(int * inmajor, int * inminor, int * inrelease);
LibraryBridgeStatus GetHidUartLibraryVersion(int * inmajor, int * inminor, int * inrelease);

LibraryBridgeStatus HidUartIsOpened(void * device, int * outOpened);

LibraryBridgeStatus HidUartWriteLatch(void * device, unsigned short inlatchValue, unsigned short inlatchMask);

LibraryBridgeStatus HidUartReadLatch(void * device, unsigned short * latchValue);

LibraryBridgeStatus HidUartWrite(void * device, unsigned char * buffer, unsigned int numBytesToWrite, unsigned long * numBytesWritten);

LibraryBridgeStatus HidUartClose(void * device);

LibraryBridgeStatus HidUartGetNumDevices(int * numDevices, unsigned short vid, unsigned short pid);

LibraryBridgeStatus HidUartGetString(int deviceNum, int vid, int pid, char* deviceString, int options);

LibraryBridgeStatus HidUartOpen(void ** device, int deviceNum, int vid, int pid);

LibraryBridgeStatus HidUartGetPartNumber(void * device, int * partNumber, int * version);

LibraryBridgeStatus HidUartSetUartConfig(void * device, int baudRate, int dataBits, int parity, int stopBits, int flowControl);

LibraryBridgeStatus HidUartGetUartConfig(void * device, int * baudRate, int * dataBits, int * parity, int * stopBits, int * flowControl);

LibraryBridgeStatus HidUartSetTimeouts(void * device, int readTimeout, int writeTimeout);

LibraryBridgeStatus HidUartGetOpenedString(void * device, char* deviceString, int options);

LibraryBridgeStatus HidUartSetPinConfig(void * device, unsigned char* pinConfig, int useSuspendValues, unsigned short suspendValue, unsigned short suspendMode, unsigned char rs485Level, unsigned char clkDiv);

LibraryBridgeStatus HidUartGetPinConfig(void * device, unsigned char * pinConfig, int * useSuspendValues, unsigned short * suspendValue, unsigned short* suspendMode, unsigned char * rs485Level, unsigned char * clkDiv);

LibraryBridgeStatus HidUartRead(void * device, unsigned char* buffer, long numBytesToRead, unsigned long* numBytesRead);

LibraryBridgeStatus CP2114GetPinConfig(void * device, unsigned char* pinConfig, int * useSuspendValues, unsigned short* suspendValue, unsigned short* suspendMode, unsigned char * clkDiv);


#endif /* LibraryBridge_h */

