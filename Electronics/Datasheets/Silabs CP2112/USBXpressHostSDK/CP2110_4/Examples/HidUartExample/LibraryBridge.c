//
//  LibraryBridge.c
//  HidUartExample
//
//  Created by Brant Merryman on 1/24/17.
//
//

#include "LibraryBridge.h"

#import "SLABHIDDevice.h"
#import "SLABHIDtoUART.h"

#import "SLABCP2110.h"
#import "SLABCP2114.h"


const char * GetHidUartStatusStr(int status)
{
  switch (status)
  {
    case HID_UART_SUCCESS:
      return "HID_UART_SUCCESS";


    case HID_UART_DEVICE_NOT_FOUND:
      return "HID_UART_DEVICE_NOT_FOUND";


    case HID_UART_INVALID_HANDLE:
      return "HID_UART_INVALID_HANDLE";


    case HID_UART_INVALID_DEVICE_OBJECT:
      return "HID_UART_INVALID_DEVICE_OBJECT";


    case HID_UART_INVALID_PARAMETER:
      return "HID_UART_INVALID_PARAMETER";


    case HID_UART_INVALID_REQUEST_LENGTH:
      return "HID_UART_INVALID_REQUEST_LENGTH";


    case HID_UART_READ_ERROR:
      return "HID_UART_READ_ERROR";


    case HID_UART_WRITE_ERROR:
      return "HID_UART_WRITE_ERROR";


    case HID_UART_READ_TIMED_OUT:
      return "HID_UART_READ_TIMED_OUT";


    case HID_UART_WRITE_TIMED_OUT:
      return "HID_UART_WRITE_TIMED_OUT";


    case HID_UART_DEVICE_IO_FAILED:
      return "HID_UART_DEVICE_IO_FAILED";


    case HID_UART_DEVICE_ACCESS_ERROR:
      return "HID_UART_DEVICE_ACCESS_ERROR";


    case HID_UART_DEVICE_NOT_SUPPORTED:
      return "HID_UART_DEVICE_NOT_SUPPORTED";


    case HID_UART_UNKNOWN_ERROR:
      return "HID_UART_UNKNOWN_ERROR";

  }
  
  return "Unknown HID UART status";
}

LibraryBridgeStatus GetHIDDeviceLibraryVersion(int * inmajor, int * inminor, int * inrelease)
{

  BYTE major, minor;
  BOOL rc;
  BOOL release;

  rc = HidDevice_GetHidLibraryVersion(&major, &minor, &release);

  if (HID_DEVICE_SUCCESS == rc) {
    *inmajor    = (int) major;
    *inminor    = (int)minor;
    *inrelease  = release ? 1 : 0;

    return ok;
  }

  return some_error;
}

LibraryBridgeStatus GetHidUartLibraryVersion(int * inmajor, int * inminor, int * inrelease)
{
  HID_UART_STATUS rc;
  BYTE major, minor;
  BOOL release;

  rc = HidUart_GetLibraryVersion(&major, &minor, &release);

  if (HID_DEVICE_SUCCESS == rc) {
    *inmajor    = (int) major;
    *inminor    = (int)minor;
    *inrelease  = release ? 1 : 0;

    return ok;
  }

  return some_error;
}

LibraryBridgeStatus HidUartIsOpened(void * device, int * outOpened)
{
  BOOL opened;
  HID_UART_STATUS status = HidUart_IsOpened( (HID_UART_DEVICE) device, &opened);

  if ( HID_UART_SUCCESS == status ) {
    if (opened) {
      *outOpened = 1;
    } else {
      *outOpened = 0;
    }
    return ok;
  }
  return some_error;
}

LibraryBridgeStatus HidUartWriteLatch(void * device, unsigned short inlatchValue, unsigned short inlatchMask)
{
  WORD latchValue = inlatchValue;
  WORD latchMask = inlatchMask;

  HID_UART_STATUS status = HidUart_WriteLatch( (HID_UART_DEVICE) device, latchValue, latchMask);

  if (HID_UART_SUCCESS == status) {
    return ok;
  } else {
    return some_error;
  }
}

LibraryBridgeStatus HidUartWrite(void * device, unsigned char * buffer, unsigned int numBytesToWrite, unsigned long * numBytesWritten)
{
  HID_UART_STATUS status = HidUart_Write( (HID_UART_DEVICE) device, buffer, numBytesToWrite, numBytesWritten);
  if (HID_UART_SUCCESS == status) {
    return ok;
  } else {
    return some_error;
  }
}

LibraryBridgeStatus HidUartClose(void * device)
{

  HID_UART_STATUS status = HidUart_Close( (HID_UART_DEVICE) device);
  if (HID_UART_SUCCESS == status) {
    return ok;
  } else {
    return some_error;
  }

}

LibraryBridgeStatus HidUartReadLatch(void * device, unsigned short * latchValue)
{
  HID_UART_STATUS status = HidUart_ReadLatch( (HID_UART_DEVICE) device, latchValue);
  if (HID_UART_SUCCESS == status) {
    return ok;
  } else {
    return some_error;
  }
}


LibraryBridgeStatus HidUartGetNumDevices(int * numDevices, unsigned short vid, unsigned short pid)
{
  HID_UART_STATUS status = HidUart_GetNumDevices((DWORD *)numDevices, vid, pid);
  if ( HID_UART_SUCCESS == status ) {
    return ok;
  } else {
    return some_error;
  }
}

LibraryBridgeStatus HidUartGetString(int deviceNum, int vid, int pid, char* deviceString, int options)
{
  if (HID_UART_SUCCESS == HidUart_GetString(deviceNum,  vid, pid, deviceString, options)) {
    return ok;
  }
  return some_error;
}

LibraryBridgeStatus HidUartOpen(void ** device, int deviceNum, int vid, int pid)
{
  if (HID_UART_SUCCESS == HidUart_Open((HID_UART_DEVICE*) device,  deviceNum,  vid,  pid)) {
    return ok;
  }
  return some_error;
}

LibraryBridgeStatus HidUartGetPartNumber(void * device, int * partNumber, int * version)
{
  BYTE myPartNumber;
  BYTE myVersion;

  if (HID_UART_SUCCESS ==  HidUart_GetPartNumber((HID_UART_DEVICE) device, &myPartNumber, &myVersion)) {
    partNumber = myPartNumber;
    version = myVersion;
    return ok;
  }
  return some_error;
}

LibraryBridgeStatus HidUartSetUartConfig(void * device, int baudRate, int dataBits, int parity, int stopBits, int flowControl)
{
  BYTE myBaudRate, myDataBits, myParity, myStopBits, myFlowControl;

  myBaudRate = baudRate;
  myDataBits = dataBits;
  myParity = parity;
  myStopBits = stopBits;
  myFlowControl = flowControl;

  if (HID_UART_SUCCESS ==  HidUart_SetUartConfig( (HID_UART_DEVICE) device, myBaudRate, myDataBits, myParity, myStopBits, myFlowControl)) {

    return ok;
  }
  return some_error;
}

LibraryBridgeStatus HidUartGetUartConfig(void * device, int * baudRate, int * dataBits, int * parity, int * stopBits, int * flowControl)
{
  BYTE myDataBits, myParity, myStopBits, myFlowControl;
  DWORD myBaudRate;

  if (HID_UART_SUCCESS == HidUart_GetUartConfig((HID_UART_DEVICE) device, &myBaudRate, &myDataBits, &myParity, &myStopBits, &myFlowControl)) {

    *baudRate = myBaudRate;
    *dataBits = myDataBits;
    *parity = myParity;
    *stopBits = myStopBits;
    *flowControl = myFlowControl;

    return ok;
  }
  return some_error;
}


LibraryBridgeStatus HidUartSetTimeouts(void * device, int readTimeout, int writeTimeout)
{
  if (HID_UART_SUCCESS == HidUart_SetTimeouts( (HID_UART_DEVICE) device, readTimeout, writeTimeout)) {

    return ok;
  }

  return some_error;
}

LibraryBridgeStatus HidUartGetOpenedString(void * device, char* deviceString, int options)
{
  if (HID_UART_SUCCESS == HidUart_GetOpenedString( (HID_UART_DEVICE) device, deviceString, options)) {
    return ok;
  }
  return some_error;
}


LibraryBridgeStatus HidUartSetPinConfig(void * device, unsigned char* pinConfig, int useSuspendValues, unsigned short suspendValue, unsigned short suspendMode, unsigned char rs485Level, unsigned char clkDiv)
{

  if (HID_UART_SUCCESS == HidUart_SetPinConfig( (HID_UART_DEVICE) device, pinConfig, useSuspendValues, suspendValue, suspendMode, rs485Level, clkDiv)) {
    return ok;
  }
  return some_error;
}

  // HidUart_GetPinConfig
LibraryBridgeStatus HidUartGetPinConfig(void * device, unsigned char * pinConfig, int * useSuspendValues, unsigned short * suspendValue, unsigned short* suspendMode, unsigned char * rs485Level, unsigned char * clkDiv)
{
  BOOL myUseSuspendValues;
  if (HID_UART_SUCCESS == HidUart_GetPinConfig( (HID_UART_DEVICE) device, pinConfig, &myUseSuspendValues, suspendValue, suspendMode, rs485Level, clkDiv)) {
    if (myUseSuspendValues) {
      useSuspendValues = 1;
    } else {
      useSuspendValues = 0;
    }
    return ok;
  }
  return some_error;
}

LibraryBridgeStatus HidUartRead(void * device, unsigned char* buffer, long numBytesToRead, unsigned long* numBytesRead)
{
  HID_UART_STATUS status = HidUart_Read( (HID_UART_DEVICE) device, buffer, numBytesToRead, numBytesRead);
  if (HID_UART_SUCCESS == status) {
    return ok;
  } else if (HID_UART_READ_TIMED_OUT) {
    return timed_out;
  }
  
  return some_error;
}

LibraryBridgeStatus CP2114GetPinConfig(void * device, unsigned char* pinConfig, int * useSuspendValues, unsigned short* suspendValue, unsigned short* suspendMode, unsigned char * clkDiv)
{
  BOOL myUseSuspendValues;
  if (HID_UART_SUCCESS == CP2114_GetPinConfig( (HID_UART_DEVICE) device, pinConfig, &myUseSuspendValues, suspendValue, suspendMode, clkDiv)) {

    if (myUseSuspendValues) {
      *useSuspendValues = 1;
    } else {
      *useSuspendValues = 0;
    }

    return ok;
  }
  return some_error;
}

