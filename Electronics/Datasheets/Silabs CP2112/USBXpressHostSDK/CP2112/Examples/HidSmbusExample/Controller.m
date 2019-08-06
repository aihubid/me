////////////////////////////////////////////////////////////////////////////////
// Controller.m
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

#import "Controller.h"
#import "Utilities.h"
#include <limits.h>

////////////////////////////////////////////////////////////////////////////////
// Controller Class
////////////////////////////////////////////////////////////////////////////////

@implementation Controller

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Action
////////////////////////////////////////////////////////////////////////////////

- (IBAction)OnConnect:(id)sender
{
  (void)(sender);
	if ([[m_btnConnect title] compare:@"Connect"] == NSOrderedSame)
	{
		[self Connect];
	}
	else
	{
		[self Disconnect];
	}
}

- (IBAction)OnReset:(id)sender
{
  (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		// Reset the device
		HID_SMBUS_STATUS status = HidSmbus_Reset(m_hidSmbus);
		
		// The device will re-enumerate and the device pointer will become invalid
		[self Disconnect];
		
		// Output status to status bar
		// And play an audible alert if the status is not HID_SMBUS_SUCCESS
		[self OutputStatus:@"HidSmbus_Reset" withStatus:status];
	}
}

////////////////////////////////////////////////////////////////////////////
// Controll Class - Configuration Tab Actions
////////////////////////////////////////////////////////////////////////////

- (void)GetSmbusConfig:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		DWORD	bitRate;
		BYTE	ackAddress;
		BOOL	autoRespond;
		WORD	writeTimeout;
		WORD	readTimeout;
		BOOL	sclLowTimeout;
		WORD	transferRetries;
		
		// Get the SMBus configuration
		HID_SMBUS_STATUS status = HidSmbus_GetSmbusConfig(m_hidSmbus, &bitRate, &ackAddress, &autoRespond, &writeTimeout, &readTimeout, &sclLowTimeout, &transferRetries);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			[m_textBitRate setIntValue: (int) bitRate];
			[m_textMasterSlaveAddress setStringValue:[NSString stringWithFormat:@"%02X", (UINT)ackAddress]];
			[m_btnAutoRespond setState:autoRespond];
			[m_textWriteTimeout setIntValue:writeTimeout];
			[m_textReadTimeout setIntValue:readTimeout];
			[m_btnSclLowTimeout setState:sclLowTimeout];
			[m_textTransferRetries setIntValue:transferRetries];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetSmbusConfig" withStatus:status];
		}
	}
}

- (void)GetTimeouts:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		DWORD responseTimeout;
		
		// Get response timeouts
		HID_SMBUS_STATUS status = HidSmbus_GetTimeouts(m_hidSmbus, &responseTimeout);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			[m_textResponseTimeout setIntValue: (int)responseTimeout];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetTimeouts" withStatus:status];
		}
	}
}

- (IBAction)OnGetSmbusConfig:(id)sender
{
  (void)(sender);
	[self GetSmbusConfig:FALSE];
}

- (IBAction)OnSetSmbusConfig:(id)sender
{
  (void)(sender);
	if ([self ValidateConfiguration])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			BYTE ackAddress = [[[self GetHexArray:[m_textMasterSlaveAddress stringValue]] objectAtIndex:0] unsignedCharValue];
			
			// Set the SMBus configuration
			HID_SMBUS_STATUS status = HidSmbus_SetSmbusConfig(m_hidSmbus, (DWORD) [m_textBitRate intValue], ackAddress, (BOOL)[m_btnAutoRespond state], (WORD) [m_textWriteTimeout intValue], (WORD) [m_textReadTimeout intValue], (BOOL)[m_btnSclLowTimeout state], (WORD) [m_textTransferRetries intValue]);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_SetSmbusConfig" withStatus:status];
		}
	}
}

- (IBAction)OnGetTimeouts:(id)sender
{
  (void)(sender);
	[self GetTimeouts:FALSE];
}

- (IBAction)OnSetTimeouts:(id)sender
{
  (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
    assert([m_textResponseTimeout intValue] >= 0);
		DWORD responseTimeout = (DWORD) [m_textResponseTimeout intValue];
		
		// Set response timeouts
		HID_SMBUS_STATUS status = HidSmbus_SetTimeouts(m_hidSmbus, responseTimeout);
		
		// Output status to status bar
		// And play an audible alert if the status is not HID_SMBUS_SUCCESS
		[self OutputStatus:@"HidSmbus_SetTimeouts" withStatus:status];
	}
}

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Data Transfer Tab Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)OnReadRequest:(id)sender
{
    (void)(sender);
	if ([self ValidateDataTransferRead])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			BYTE slaveAddress	= [[[self GetHexArray:[m_textReadAddress stringValue]] objectAtIndex:0] unsignedCharValue];
      assert([m_textReadBytesToRead intValue] <= USHRT_MAX);
			WORD bytesToRead	= (WORD)[m_textReadBytesToRead intValue];
			
			// Issue a read request
			HID_SMBUS_STATUS status = HidSmbus_ReadRequest(m_hidSmbus, slaveAddress, bytesToRead);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_ReadRequest" withStatus:status];
		}
	}
}

- (IBAction)OnAddressedReadRequest:(id)sender
{
    (void)(sender);
	if ([self ValidateDataTransferAddressedRead])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			BYTE		slaveAddress		= [[[self GetHexArray:[m_textAddressedAddress stringValue]] objectAtIndex:0] unsignedCharValue];


      assert([m_textAddressedBytesToRead intValue] <= USHRT_MAX);

      WORD		bytesToRead			= (WORD) [m_textAddressedBytesToRead intValue];
			NSArray*	targetAddressArray	= [self GetHexArray:[m_textTargetAddress stringValue]];

      assert([targetAddressArray count] <= 255);

			BYTE		targetAddressSize	= (BYTE) [targetAddressArray count];
			BYTE		targetAddress[HID_SMBUS_MAX_TARGET_ADDRESS_SIZE];
			unsigned int i;
			
			// Copy target address from NSArray to BYTE array
			for (i = 0; i < HID_SMBUS_MAX_TARGET_ADDRESS_SIZE; i++)
			{
				if (i < targetAddressSize)
				{
					targetAddress[i] = [[targetAddressArray objectAtIndex:i] unsignedCharValue];
				}
				// Fill the rest of the address with 0x00
				else
				{
					targetAddress[i] = 0;
				}
			}
			
			// Issue an address read request
			HID_SMBUS_STATUS status = HidSmbus_AddressReadRequest(m_hidSmbus, slaveAddress, bytesToRead, targetAddressSize, targetAddress);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_AddressReadRequest" withStatus:status];
		}
	}
}

- (IBAction)OnForceReadResponse:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	if ([self ValidateDataTransferReadResponse])
	{
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{

      assert([m_textForceBytesToRead intValue] >= 0);
      assert([m_textForceBytesToRead intValue] < USHRT_MAX);
			WORD bytesToRead = (WORD) [m_textForceBytesToRead intValue];
			
			// Notify device that it should send a read response back
			HID_SMBUS_STATUS status = HidSmbus_ForceReadResponse(m_hidSmbus, bytesToRead);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_ForceReadResponse" withStatus:status];
		}
	}
}

- (IBAction)OnGetReadResponse:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		HID_SMBUS_S0	status0;
		BYTE			buffer[HID_SMBUS_MAX_READ_RESPONSE_SIZE];
		BYTE			numBytesRead = 0;
		
		// Wait for a read response
		HID_SMBUS_STATUS status = HidSmbus_GetReadResponse(m_hidSmbus, &status0, buffer, HID_SMBUS_MAX_READ_RESPONSE_SIZE, &numBytesRead);
		
		NSMutableString* receiveString = [NSMutableString stringWithCapacity:10];
		
		// Show the received data in the receive data editbox
		if (status == HID_SMBUS_SUCCESS)
		{
			int i;
			
			for (i = 0; i < numBytesRead; i++)
			{
				[receiveString appendFormat:@"%02X ", (UINT)buffer[i]];
			}
		}
		
		[m_textReceivedData setStringValue:receiveString];
		
		// Read response received successfully
		if (status == HID_SMBUS_SUCCESS)
		{
			// Update status bar text
			[self SetStatusText:[NSString stringWithFormat:@"Transfer Status: %s  Bytes Read: %u", HidSmbus_DecodeTransferStatus(status0), (UINT)numBytesRead]];
		}
		// Read response failed
		else
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetReadResponse" withStatus:status];
		}
	}
}

- (IBAction)OnWriteRequest:(id)sender
{
    (void)(sender);
	if ([self ValidateDataTransferWrite])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			NSArray*	writeDataArray		= [self GetHexArray:[m_textDataToWrite stringValue]];
      assert([writeDataArray count] < 256);
			BYTE		numBytesToWrite		= (BYTE) [writeDataArray count];
			BYTE		writeData[HID_SMBUS_MAX_WRITE_REQUEST_SIZE];
			NSArray*	writeAddressArray	= [self GetHexArray:[m_textWriteAddress stringValue]];
			BYTE		writeAddress		= [[writeAddressArray objectAtIndex:0] unsignedCharValue];
			unsigned int			i;
			
			// Copy NSArray data to BYTE array
			for (i = 0; i < HID_SMBUS_MAX_WRITE_REQUEST_SIZE; i++)
			{
				if (i < [writeDataArray count])
				{
					writeData[i] = [[writeDataArray objectAtIndex:i] unsignedCharValue];
				}
				// Fill rest of array with 0x00
				else
				{
					writeData[i] = 0;
				}
			}
			
			// Issue write transfer request
			HID_SMBUS_STATUS status = HidSmbus_WriteRequest(m_hidSmbus, writeAddress, writeData, numBytesToWrite);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_WriteRequest" withStatus:status];
		}
	}
}

- (IBAction)OnCancelTransfer:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		// Cancel pending transfer
		HID_SMBUS_STATUS status = HidSmbus_CancelTransfer(m_hidSmbus);
		
		// Output status to status bar
		// And play an audible alert if the status is not HID_SMBUS_SUCCESS
		[self OutputStatus:@"HidSmbus_CancelTransfer" withStatus:status];
	}
}

- (IBAction)OnGetTransferStatus:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		// Issue transfer status request
		HID_SMBUS_STATUS status = HidSmbus_TransferStatusRequest(m_hidSmbus);
		
		// Transfer status request was successful
		if (status == HID_SMBUS_SUCCESS)
		{
			HID_SMBUS_S0	status0;
			HID_SMBUS_S1	status1;
			WORD			numRetries;
			WORD			bytesRead;
			
			// Wait for transfer status response
			status = HidSmbus_GetTransferStatusResponse(m_hidSmbus, &status0, &status1, &numRetries, &bytesRead);
			
			// Transfer status response received successfully
			if (status == HID_SMBUS_SUCCESS)
			{
				// Update status bar text
				[self SetStatusText:[NSString stringWithFormat:@"Transfer Status: %s  Retries: %u  Bytes Read: %u", HidSmbus_DecodeTransferStatuses(status0, status1), (UINT)numRetries, (UINT)bytesRead]];
			}
			// Transfer status response failed
			else
			{
				// Output status to status bar
				// And play an audible alert if the status is not HID_SMBUS_SUCCESS
				[self OutputStatus:@"HidSmbus_GetTransferStatusResponse" withStatus:status];
			}
		}
		// Transfer status request failed
		else
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_TransferStatusRequest" withStatus:status];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Pin Configuration Tab Actions
////////////////////////////////////////////////////////////////////////////////

- (void)GetGpioConfig:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		BYTE direction;
		BYTE mode;
		BYTE function;
		BYTE clkDiv;
		
		// Get GPIO direction, mode, and function bitmasks
		HID_SMBUS_STATUS status = HidSmbus_GetGpioConfig(m_hidSmbus, &direction, &mode, &function, &clkDiv);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			// Update controls to reflect direction, mode, and function bitmasks
			[self SetPinDirection:direction withMode:mode withFunction:function];
			
			// Update clock divider and frequency controls
			[m_textClkDiv setIntegerValue:clkDiv];
			[self UpdateClkFrequency];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetGpioConfig" withStatus:status];
		}
	}
}

- (void)ReadLatch:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		BYTE latchValue;
		
		// Read GPIO latch value
		HID_SMBUS_STATUS status = HidSmbus_ReadLatch(m_hidSmbus, &latchValue);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			// Update controls to reflect latch value
			[self SetLatchValue:latchValue];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_ReadLatch" withStatus:status];
		}
	}
}

- (IBAction)OnGetGpioConfig:(id)sender
{
    (void)(sender);
	[self GetGpioConfig:FALSE];
}

- (IBAction)OnSetGpioConfig:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	if ([self ValidatePinConfiguration])
	{
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			BYTE direction;
			BYTE mode;
			BYTE function;
			BYTE clkDiv;
			
			// Get the direction, mode, and funciton bitmasks from the control states
			[self GetPinDirection:&direction getMode:&mode getFunction:&function];

      assert([m_textClkDiv intValue] >= 0 && [m_textClkDiv intValue] < 256);
			clkDiv = (BYTE) [m_textClkDiv intValue];
			
			// Set GPIO direction, mode, and function bitmasks
			HID_SMBUS_STATUS status = HidSmbus_SetGpioConfig(m_hidSmbus, direction, mode, function, clkDiv);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_SetGpioConfig" withStatus:status];
		}
	}	
}

- (IBAction)OnReadLatch:(id)sender
{
    (void)(sender);
	[self ReadLatch:FALSE];
}

- (IBAction)OnWriteLatch:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		BYTE latchValue;
		BYTE mask;
		
		// Get the latchValue and mask bitmasks from the control states
		latchValue = [self GetLatchValue:&mask];
		
		// Write GPIO latch value
		// "X" - means that the GPIO pin will not be modified
		HID_SMBUS_STATUS status = HidSmbus_WriteLatch(m_hidSmbus, latchValue, mask);
		
		// Output status to status bar
		// And play an audible alert if the status is not HID_SMBUS_SUCCESS
		[self OutputStatus:@"HidSmbus_WriteLatch" withStatus:status];
	}
}

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Customization Tab Actions
////////////////////////////////////////////////////////////////////////////////

- (void)GetUsbConfig:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		WORD vid;
		WORD pid;
		BYTE power;
		BYTE powerMode;
		WORD releaseVersion;
		
		// Get USB Configuration
		HID_SMBUS_STATUS status = HidSmbus_GetUsbConfig(m_hidSmbus, &vid, &pid, &power, &powerMode, &releaseVersion);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			[m_textCustomVid setStringValue:[NSString stringWithFormat:@"%04X", (UINT)vid]];
			[m_textCustomPid setStringValue:[NSString stringWithFormat:@"%04X", (UINT)pid]];
			[m_textCustomPower setIntValue:(power * 2)];
			[m_mtxCustomPowerMode selectCellAtRow:powerMode column:0];
			[m_textCustomReleaseMsb setIntValue:(releaseVersion >> 8)];
			[m_textCustomReleaseLsb setIntValue:(releaseVersion & 0xFF)];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetUsbConfig" withStatus:status];
		}
	}
}

- (void)GetLock:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		BYTE lock = 0x00;
		
		// Get lock byte
		HID_SMBUS_STATUS status = HidSmbus_GetLock(m_hidSmbus, &lock);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			// Check the field lock checkbox if the field is unlocked
			// Once a field is locked, it cannot be unlocked
			if (lock & HID_SMBUS_LOCK_VID)				[m_btnLockVid setState:NSOnState];
			else										[m_btnLockVid setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_PID)				[m_btnLockPid setState:NSOnState];
			else										[m_btnLockPid setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_POWER)			[m_btnLockPower setState:NSOnState];
			else										[m_btnLockPower setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_POWER_MODE)		[m_btnLockPowerMode setState:NSOnState];
			else										[m_btnLockPowerMode setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_RELEASE_VERSION)	[m_btnLockRelease setState:NSOnState];
			else										[m_btnLockRelease setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_MFG_STR)			[m_btnLockManufacturer setState:NSOnState];
			else										[m_btnLockManufacturer setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_PRODUCT_STR)		[m_btnLockProduct setState:NSOnState];
			else										[m_btnLockProduct setState:NSOffState];
			if (lock & HID_SMBUS_LOCK_SERIAL_STR)		[m_btnLockSerial setState:NSOnState];
			else										[m_btnLockSerial setState:NSOffState];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetLock" withStatus:status];
		}
	}
}

- (void)GetManufacturer:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		HID_SMBUS_CP2112_MFG_STR	manufacturingString;
		BYTE						strlen					= 0;
		
		// Get manufacturer string
		HID_SMBUS_STATUS status = HidSmbus_GetManufacturingString(m_hidSmbus, manufacturingString, &strlen);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			NSString* str = [[NSString stringWithCString:manufacturingString encoding:NSASCIIStringEncoding] substringToIndex:strlen];
			[m_textCustomManufacturer setStringValue:str];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetManufacturingString" withStatus:status];
		}
	}
}

- (void)GetProduct:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		HID_SMBUS_CP2112_PRODUCT_STR	productString;
		BYTE							strlen			= 0;
		
		// Get product string
		HID_SMBUS_STATUS status = HidSmbus_GetProductString(m_hidSmbus, productString, &strlen);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			NSString* str = [[NSString stringWithCString:productString encoding:NSASCIIStringEncoding] substringToIndex:strlen];
			[m_textCustomProduct setStringValue:str];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetProductString" withStatus:status];
		}
	}
}

- (void)GetSerial:(BOOL)silent
{
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		HID_SMBUS_CP2112_SERIAL_STR		serialString;
		BYTE							strlen			= 0;
		
		// Get serial string
		HID_SMBUS_STATUS status = HidSmbus_GetSerialString(m_hidSmbus, serialString, &strlen);
		
		if (status == HID_SMBUS_SUCCESS)
		{
			NSString* str = [[NSString stringWithCString:serialString encoding:NSASCIIStringEncoding] substringToIndex:strlen];
			[m_textCustomSerial setStringValue:str];
		}
		
		if (!silent)
		{
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_GetSerialString" withStatus:status];
		}
	}
}

- (IBAction)OnGetUsbConfig:(id)sender
{
    (void)(sender);
	[self GetUsbConfig:FALSE];
}

- (IBAction)OnSetUsbConfig:(id)sender
{
    (void)(sender);
	if ([self ValidateCustomizationUsbConfig])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			WORD vid;
			WORD pid;
			BYTE mask				= 0x00;
			BYTE power;
			BYTE powerMode;
			WORD releaseVersion;
			
			// Calculate USB configuration variable values
			vid				= [self GetShortHexValue:[m_textCustomVid stringValue]];
			pid				= [self GetShortHexValue:[m_textCustomPid stringValue]];

      assert( ([m_textCustomPower intValue] / 2) >= 0 && ([m_textCustomPower intValue] / 2) < 256);
      assert( [m_mtxCustomPowerMode selectedRow] >= 0 && [m_mtxCustomPowerMode selectedRow] < 256);

      assert( (([m_textCustomReleaseMsb intValue] << 8) | [m_textCustomReleaseLsb intValue]) >= 0  && (([m_textCustomReleaseMsb intValue] << 8) | [m_textCustomReleaseLsb intValue]) < USHRT_MAX );

			power			= (BYTE) [m_textCustomPower intValue] / 2;
			powerMode		= (BYTE) [m_mtxCustomPowerMode selectedRow];
			releaseVersion	= (WORD) ([m_textCustomReleaseMsb intValue] << 8) | (WORD) [m_textCustomReleaseLsb intValue];
			
			// Initialize the mask to decide which values will be programmed
			if ([m_btnCustomVid state] == NSOnState)	mask |= HID_SMBUS_SET_VID;
			if ([m_btnCustomPid state] == NSOnState)	mask |= HID_SMBUS_SET_PID;
			if ([m_btnCustomPower state] == NSOnState)	mask |= HID_SMBUS_SET_POWER;
			if ([m_btnCustomPowerMode state] == NSOnState)	mask |= HID_SMBUS_SET_POWER_MODE;
			if ([m_btnCustomRelease state] == NSOnState)	mask |= HID_SMBUS_SET_RELEASE_VERSION;
			
			// Set USB Configuration
			HID_SMBUS_STATUS status = HidSmbus_SetUsbConfig(m_hidSmbus, vid, pid, power, powerMode, releaseVersion, mask);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_SetUsbConfig" withStatus:status];
		}
	}	
}

- (IBAction)OnGetLock:(id)sender
{
    (void)(sender);
	[self GetLock:FALSE];
}

- (IBAction)OnSetLock:(id)sender
{
    (void)(sender);
	BOOL opened;
	
	// Make sure that the device is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
	{
		BYTE lock = 0x00;
		
		// Uncheck the field lock checkbox to prevent further programming
		// of that field
		//
		// Once a field is locked, it cannot be unlocked
		if ([m_btnLockVid state] == NSOnState)				lock |= HID_SMBUS_LOCK_VID;
		if ([m_btnLockPid state] == NSOnState)				lock |= HID_SMBUS_LOCK_PID;
		if ([m_btnLockPower state] == NSOnState)			lock |= HID_SMBUS_LOCK_POWER;
		if ([m_btnLockPowerMode state] == NSOnState)		lock |= HID_SMBUS_LOCK_POWER_MODE;
		if ([m_btnLockRelease state] == NSOnState)			lock |= HID_SMBUS_LOCK_RELEASE_VERSION;
		if ([m_btnLockManufacturer state] == NSOnState)		lock |= HID_SMBUS_LOCK_MFG_STR;
		if ([m_btnLockProduct state] == NSOnState)			lock |= HID_SMBUS_LOCK_PRODUCT_STR;
		if ([m_btnLockSerial state] == NSOnState)			lock |= HID_SMBUS_LOCK_SERIAL_STR;
		
		// Set lock byte
		HID_SMBUS_STATUS status = HidSmbus_SetLock(m_hidSmbus, lock);
		
		// Output status to status bar
		// And play an audible alert if the status is not HID_SMBUS_SUCCESS
		[self OutputStatus:@"HidSmbus_SetLock" withStatus:status];
	}
}

- (IBAction)OnGetManufacturer:(id)sender
{
    (void)(sender);
	[self GetManufacturer:FALSE];
}

- (IBAction)OnSetManufacturer:(id)sender
{
    (void)(sender);
	if ([self ValidateCustomizationManufacturer])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			char manufacturingString[HID_SMBUS_CP2112_MFG_STRLEN + 1];
			BYTE strlen = 0;

      assert([[m_textCustomManufacturer stringValue] length]);
			strlen = (BYTE)[[m_textCustomManufacturer stringValue] length];
			
			// Convert NSString to an array of BYTE
			[[m_textCustomManufacturer stringValue] getCString:manufacturingString maxLength:HID_SMBUS_CP2112_MFG_STRLEN + 1 encoding:NSASCIIStringEncoding];
			
			// Set manufacturer string
			HID_SMBUS_STATUS status = HidSmbus_SetManufacturingString(m_hidSmbus, manufacturingString, strlen);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_SetManufacturingString" withStatus:status];
		}
	}
}

- (IBAction)OnGetProduct:(id)sender
{
    (void)(sender);
	[self GetProduct:FALSE];
}

- (IBAction)OnSetProduct:(id)sender
{
    (void)(sender);
	if ([self ValidateCustomizationProduct])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			char productString[HID_SMBUS_CP2112_PRODUCT_STRLEN + 1];
			BYTE strlen = 0;

      assert([[m_textCustomProduct stringValue] length] < 256);
			strlen = (BYTE) [[m_textCustomProduct stringValue] length];
			
			// Convert NSString to an array of BYTE
			[[m_textCustomProduct stringValue] getCString:productString maxLength:HID_SMBUS_CP2112_PRODUCT_STRLEN + 1 encoding:NSASCIIStringEncoding];
			
			// Set product string
			HID_SMBUS_STATUS status = HidSmbus_SetProductString(m_hidSmbus, productString, strlen);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_SetProductString" withStatus:status];
		}
	}
}

- (IBAction)OnGetSerial:(id)sender
{
    (void)(sender);
	[self GetSerial:FALSE];
}

- (IBAction)OnSetSerial:(id)sender
{
    (void)(sender);
	if ([self ValidateCustomizationSerial])
	{
		BOOL opened;
		
		// Make sure that the device is opened
		if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS && opened)
		{
			char serialString[HID_SMBUS_CP2112_SERIAL_STRLEN + 1];
			BYTE strlen = 0;

      assert([[m_textCustomSerial stringValue] length] < 256);
			strlen = (BYTE) [[m_textCustomSerial stringValue] length];
			
			// Convert NSString to an array of BYTE
			[[m_textCustomSerial stringValue] getCString:serialString maxLength:HID_SMBUS_CP2112_SERIAL_STRLEN + 1 encoding:NSASCIIStringEncoding];
			
			// Set serial string
			HID_SMBUS_STATUS status = HidSmbus_SetSerialString(m_hidSmbus, serialString, strlen);
			
			// Output status to status bar
			// And play an audible alert if the status is not HID_SMBUS_SUCCESS
			[self OutputStatus:@"HidSmbus_SetSerialString" withStatus:status];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Validation Functions
////////////////////////////////////////////////////////////////////////////////

// Remove whitespace and invalid characters from a string
// and return
- (NSString*)CleanHexString:(NSString*)editStr
{
	NSMutableString*	cleanStr	= [NSMutableString stringWithCapacity:255];
	NSMutableString*	hexStr		= [NSMutableString stringWithCapacity:255];
	
	unsigned int i;
	
	[cleanStr setString:editStr];
	
	// Remove spaces
	[cleanStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [cleanStr length])];
	
	// Remove commas
	[cleanStr replaceOccurrencesOfString:@"," withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [cleanStr length])];
	
	// Only parse text including valid hex characters
	// (stop at the first invalid character)
	for (i = 0; i < [cleanStr length]; i++)
	{
		unichar letter = [cleanStr characterAtIndex:i];
		
		if ((letter >= '0' && letter <= '9') ||
			(letter >= 'a' && letter <= 'f') ||
			(letter >= 'A' && letter <= 'F'))
		{
			[hexStr appendString:[NSString stringWithFormat:@"%c", letter]];
		}
		else
		{
			break;
		}
	}
	
	// Odd number of characters
	if ([hexStr length] % 2 == 1)
	{
		// Insert a "0" before the last character to make a
		// complete set of hex bytes (two characters each)
		[hexStr insertString:@"0" atIndex:([hexStr length] - 1)];
	}
	
	return hexStr;
}

// Given an input string containing hex byte values,
// convert each to a BYTE number value and return in an
// array
- (NSArray*)GetHexArray:(NSString*)hexStr
{
	NSMutableArray*		hexArray = [NSMutableArray arrayWithCapacity:10];
	unsigned int					i;
	UINT				value;
	
	// Remove invalid hex characters and whitespace
	hexStr = [self CleanHexString:hexStr];
	
	// Convert each hex byte string to a BYTE value
	for (i = 0; i < ([hexStr length] / 2); i++)
	{
		// Extract each 2-character hex string
		NSScanner* hexVal = [NSScanner scannerWithString:[hexStr substringWithRange:NSMakeRange(i*2, 2)]];
		
		// Convert the hex byte to a numeric value
		[hexVal scanHexInt:&value];
		
		// Return decimal value in an array
		[hexArray addObject:[NSNumber numberWithUnsignedChar:(BYTE)value]];
	}

	return hexArray;
}

- (WORD)GetShortHexValue:(NSString *)hexStr
{
  WORD value = 0;

  const char *s = [hexStr UTF8String];

  for (unsigned int i=0; s[i]; ++i) {
    char c = s[i];

    value *= 16;

    if (c >= 'a' && c <='f') {
      value += 10 + (c - 'a');

    } else if ( c >= 'A' && c <= 'F') {
      value += 10 + (c - 'A');

    } else if ( c >= '0' && c <= '9') {
      value += (c - '0');

    } else {
        // invalid character.
      [NSException raise:@"Invalid character in hex string" format:@"String %@ contains an invalid hex character.", hexStr];
    }
  }

  return value;
}

// Calculate the decimal value of a hexadecimal string
- (DWORD)GetHexValue:(NSString*)hexStr
{
	DWORD		value		= 0x00000000;
	NSArray*	hexArray	= [self GetHexArray:hexStr];
	unsigned int			i;
	
	// Calculate the decimal value for each byte in the hex string
	for (i = 0; i < [hexArray count]; i++)
	{
		// Shift previous byte by 1 byte to the left
		value <<= 8;
		value |= [[hexArray objectAtIndex:i] unsignedLongValue];
	}
	
	return value;
}

// Validate a hex string field:
// - textField: points to a text field to validate
// - numBytes:	the expected number of hex bytes in the text field
// - minimum:	the minimum hex value
// - maximum:	the maximum hex value
// - isEven:	Set to TRUE if validating an even hex value
// - isOdd:		Set to TRUE if validating an odd hex value
- (BOOL)ValidateHexField:(NSTextField*)textField numBytes:(int)numBytes minimum:(DWORD)min maximum:(DWORD)max isEven:(BOOL)even isOdd:(BOOL)odd
{
	BOOL		valid		= FALSE;
	NSArray*	hexArray	= [self GetHexArray:[textField stringValue]];
	DWORD		hexValue	= 0x00000000;

	// First check hex value for correct number of bytes
	if ( (long) [hexArray count] != numBytes)
	{

    NSAlert * alert = [[NSAlert alloc] init];
    alert.icon = [NSImage imageNamed:NSImageNameInfo];
    alert.messageText = @"Invalid Hexadecimal Value";
    alert.informativeText = [NSString stringWithFormat:@"Please enter a %d-byte hexadecimal value.", numBytes];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
    [alert release];


		[textField selectText:self];
	}
	else
	{
		// Convert hex array to decimal value
		hexValue = [self GetHexValue:[textField stringValue]];
		
		// Check range
		if (hexValue < min || hexValue > max)
		{

      NSAlert * alert = [[NSAlert alloc] init];
      alert.icon = [NSImage imageNamed:NSImageNameInfo];
      alert.messageText = @"Invalid Hexadecimal Value";
      alert.informativeText = [NSString stringWithFormat:@"Please enter an integer between 0x%X and 0x%X.", (UINT)min, (UINT)max];
      [alert addButtonWithTitle:@"OK"];
      [alert runModal];
      [alert release];

			[textField selectText:self];
		}
		// Check if even
		else if (even && (hexValue % 2 == 1))
		{
			NSRunAlertPanel(@"Invalid Hexadecimal Value", @"Please enter an even integer.", nil, nil, nil);
			[textField selectText:self];
		}
		// Check if odd
		else if (odd && (hexValue % 2 == 0))
		{
			NSRunAlertPanel(@"Invalid Hexadecimal Value", @"Please enter an odd integer.", nil, nil, nil);
			[textField selectText:self];
		}
		// Passed all validation
		else
		{
			valid = TRUE;
		}
	}
	
	return valid;
}

// Validate:
// - Configuration Tab
//   - SMBus Settings Group Controls
- (BOOL)ValidateConfiguration
{
	BOOL		valid			= FALSE;
//	NSArray*	hexArray		= [self GetHexArray:[m_textMasterSlaveAddress stringValue]];
//	BYTE		masterAddress	= 0;
	
	if ([m_textBitRate intValue] < HID_SMBUS_MIN_BIT_RATE)
	{
		NSRunAlertPanel(@"Invalid Bit Rate", @"SMBus bit rate must be at least 1 Hz.", nil, nil, nil);
		[m_textBitRate selectText:self];
	}
	else if (![self ValidateHexField:m_textMasterSlaveAddress numBytes:1 minimum:HID_SMBUS_MIN_ADDRESS maximum:HID_SMBUS_MAX_ADDRESS isEven:TRUE isOdd:FALSE])
	{
		// ValidateHexField will display any validation errors
	}
	else if ([m_textWriteTimeout intValue] < HID_SMBUS_MIN_TIMEOUT ||
			 [m_textWriteTimeout intValue] > HID_SMBUS_MAX_TIMEOUT)
	{
    [self runModalInfoMessage:@"Invalid Write Timeout" withMessage:[NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)HID_SMBUS_MIN_TIMEOUT, (UINT)HID_SMBUS_MAX_TIMEOUT]];
		[m_textWriteTimeout selectText:self];
	}
	else if ([m_textReadTimeout intValue] < HID_SMBUS_MIN_TIMEOUT ||
			 [m_textReadTimeout intValue] > HID_SMBUS_MAX_TIMEOUT)
	{
		    [self runModalInfoMessage:@"Invalid Read Timeout" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)HID_SMBUS_MIN_TIMEOUT, (UINT)HID_SMBUS_MAX_TIMEOUT]];

		[m_textReadTimeout selectText:self];
	}
	else if ([m_textTransferRetries intValue] < 0 ||
			 [m_textTransferRetries intValue] > HID_SMBUS_MAX_RETRIES)
	{
		[self runModalInfoMessage:@"Invalid Transfer Retries" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)0, (UINT)HID_SMBUS_MAX_RETRIES]];

		[m_textTransferRetries selectText:self];
	}
	else
	{
		// Passed all validation tests
		valid = TRUE;
	}
	
	return valid;	
}

// Validate:
// - Data Transfer Tab
//   - Read Request Group Controls
- (BOOL)ValidateDataTransferRead
{
	BOOL valid = FALSE;

	if (![self ValidateHexField:m_textReadAddress numBytes:1 minimum:HID_SMBUS_MIN_ADDRESS maximum:HID_SMBUS_MAX_ADDRESS isEven:TRUE isOdd:FALSE])
	{
		// ValidateHexField will display any validation errors
	}
	else if ([m_textReadBytesToRead intValue] < HID_SMBUS_MIN_READ_REQUEST_SIZE ||
			 [m_textReadBytesToRead intValue] > HID_SMBUS_MAX_READ_REQUEST_SIZE)
	{

    [self runModalInfoMessage: @"Invalid Read Request Size" withMessage:[NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)HID_SMBUS_MIN_READ_REQUEST_SIZE, (UINT)HID_SMBUS_MAX_READ_REQUEST_SIZE] ];
		[m_textReadBytesToRead selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	
	return valid;
}

// Validate:
// - Data Transfer Tab
//   - Address Read Request Group Controls
- (BOOL)ValidateDataTransferAddressedRead
{
	BOOL		valid				= FALSE;
	NSArray*	targetAddressArray	= [self GetHexArray:[m_textTargetAddress stringValue]];

	if (![self ValidateHexField:m_textAddressedAddress numBytes:1 minimum:HID_SMBUS_MIN_ADDRESS maximum:HID_SMBUS_MAX_ADDRESS isEven:TRUE isOdd:FALSE])
	{
		// ValidateHexField will display any validation errors
	}
	else if ([m_textTargetAddressSize intValue] < HID_SMBUS_MIN_TARGET_ADDRESS_SIZE ||
			 [m_textTargetAddressSize intValue] > HID_SMBUS_MAX_TARGET_ADDRESS_SIZE)
	{
    [self runModalInfoMessage: @"Invalid Target Address Size" withMessage:[NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)HID_SMBUS_MIN_TARGET_ADDRESS_SIZE, (UINT)HID_SMBUS_MAX_TARGET_ADDRESS_SIZE] ];

		[m_textTargetAddressSize selectText:self];
	}
	else if ( (int)[targetAddressArray count] != [m_textTargetAddressSize intValue])
	{
    [self runModalInfoMessage: @"Invalid Target Address Size" withMessage: [NSString stringWithFormat:@"Please enter a %u-byte hexadecimal value.", (UINT)[m_textTargetAddressSize intValue]] ];
		[m_textTargetAddress selectText:self];
	}
	else if ([m_textAddressedBytesToRead intValue] < HID_SMBUS_MIN_READ_REQUEST_SIZE ||
			 [m_textAddressedBytesToRead intValue] > HID_SMBUS_MAX_READ_REQUEST_SIZE)
	{
    [self runModalInfoMessage: @"Invalid Addressed Read Request Size" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)HID_SMBUS_MIN_READ_REQUEST_SIZE, (UINT)HID_SMBUS_MAX_READ_REQUEST_SIZE]];
		[m_textAddressedBytesToRead selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	
	return valid;
}

// Validate:
// - Data Transfer Tab
//   - Read Response Group Controls
- (BOOL)ValidateDataTransferReadResponse
{
	BOOL valid  = FALSE;
	
	if ([m_textForceBytesToRead intValue] < HID_SMBUS_MIN_READ_REQUEST_SIZE ||
		[m_textForceBytesToRead intValue] > HID_SMBUS_MAX_READ_REQUEST_SIZE)
	{
    [self runModalInfoMessage: @"Invalid Request Size" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)HID_SMBUS_MIN_READ_REQUEST_SIZE, (UINT)HID_SMBUS_MAX_READ_REQUEST_SIZE] ];
		[m_textForceBytesToRead selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	
	return valid;
}

// Validate:
// - Data Transfer Tab
//   - Write Request Group Controls
- (BOOL)ValidateDataTransferWrite
{
	BOOL valid = FALSE;
	
	if ([[self GetHexArray:[m_textDataToWrite stringValue]] count] < HID_SMBUS_MIN_WRITE_REQUEST_SIZE ||
		[[self GetHexArray:[m_textDataToWrite stringValue]] count] > HID_SMBUS_MAX_WRITE_REQUEST_SIZE)
	{
		[self runModalInfoMessage: @"Invalid Write Data" withMessage: [NSString stringWithFormat:@"Please enter between %u and %u hexadecimal bytes.", (UINT)HID_SMBUS_MIN_WRITE_REQUEST_SIZE, (UINT)HID_SMBUS_MAX_WRITE_REQUEST_SIZE]];
		[m_textDataToWrite selectText:self];
	}
	else if (![self ValidateHexField:m_textWriteAddress numBytes:1 minimum:HID_SMBUS_MIN_ADDRESS maximum:HID_SMBUS_MAX_ADDRESS isEven:TRUE isOdd:FALSE])
	{
		// ValidateHexField will display any validation errors
	}
	else
	{
		valid = TRUE;
	}
	
	
	return valid;
}

// Validate:
// - Pin Configuration Tab
//   - GPIO Configuration Group Controls
- (BOOL)ValidatePinConfiguration
{
	BOOL valid = FALSE;
	
	if ([m_textClkDiv intValue] < 0 ||
		[m_textClkDiv intValue] > 255)
	{

    [self runModalInfoMessage: @"Invalid Clock Divider" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)0, (UINT)255] ];
		[m_textClkDiv selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	return valid;
}

// Validate:
// - Customization Tab
//   - USB Customization Group Controls
- (BOOL)ValidateCustomizationUsbConfig
{
	BOOL valid = FALSE;
	
	if (![self ValidateHexField:m_textCustomVid numBytes:2 minimum:0x0000 maximum:0xFFFF isEven:FALSE isOdd:FALSE])
	{
		// ValidateHexField will display any validation errors
	}
	else if (![self ValidateHexField:m_textCustomPid numBytes:2 minimum:0x0000 maximum:0xFFFF isEven:FALSE isOdd:FALSE])
	{
		// ValidateHexField will display any validation errors
	}
	else if ([m_textCustomPower intValue] < 0 || [m_textCustomPower intValue] > (HID_SMBUS_BUS_POWER_MAX * 2))
	{
    [self runModalInfoMessage: @"Invalid Power Value" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)0, (UINT)(HID_SMBUS_BUS_POWER_MAX * 2)]];
		[m_textCustomPower selectText:self];
	}
	else if ([m_textCustomPower intValue] % 2 == 1)
	{
		NSRunAlertPanel(@"Invalid Power Value", @"Please enter an even integer.", nil, nil, nil);
		[m_textCustomPower selectText:self];
	}
	else if ([m_textCustomReleaseMsb intValue] < 0 || [m_textCustomReleaseMsb intValue] > 255)
	{
    [self runModalInfoMessage: @"Invalid Release Version" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)0, (UINT)255]];
		[m_textCustomReleaseMsb selectText:self];
	}
	else if ([m_textCustomReleaseLsb intValue] < 0 || [m_textCustomReleaseLsb intValue] > 255)
	{
    [self runModalInfoMessage: @"Invalid Release Version" withMessage: [NSString stringWithFormat:@"Please enter an integer between %u and %u.", (UINT)0, (UINT)255]];
		[m_textCustomReleaseLsb selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	return valid;
}

// Validate:
// - Customization Tab
//   - Manufacturer Controls
- (BOOL)ValidateCustomizationManufacturer
{
	BOOL valid = FALSE;
	
	if ([[m_textCustomManufacturer stringValue] length] > HID_SMBUS_CP2112_MFG_STRLEN)
	{

    [self runModalInfoMessage: @"Invalid Manufacturer String Length" withMessage: [NSString stringWithFormat:@"Maximum string length is: %u\nSpecified string length is: %u", (UINT)HID_SMBUS_CP2112_MFG_STRLEN, (UINT)[[m_textCustomManufacturer stringValue] length]]];
		[m_textCustomManufacturer selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	return valid;
}

// Validate:
// - Customization Tab
//   - Product Controls
- (BOOL)ValidateCustomizationProduct
{
	BOOL valid = FALSE;
	
	if ([[m_textCustomProduct stringValue] length] > HID_SMBUS_CP2112_PRODUCT_STRLEN)
	{
    [self runModalInfoMessage:@"Invalid Product String Length" withMessage: [NSString stringWithFormat:@"Maximum string length is: %u\nSpecified string length is: %u", (UINT)HID_SMBUS_CP2112_PRODUCT_STRLEN, (UINT)[[m_textCustomProduct stringValue] length]]];
		[m_textCustomProduct selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	return valid;
}

// Validate:
// - Customization Tab
//   - Serial Controls
- (BOOL)ValidateCustomizationSerial
{
	BOOL valid = FALSE;
	
	if ([[m_textCustomSerial stringValue] length] > HID_SMBUS_CP2112_SERIAL_STRLEN)
	{

    [self runModalInfoMessage:@"Invalid Serial String Length" withMessage: [NSString stringWithFormat:@"Maximum string length is: %u\nSpecified string length is: %u", (UINT)HID_SMBUS_CP2112_SERIAL_STRLEN, (UINT)[[m_textCustomSerial stringValue] length]]];
		[m_textCustomSerial selectText:self];
	}
	else
	{
		valid = TRUE;
	}
	
	return valid;
}

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Delegate Functions
////////////////////////////////////////////////////////////////////////////////

- (void)windowWillClose:(NSNotification*)notification
{
  (void)(notification);
	BOOL opened;
	
	// Close the device if it is opened
	if (HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS &&
		opened)
	{
		HidSmbus_Close(m_hidSmbus);
		m_hidSmbus = NULL;
	}
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
  (void)(notification);
	// Update device information for newly selected device
	// (not connected)
	[self UpdateDeviceInformation:FALSE];
}

- (void)comboBoxWillDismiss:(NSNotification *)notification
{
  (void)(notification);
	NSString*	serial;
	DWORD		deviceNum;
	
	if ([self GetSelectedDevice:&serial])
	{
		// If the selected device has been removed
		if (![self FindDevice:serial deviceNum:&deviceNum])
		{
			// Then update the device list
			[self UpdateDeviceList];
			[self UpdateDeviceInformation:FALSE];
		}
	}
}

- (void)comboBoxWillPopUp:(NSNotification *)notification
{
  (void)(notification);
	// Automatically update the device list when the list is opened/dropped down
	[self UpdateDeviceList];
	
	// Update device information for selected device (not connected)
	[self UpdateDeviceInformation:FALSE];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
  (void)(aNotification);
	[self UpdateClkFrequency];
}

////////////////////////////////////////////////////////////////////////////////
// Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib
{
	[self InitializeDialog];
}

////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////

- (void)InitializeDialog
{
	[self InitStatusBar];
	
	// Initially disable device controls
	[self EnableDeviceCtrls:FALSE];
	
	[self UpdateDeviceList];
	[self UpdateDeviceInformation:FALSE];
}

// Initialize the status bar
// - Set default status bar text to "Not Connected" and ""
- (void)InitStatusBar
{
	[self SetConnectionText:@"Not Connected"];
	[self SetStatusText:@""];
}

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////

// Set connection status bar text
- (void)SetConnectionText:(NSString*)text
{
	[m_textConnection setStringValue:text];
}

// Set status bar text
- (void)SetStatusText:(NSString*)text
{
	[m_textStatus setStringValue:text];
}

// Populate the device list combobox with connected device serial strings
// - Save previous device serial string selection
// - Fill the device list with connected device serial strings
// - Restore previous device selection
- (void)UpdateDeviceList
{
	DWORD					numDevices;
	DWORD					i;
	HID_SMBUS_DEVICE_STR	str;
	NSString*				selText;
	
	// Get current device selection
	selText = [m_comboDeviceList objectValueOfSelectedItem];

	// Reset the device list
	[m_comboDeviceList removeAllItems];
	[m_comboDeviceList setStringValue:@""];
	
	HidSmbus_GetNumDevices(&numDevices, VID, PID);
	
	// Display connected HID SMBus device serial strings in the combo box
	for (i = 0; i < numDevices; i++)
	{
		if (HidSmbus_GetString(i, VID, PID, str, HID_SMBUS_GET_SERIAL_STR) == HID_SMBUS_SUCCESS)
		{
			[m_comboDeviceList addItemWithObjectValue:[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
		}
	}
	
	// Reselect the old device
	[m_comboDeviceList selectItemWithObjectValue:selText];
	
	// If no device is selected, then select the first available
	// device
	if ([m_comboDeviceList indexOfSelectedItem] == -1 &&
		[m_comboDeviceList numberOfItems] > 0)
	{
		[m_comboDeviceList selectItemAtIndex:0];
	}
}

// Retrieve device information strings and display on the dialog
- (void)UpdateDeviceInformation:(BOOL)connected
{
	BOOL					opened;
	HID_SMBUS_DEVICE_STR	deviceString;
	WORD					vid;
	WORD					pid;
	WORD					releaseNumber;
	BYTE					partNumber;
	BYTE					version;

  char devicePathString[PATH_MAX];
	NSString*				vidString				= @"";
	NSString*				pidString				= @"";
	NSString*				releaseNumberString		= @"";
	NSString*				partNumberString		= @"";
	NSString*				versionString			= @"";
	NSString*				serialString			= @"";
	NSString*				pathString				= @"";
	NSString*				manufacturerString		= @"";
	NSString*				productString			= @"";

	// If we're already connected to the device, then we can call the
	// opened version of the device information functions
	if (connected == TRUE &&
		HidSmbus_IsOpened(m_hidSmbus, &opened) == HID_SMBUS_SUCCESS &&
		opened == TRUE)
	{
		// Update device information (opened)
		
		if (HidSmbus_GetOpenedAttributes(m_hidSmbus, &vid, &pid, &releaseNumber) == HID_SMBUS_SUCCESS)
		{
			vidString				= [NSString stringWithFormat:@"%04X", (UINT)vid];
			pidString				= [NSString stringWithFormat:@"%04X", (UINT)pid];
			releaseNumberString		= [NSString stringWithFormat:@"%X.%02X", (UINT)(releaseNumber >> 8), (UINT)((BYTE)releaseNumber)];
		}
		if (HidSmbus_GetPartNumber(m_hidSmbus, &partNumber, &version) == HID_SMBUS_SUCCESS)
		{
			partNumberString		= [NSString stringWithFormat:@"%u", (UINT)partNumber];
			versionString			= [NSString stringWithFormat:@"%u", (UINT)version];
		}
		if (HidSmbus_GetOpenedString(m_hidSmbus, deviceString, HID_SMBUS_GET_SERIAL_STR) == HID_SMBUS_SUCCESS)
		{
			serialString			= [NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding];
		}

    
		if (HidSmbus_GetOpenedString(m_hidSmbus, devicePathString, HID_SMBUS_GET_PATH_STR) == HID_SMBUS_SUCCESS)
		{
			pathString				= [NSString stringWithCString:devicePathString encoding:NSASCIIStringEncoding];
		}
		if (HidSmbus_GetOpenedString(m_hidSmbus, deviceString, HID_SMBUS_GET_MANUFACTURER_STR) == HID_SMBUS_SUCCESS)
		{
			manufacturerString		= [NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding];
		}
		if (HidSmbus_GetOpenedString(m_hidSmbus, deviceString, HID_SMBUS_GET_PRODUCT_STR) == HID_SMBUS_SUCCESS)
		{
			productString			= [NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding];
		}
	}
	else
	{
		NSString*	serial;
		DWORD		deviceNum;
		
		// Get selected device serial string
		if ([self GetSelectedDevice:&serial])
		{
			// Find the selected device number
			if ([self FindDevice:serial deviceNum:&deviceNum])
			{
				// Update device information
				
				if (HidSmbus_GetAttributes(deviceNum, VID, PID, &vid, &pid, &releaseNumber) == HID_SMBUS_SUCCESS)
				{
					vidString				= [NSString stringWithFormat:@"%04X", (UINT)vid];
					pidString				= [NSString stringWithFormat:@"%04X", (UINT)pid];
					releaseNumberString		= [NSString stringWithFormat:@"%X.%02X", (UINT)(releaseNumber >> 8), (UINT)((BYTE)releaseNumber)];
				}
				if (HidSmbus_GetString(deviceNum, VID, PID, deviceString, HID_SMBUS_GET_SERIAL_STR) == HID_SMBUS_SUCCESS)
				{
					serialString			= [NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding];
				}
				if (HidSmbus_GetString(deviceNum, VID, PID, devicePathString, HID_SMBUS_GET_PATH_STR) == HID_SMBUS_SUCCESS)
				{
					pathString				= [NSString stringWithCString:devicePathString encoding:NSASCIIStringEncoding];
				}
				if (HidSmbus_GetString(deviceNum, VID, PID, deviceString, HID_SMBUS_GET_MANUFACTURER_STR) == HID_SMBUS_SUCCESS)
				{
					manufacturerString		= [NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding];
				}
				if (HidSmbus_GetString(deviceNum, VID, PID, deviceString, HID_SMBUS_GET_PRODUCT_STR) == HID_SMBUS_SUCCESS)
				{
					productString			= [NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding];
				}
			}
		}
	}
	
	// Update device information on the dialog
	[m_textVid setStringValue:vidString];
	[m_textPid setStringValue:pidString];
	[m_textReleaseNumber setStringValue:releaseNumberString];
	[m_textPartNumber setStringValue:partNumberString];
	[m_textVersion setStringValue:versionString];
	[m_textPath setStringValue:pathString];
	[m_textSerial setStringValue:serialString];
	[m_textManufacturer setStringValue:manufacturerString];
	[m_textProduct setStringValue:productString];
}

// Enable/disable all of the controls on each of the property page
// dialogs and the reset button
- (void)EnableDeviceCtrls:(BOOL)enable
{
	[m_btnReset setEnabled:enable];
	
	// Enable/disable the configuration tab controls
	[m_textBitRate setEnabled:enable];
	[m_textMasterSlaveAddress setEnabled:enable];
	[m_btnAutoRespond setEnabled:enable];
	[m_textWriteTimeout setEnabled:enable];
	[m_textReadTimeout setEnabled:enable];
	[m_btnSclLowTimeout setEnabled:enable];
	[m_textTransferRetries setEnabled:enable];
	[m_textResponseTimeout setEnabled:enable];
	[m_btnGetConfig setEnabled:enable];
	[m_btnSetConfig setEnabled:enable];
	[m_btnGetTimeout setEnabled:enable];
	[m_btnSetTimeout setEnabled:enable];
	
	// Enable/disable the data transfer tab controls
	[m_textReadAddress setEnabled:enable];
	[m_textReadBytesToRead setEnabled:enable];
	[m_btnRead setEnabled:enable];
	[m_textAddressedAddress setEnabled:enable];
	[m_textTargetAddressSize setEnabled:enable];
	[m_textTargetAddress setEnabled:enable];
	[m_textAddressedBytesToRead setEnabled:enable];
	[m_btnAddressedRead setEnabled:enable];
	[m_textReceivedData setEnabled:enable];
	[m_textForceBytesToRead setEnabled:enable];
	[m_btnForceReadResponse setEnabled:enable];
	[m_btnGetReadResponse setEnabled:enable];
	[m_textDataToWrite setEnabled:enable];
	[m_textWriteAddress setEnabled:enable];
	[m_btnWriteRequest setEnabled:enable];
	[m_btnCancelTransfer setEnabled:enable];
	[m_btnGetTransferStatus setEnabled:enable];
	
	// Enable/disable the pin configuration tab controls
	[m_btnGetGpioConfig setEnabled:enable];
	[m_btnSetGpioConfig setEnabled:enable];
	[m_comboGpio0 setEnabled:enable];
	[m_comboGpio1 setEnabled:enable];
	[m_comboGpio2 setEnabled:enable];
	[m_comboGpio3 setEnabled:enable];
	[m_comboGpio4 setEnabled:enable];
	[m_comboGpio5 setEnabled:enable];
	[m_comboGpio6 setEnabled:enable];
	[m_comboGpio7 setEnabled:enable];
	[m_textClkDiv setEnabled:enable];
	[m_textClkFreq setEnabled:enable];
	[m_btnReadLatch setEnabled:enable];
	[m_btnWriteLatch setEnabled:enable];
	[m_btnGpio0 setEnabled:enable];
	[m_btnGpio1 setEnabled:enable];
	[m_btnGpio2 setEnabled:enable];
	[m_btnGpio3 setEnabled:enable];
	[m_btnGpio4 setEnabled:enable];
	[m_btnGpio5 setEnabled:enable];
	[m_btnGpio6 setEnabled:enable];
	[m_btnGpio7 setEnabled:enable];
	
	// Enable/disable the customization tab controls
	[m_btnGetUsbConfig setEnabled:enable];
	[m_btnSetUsbConfig setEnabled:enable];
	[m_btnCustomVid setEnabled:enable];
	[m_textCustomVid setEnabled:enable];
	[m_btnCustomPid setEnabled:enable];
	[m_textCustomPid setEnabled:enable];
	[m_btnCustomPower setEnabled:enable];
	[m_textCustomPower setEnabled:enable];
	[m_btnCustomPowerMode setEnabled:enable];
	[m_mtxCustomPowerMode setEnabled:enable];
	[m_btnCustomRelease setEnabled:enable];
	[m_textCustomReleaseMsb setEnabled:enable];
	[m_textCustomReleaseLsb setEnabled:enable];
	[m_btnGetLock setEnabled:enable];
	[m_btnSetLock setEnabled:enable];
	[m_btnLockVid setEnabled:enable];
	[m_btnLockPid setEnabled:enable];
	[m_btnLockPower setEnabled:enable];
	[m_btnLockPowerMode setEnabled:enable];
	[m_btnLockRelease setEnabled:enable];
	[m_btnLockManufacturer setEnabled:enable];
	[m_btnLockProduct setEnabled:enable];
	[m_btnLockSerial setEnabled:enable];
	[m_btnGetManufacturer setEnabled:enable];
	[m_btnSetManufacturer setEnabled:enable];
	[m_textCustomManufacturer setEnabled:enable];
	[m_btnGetProduct setEnabled:enable];
	[m_btnSetProduct setEnabled:enable];
	[m_textCustomProduct setEnabled:enable];
	[m_btnGetSerial setEnabled:enable];
	[m_btnSetSerial setEnabled:enable];
	[m_textCustomSerial setEnabled:enable];
}

// Get the combobox device selection
// If a device is selected, return TRUE and return the serial string
// Otherwise, return FALSE
- (BOOL)GetSelectedDevice:(NSString**)serial
{
	BOOL selected = FALSE;

	if ([m_comboDeviceList indexOfSelectedItem] != -1)
	{
		// Get current device selection
		*serial		= [m_comboDeviceList objectValueOfSelectedItem];
		selected	= TRUE;
	}

	return selected;
}

// Search for an HID device with a matching device serial string
// If the device was found return TRUE and return the device number
// in deviceNumber
// Otherwise return FALSE
- (BOOL)FindDevice:(NSString*)serial deviceNum:(DWORD*)deviceNum
{
	BOOL					found			= FALSE;
	DWORD					numDevices;
	HID_SMBUS_DEVICE_STR	deviceString;
	
	if (HidSmbus_GetNumDevices(&numDevices, VID, PID) == HID_SMBUS_SUCCESS)
	{
		DWORD i;
		for (i = 0; i < numDevices; i++)
		{
			if (HidSmbus_GetString(i, VID, PID, deviceString, HID_SMBUS_GET_SERIAL_STR) == HID_SMBUS_SUCCESS)
			{
				if ([serial compare:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding] options:NSCaseInsensitiveSearch] == NSOrderedSame)
				{
					found		= TRUE;
					*deviceNum	= i;
					break;
				}
			}
		}
	}
	
	return found;
}

// Connect to the device with the serial string selected
// in the device list
// - Connect to the device specified in the device list
// - Update the device information text boxes
// - Set Connect button caption
// - Enable/disable device combobox
- (BOOL)Connect
{
	BOOL		connected = FALSE;
	NSString*	serial;
	DWORD		deviceNum;
	
	// Get selected device serial string
	if ([self GetSelectedDevice:&serial])
	{
		// Find the selected device number
		if ([self FindDevice:serial deviceNum:&deviceNum])
		{
			HID_SMBUS_STATUS status = HidSmbus_Open(&m_hidSmbus, deviceNum, VID, PID);
			
			[self SetStatusText:[NSString stringWithFormat:@"HidSmbus_Open(): %s", HidSmbus_DecodeErrorStatus(status)]];
			
			// Attempt to open the device
			if (status == HID_SMBUS_SUCCESS)
			{
				connected = TRUE;
			}
			else
			{
        [self runModalInfoMessage:@"Connection Error" withMessage:[NSString stringWithFormat:@"Failed to connect to %@: %s", serial, HidSmbus_DecodeErrorStatus(status)]];
			}
		}
	}
	
	// Connected
	if (connected)
	{
		// Update Connect/Disconnect button caption
		[m_btnConnect setTitle:@"Disconnect"];
		
		// Update connection status text
		[self SetConnectionText:serial];
		
		// Disable the device combobox
		[m_comboDeviceList setEnabled:FALSE];
		
		// Enable all device controls when connected
		[self EnableDeviceCtrls:TRUE];
	}
	// Disconnected
	else
	{
		// Update Connect/Disconnect button caption
		[m_btnConnect setTitle:@"Connect"];
		
		// Update connection status text
		[self SetConnectionText:@"Not Connected"];
		
		// Enable the device combobox
		[m_comboDeviceList setEnabled:TRUE];
		
		// Disable all device controls when disconnected
		[self EnableDeviceCtrls:FALSE];
	}
	
	// Update the device information now that we are connected to it
	// (this will give us the part number and version if connected)
	[self UpdateDeviceInformation:TRUE];
	
	// Update all device settings for all tabs
	[self SetFromDevice];
	
	return connected;
}

// Disconnect from the currently connected device
// - Disconnect from the current device
// - Output any error messages
// - Display "Not Connected" in the status bar
// - Update the device information text boxes (clear text)
// - Set Connect button caption
// - Enable/disable device combobox
- (BOOL)Disconnect
{
	BOOL disconnected = FALSE;
	
	// Disconnect from the current device
	HID_SMBUS_STATUS status = HidSmbus_Close(m_hidSmbus);
	m_hidSmbus = NULL;
	
	[self SetStatusText:[NSString stringWithFormat:@"HidSmbus_Close(): %s", HidSmbus_DecodeErrorStatus(status)]];
	
	// Output an error message if the close failed
	if (status != HID_SMBUS_SUCCESS)
	{
    [self runModalInfoMessage: @"Connection Error" withMessage: [NSString stringWithFormat:@"Failed to disconnect: %s", HidSmbus_DecodeErrorStatus(status)]];
	}
	else
	{
		disconnected = TRUE;
	}
	
	// Update Connect/Disconnect button caption
	[m_btnConnect setTitle:@"Connect"];
	
	// Update connection status text
	[self SetConnectionText:@"Not Connected"];
	
	// Enable the device combobox
	[m_comboDeviceList setEnabled:TRUE];
	
	// Disable all device controls when disconnected
	[self EnableDeviceCtrls:FALSE];
	
	// Update the device information (clear)
	[self UpdateDeviceInformation:TRUE];
	
	return disconnected;
}

// Convert the clock output frequency using the clock output divider
// Clock Frequency = 48000000 / (2 x clkDiv)
// If clkDiv = 0, then Clock Frequency = 48000000
- (void)UpdateClkFrequency
{
	int clkDiv = [m_textClkDiv intValue];
	
	if (clkDiv == 0)
	{
		[m_textClkFreq setStringValue:@"48000000"];
	}
	else if (clkDiv >= 0 && clkDiv <= 255)
	{
		int clkFreq = 48000000 / (2 * clkDiv);
		
		[m_textClkFreq setStringValue:[NSString stringWithFormat:@"%d", clkFreq]];
	}
	else
	{
		[m_textClkFreq setStringValue:@"Invalid"];
	}
}
			 
// Update the GPIO combobox selections based on the direction, mode, and function bitmasks
- (void)SetPinDirection:(BYTE)direction withMode:(BYTE)mode withFunction:(BYTE) function
{
	int gpioSel[8] = {
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN,
		GPIO_INPUT_OPEN_DRAIN
	};

	// Determine GPIO.0 combobox selection
	if (function & HID_SMBUS_MASK_FUNCTION_GPIO_0_TXT)									gpioSel[0] = GPIO_SPECIAL_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_0) && (mode & HID_SMBUS_MASK_GPIO_0))		gpioSel[0] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_0) && !(mode & HID_SMBUS_MASK_GPIO_0))	gpioSel[0] = GPIO_OUTPUT_OPEN_DRAIN;

	// Determine GPIO.1 combobox selection
	if (function & HID_SMBUS_MASK_FUNCTION_GPIO_1_RXT)									gpioSel[1] = GPIO_SPECIAL_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_1) && (mode & HID_SMBUS_MASK_GPIO_1))		gpioSel[1] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_1) && !(mode & HID_SMBUS_MASK_GPIO_1))	gpioSel[1] = GPIO_OUTPUT_OPEN_DRAIN;

	// Determine GPIO.2 combobox selection
	if ((direction & HID_SMBUS_MASK_GPIO_2) && (mode & HID_SMBUS_MASK_GPIO_2))			gpioSel[2] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_2) && !(mode & HID_SMBUS_MASK_GPIO_2))	gpioSel[2] = GPIO_OUTPUT_OPEN_DRAIN;

	// Determine GPIO.3 combobox selection
	if ((direction & HID_SMBUS_MASK_GPIO_3) && (mode & HID_SMBUS_MASK_GPIO_3))			gpioSel[3] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_3) && !(mode & HID_SMBUS_MASK_GPIO_3))	gpioSel[3] = GPIO_OUTPUT_OPEN_DRAIN;
	
	// Determine GPIO.4 combobox selection
	if ((direction & HID_SMBUS_MASK_GPIO_4) && (mode & HID_SMBUS_MASK_GPIO_4))			gpioSel[4] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_4) && !(mode & HID_SMBUS_MASK_GPIO_4))	gpioSel[4] = GPIO_OUTPUT_OPEN_DRAIN;
	
	// Determine GPIO.5 combobox selection
	if ((direction & HID_SMBUS_MASK_GPIO_5) && (mode & HID_SMBUS_MASK_GPIO_5))			gpioSel[5] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_5) && !(mode & HID_SMBUS_MASK_GPIO_5))	gpioSel[5] = GPIO_OUTPUT_OPEN_DRAIN;
	
	// Determine GPIO.6 combobox selection
	if ((direction & HID_SMBUS_MASK_GPIO_6) && (mode & HID_SMBUS_MASK_GPIO_6))			gpioSel[6] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_6) && !(mode & HID_SMBUS_MASK_GPIO_6))	gpioSel[6] = GPIO_OUTPUT_OPEN_DRAIN;

	// Determine GPIO.7 combobox selection
	if (function & HID_SMBUS_MASK_FUNCTION_GPIO_7_CLK)									gpioSel[7] = GPIO_SPECIAL_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_7) && (mode & HID_SMBUS_MASK_GPIO_7))		gpioSel[7] = GPIO_OUTPUT_PUSH_PULL;
	else if ((direction & HID_SMBUS_MASK_GPIO_7) && !(mode & HID_SMBUS_MASK_GPIO_7))	gpioSel[7] = GPIO_OUTPUT_OPEN_DRAIN;

	// Set GPIO combobox selections
	[m_comboGpio0 selectItemAtIndex:gpioSel[0]];
	[m_comboGpio1 selectItemAtIndex:gpioSel[1]];
	[m_comboGpio2 selectItemAtIndex:gpioSel[2]];
	[m_comboGpio3 selectItemAtIndex:gpioSel[3]];
	[m_comboGpio4 selectItemAtIndex:gpioSel[4]];
	[m_comboGpio5 selectItemAtIndex:gpioSel[5]];
	[m_comboGpio6 selectItemAtIndex:gpioSel[6]];
	[m_comboGpio7 selectItemAtIndex:gpioSel[7]];
}

// Return the direction, mode, and function bitmasks based on the GPIO combobox selections
- (void)GetPinDirection:(BYTE*)direction getMode:(BYTE*)mode getFunction:(BYTE*) function
{
	int gpioSel[8];
	int i;
	
	// Get combobox selections
	gpioSel[0] = (int)[m_comboGpio0 indexOfSelectedItem];
	gpioSel[1] = (int)[m_comboGpio1 indexOfSelectedItem];
	gpioSel[2] = (int)[m_comboGpio2 indexOfSelectedItem];
	gpioSel[3] = (int)[m_comboGpio3 indexOfSelectedItem];
	gpioSel[4] = (int)[m_comboGpio4 indexOfSelectedItem];
	gpioSel[5] = (int)[m_comboGpio5 indexOfSelectedItem];
	gpioSel[6] = (int)[m_comboGpio6 indexOfSelectedItem];
	gpioSel[7] = (int)[m_comboGpio7 indexOfSelectedItem];
	
	// Initialize bitmasks
	*direction	= 0x00;		// All pins input
	*mode		= 0x00;		// All pins open drain
	*function	= 0x00;		// All pins in GPIO mode
	
	// Set direction and mode bits for each GPIO pin
	for (i = 0; i < 8; i++)
	{
		// Direction is output
		if (gpioSel[i] >= GPIO_OUTPUT_START)
		{
			*direction |= 1 << i;
		}
		// Mode is push pull
		if (gpioSel[i] >= GPIO_PUSH_PULL_START)
		{
			*mode |= 1 << i;
		}
	}
	
	// Set function bits for GPIO.0, GPIO.1, and GPIO.7
	if (gpioSel[0] == GPIO_SPECIAL_PUSH_PULL)
	{
		*function |= HID_SMBUS_MASK_FUNCTION_GPIO_0_TXT;
	}
	if (gpioSel[1] == GPIO_SPECIAL_PUSH_PULL)
	{
		*function |= HID_SMBUS_MASK_FUNCTION_GPIO_1_RXT;
	}
	if (gpioSel[7] == GPIO_SPECIAL_PUSH_PULL)
	{
		*function |= HID_SMBUS_MASK_FUNCTION_GPIO_7_CLK;
	}
}

// Update the GPIO pin checkbox states to reflect the
// latch value.  A bit value of 1 indicates that the
// pin is logic high, set the pin checkbox to checked.
- (void)SetLatchValue:(BYTE)latchValue
{
	int i;
	int latchCheckState[8] = {
		NSOffState,
		NSOffState,
		NSOffState,
		NSOffState,
		NSOffState,
		NSOffState,
		NSOffState,
		NSOffState
	};

	// Determine latch pin value for each of the
	// GPIO pins
	for (i = 0; i < 8; i++)
	{
		// A latch bit value of 1 means logic high
		// Check the GPIO pin checkbox
		if (latchValue & 0x01)
		{
			latchCheckState[i] = NSOnState;
		}
		
		// Shift to the next bit
		latchValue >>= 1;
	}
	
	// Update all GPIO pin checkboxes
	[m_btnGpio0 setState:latchCheckState[0]];
	[m_btnGpio1 setState:latchCheckState[1]];
	[m_btnGpio2 setState:latchCheckState[2]];
	[m_btnGpio3 setState:latchCheckState[3]];
	[m_btnGpio4 setState:latchCheckState[4]];
	[m_btnGpio5 setState:latchCheckState[5]];
	[m_btnGpio6 setState:latchCheckState[6]];
	[m_btnGpio7 setState:latchCheckState[7]];
}

// Return the GPIO pin latch values and mask
// If the pin checkbox is checked, then return
// a latch bit value of 1 (logic high).
// If the pin checkbox is unchecked, then return
// a latch bit value of 0 (logic low).
// If the pin checkbox is indeterminate, then
// clear the corresponding bit in the mask bitmask.
// This means that the GPIO pin will be left unchanged.
- (BYTE)GetLatchValue:(BYTE*)mask
{
	BYTE latchValue = 0x00;
	
	// Initially all pins will be written
	*mask = 0xFF;
	
	// Set GPIO latch bit value and mask bit value for GPIO.0
	if ([m_btnGpio0 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_0;
	else if ([m_btnGpio0 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_0;
	
	// Set GPIO latch bit value and mask bit value for GPIO.1
	if ([m_btnGpio1 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_1;
	else if ([m_btnGpio1 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_1;
	
	// Set GPIO latch bit value and mask bit value for GPIO.2
	if ([m_btnGpio2 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_2;
	else if ([m_btnGpio2 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_2;
	
	// Set GPIO latch bit value and mask bit value for GPIO.3
	if ([m_btnGpio3 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_3;
	else if ([m_btnGpio3 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_3;
	
	// Set GPIO latch bit value and mask bit value for GPIO.4
	if ([m_btnGpio4 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_4;
	else if ([m_btnGpio4 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_4;
	
	// Set GPIO latch bit value and mask bit value for GPIO.5
	if ([m_btnGpio5 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_5;
	else if ([m_btnGpio5 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_5;
	
	// Set GPIO latch bit value and mask bit value for GPIO.6
	if ([m_btnGpio6 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_6;
	else if ([m_btnGpio6 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_6;

	// Set GPIO latch bit value and mask bit value for GPIO.7
	if ([m_btnGpio7 state] == NSMixedState)		*mask &= ~HID_SMBUS_MASK_GPIO_7;
	else if ([m_btnGpio7 state] == NSOnState)	latchValue |= HID_SMBUS_MASK_GPIO_7;
	
	return latchValue;
}

// Output status to status bar
// And play an audible alert if the status is not HID_SMBUS_SUCCESS
- (void)OutputStatus:(NSString*)functionName withStatus:(HID_SMBUS_STATUS)status
{
	// Update status bar text
	[self SetStatusText:[NSString stringWithFormat:@"%@(): %s", functionName, HidSmbus_DecodeErrorStatus(status)]];
	
	// Alert user if the function failed
	if (status != HID_SMBUS_SUCCESS)
	{
		NSBeep();
	}
}

// Set default control values
- (void)SetDefaults
{
	// Set default configuration tab values
	[m_textBitRate setIntValue:100000];
	[m_textMasterSlaveAddress setStringValue:@"02"];
	[m_btnAutoRespond setState:0];
	[m_textWriteTimeout setIntValue:0];
	[m_textReadTimeout setIntValue:0];
	[m_textTransferRetries setIntValue:0];
	[m_btnSclLowTimeout setState:0];
	[m_textResponseTimeout setIntValue:1000];
	
	// Set default data transfer tab values
	[m_textReadAddress setStringValue:@"F0"];
	[m_textReadBytesToRead setIntValue:1];
	[m_textAddressedAddress setStringValue:@"F0"];
	[m_textTargetAddressSize setIntValue:2];
	[m_textTargetAddress setStringValue:@"0000"];
	[m_textAddressedBytesToRead setIntValue:1];
	[m_textForceBytesToRead setIntValue:1];
	[m_textReceivedData setStringValue:@""];
	[m_textDataToWrite setStringValue:@""];
	[m_textWriteAddress setStringValue:@"F0"];
	
	// Set default pin configuration tab values
	[m_textClkDiv setIntValue:0];
	
	// Set default customization tab values
	[m_textCustomVid setStringValue:@"10C4"];
	[m_textCustomPid setStringValue:@"EA90"];
	[m_textCustomPower setIntValue:100];
	[m_mtxCustomPowerMode selectCellAtRow:0 column:0];
	[m_textCustomReleaseMsb setIntValue:1];
	[m_textCustomReleaseLsb setIntValue:0];
	[m_textCustomManufacturer setStringValue:@"Silicon Laboratories"];
	[m_textCustomProduct setStringValue:@"CP2112 HID USB-to-SMBus Bridge"];
	[m_textCustomSerial setStringValue:@"0001"];
}

// Set control values by getting the device configuration
- (void)SetFromDevice
{
	// Set default control values
	[self SetDefaults];
	
	// Update control values
	[self GetSmbusConfig:TRUE];
	[self GetTimeouts:TRUE];
	[self GetGpioConfig:TRUE];
	[self ReadLatch:TRUE];
	[self GetUsbConfig:TRUE];
	[self GetLock:TRUE];
	[self GetManufacturer:TRUE];
	[self GetProduct:TRUE];
	[self GetSerial:TRUE];
}

- (void)runModalInfoMessage:(NSString *)title withMessage:(NSString *)message
{
  NSAlert * alert = [[NSAlert alloc] init];
  alert.icon = [NSImage imageNamed:NSImageNameInfo];
  alert.messageText = title;
  alert.informativeText = message;
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
  [alert release];
}

@end
