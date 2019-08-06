////////////////////////////////////////////////////////////////////////////////
// Controller.m
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

#import "Controller.h"
#include "LibraryBridge.h"

/////////////////////////////////////////////////////////////////////////////
// Static Global Variables
/////////////////////////////////////////////////////////////////////////////

typedef enum
{
    CBS_Default,        // Tri-state = false, Read-only = false
    CBS_ReadOnly,       // Tri-state = false, Read-only = true
    CBS_Indeterminate   // Tri-state = true,  Read-only = true
} CHECKBOX_STYLE;

static const char* CP2110_PinCaptions[] =
{
	//    Pin Modes:
	//    Input     Output_OD Output_PP Function1    Function2
	//    -----     --------- --------- ---------    ---------
	/*0*/ "GPIO.0", "GPIO.0", "GPIO.0", "CLK",       "", 
	/*1*/ "GPIO.1", "GPIO.1", "GPIO.1", "RTS",       "", 
	/*2*/ "GPIO.2", "GPIO.2", "GPIO.2", "CTS",       "", 
	/*3*/ "GPIO.3", "GPIO.3", "GPIO.3", "RS485",     "", 
	/*4*/ "GPIO.4", "GPIO.4", "GPIO.4", "TX Toggle", "", 
	/*5*/ "GPIO.5", "GPIO.5", "GPIO.5", "RX Toggle", "", 
	/*6*/ "GPIO.6", "GPIO.6", "GPIO.6", "",          "", 
	/*7*/ "GPIO.7", "GPIO.7", "GPIO.7", "",          "", 
	/*8*/ "GPIO.8", "GPIO.8", "GPIO.8", "",          "", 
	/*9*/ "GPIO.9", "GPIO.9", "GPIO.9", "",          "", 
};

static const char* CP2110_PinDirections[] =
{
	//    Pin Modes:
	//    Input          Output_OD          Output_PP          Function1          Function2
	//    -----          ---------          ---------          ---------          ---------
	/*0*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "", 
	/*1*/ "(Input)", "(Output OD)", "(Output PP)", "(Output OD)", "", 
	/*2*/ "(Input)", "(Output OD)", "(Output PP)", "(Input)",     "", 
	/*3*/ "(Input)", "(Output OD)", "(Output PP)", "(Output OD)", "", 
	/*4*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "", 
	/*5*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "", 
	/*6*/ "(Input)", "(Output OD)", "(Output PP)", "",            "", 
	/*7*/ "(Input)", "(Output OD)", "(Output PP)", "",            "", 
	/*8*/ "(Input)", "(Output OD)", "(Output PP)", "",            "", 
	/*9*/ "(Input)", "(Output OD)", "(Output PP)", "",            "", 
};

static CHECKBOX_STYLE CP2110_PinStyle[] =
{
	//    Pin Modes:
	//    Input         Output_OD    Output_PP    Function1          Function2
	//    -----         ---------    ---------    ---------          ---------
	/*0*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*1*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*2*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*3*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*4*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*5*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*6*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*7*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*8*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*9*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
};

static const char* CP2114_PinCaptions[] =
{
	//    Pin Modes:
	//    Input          Output_OD      Output_PP      Function1               Function2
	//    -----          ---------      ---------      ---------               ---------
	/*0*/ "GPIO.0",  "GPIO.0",  "GPIO.0",  "Record Mute",      "", 
	/*1*/ "GPIO.1",  "GPIO.1",  "GPIO.1",  "Play Mute",        "", 
	/*2*/ "GPIO.2",  "GPIO.2",  "GPIO.2",  "Volume Down",      "", 
	/*3*/ "GPIO.3",  "GPIO.3",  "GPIO.3",  "Volume Up",        "", 
	/*4*/ "GPIO.4",  "GPIO.4",  "GPIO.4",  "LED1 Record Mute", "", 
	/*5*/ "GPIO.5",  "GPIO.5",  "GPIO.5",  "TX Toggle",        "DAC S0", 
	/*6*/ "GPIO.6",  "GPIO.6",  "GPIO.6",  "RX Toggle",        "DAC S1", 
	/*7*/ "GPIO.7",  "GPIO.7",  "GPIO.7",  "RTS",              "DAC S2", 
	/*8*/ "GPIO.8",  "GPIO.8",  "GPIO.8",  "CTS",              "DAC S3", 
	/*9*/ "GPIO.9",  "GPIO.9",  "GPIO.9",  "CLK",              "", 
	/*10*/"GPIO.10", "GPIO.10", "GPIO.10", "TX",               "TX", 
	/*11*/"GPIO.11", "GPIO.11", "GPIO.11", "RX",               "N/A", 
};

static const char* CP2114_PinDirections[] =
{
	//    Pin Modes:
	//    Input          Output_OD          Output_PP          Function1          Function2
	//    -----          ---------          ---------          ---------          ---------
	/*0*/ "(Input)", "(Output OD)", "(Output PP)", "(Input)",     "", 
	/*1*/ "(Input)", "(Output OD)", "(Output PP)", "(Input)",     "", 
	/*2*/ "(Input)", "(Output OD)", "(Output PP)", "(Input)",     "", 
	/*3*/ "(Input)", "(Output OD)", "(Output PP)", "(Input)",     "", 
	/*4*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "", 
	/*5*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "(Input)", 
	/*6*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "(Input)", 
	/*7*/ "(Input)", "(Output OD)", "(Output PP)", "(Output OD)", "(Input)", 
	/*8*/ "(Input)", "(Output OD)", "(Output PP)", "(Input)",     "(Input)", 
	/*9*/ "(Input)", "(Output OD)", "(Output PP)", "(Output PP)", "", 
	/*10*/"(Input)", "(Output OD)", "(Output PP)", "(Output OD)", "(Output PP)", 
	/*11*/"(Input)", "(Output OD)", "(Output PP)", "(Input)",     "", 
};

static CHECKBOX_STYLE CP2114_PinStyle[] =
{
	//    Pin Modes:
	//    Input         Output_OD    Output_PP    Function1          Function2
	//    -----         ---------    ---------    ---------          ---------
	/*0*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_ReadOnly,      CBS_Indeterminate, 
	/*1*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_ReadOnly,      CBS_Indeterminate, 
	/*2*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_ReadOnly,      CBS_Indeterminate, 
	/*3*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_ReadOnly,      CBS_Indeterminate, 
	/*4*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_ReadOnly,      CBS_Indeterminate, 
	/*5*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*6*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*7*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*8*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*9*/ CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*10*/CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
	/*11*/CBS_ReadOnly, CBS_Default, CBS_Default, CBS_Indeterminate, CBS_Indeterminate, 
};

////////////////////////////////////////////////////////////////////////////////
// Controller Class
////////////////////////////////////////////////////////////////////////////////

@implementation Controller

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)OnConnect:(id)sender
{
	// Connecting
	if ([buttonConnect state] == NSOnState)
	{
		[self Connect];
	}
	// Disconnecting
	else
	{
		[self Disconnect];
	}
}

// Update GPIO checkboes to display the current value of the latch
- (IBAction)OnGet:(id)sender
{
	[self GetLatch:FALSE];
}

  // Part Numbers
#define HID_UART_PART_CP2110						0x0A
#define HID_UART_PART_CP2114						0x0E

  // Pin Bitmasks
#define CP2110_MASK_GPIO_0_CLK				        0x0001
#define CP2110_MASK_GPIO_1_RTS				        0x0002
#define CP2110_MASK_GPIO_2_CTS				        0x0004
#define CP2110_MASK_GPIO_3_RS485			        0x0008
#define CP2110_MASK_TX						        0x0010
#define CP2110_MASK_RX						        0x0020
#define CP2110_MASK_GPIO_4_TX_TOGGLE		        0x0040
#define CP2110_MASK_GPIO_5_RX_TOGGLE		        0x0080
#define CP2110_MASK_SUSPEND_BAR			            0x0100
  // NA
#define CP2110_MASK_GPIO_6					        0x0400
#define CP2110_MASK_GPIO_7					        0x0800
#define CP2110_MASK_GPIO_8					        0x1000
#define CP2110_MASK_GPIO_9					        0x2000
#define CP2110_MASK_SUSPEND				            0x4000

  // Pin Bitmasks
#define CP2114_MASK_GPIO_0					        0x0001
#define CP2114_MASK_GPIO_1					        0x0002
#define CP2114_MASK_GPIO_2					        0x0004
#define CP2114_MASK_GPIO_3					        0x0008
#define CP2114_MASK_GPIO_4					        0x0010
#define CP2114_MASK_GPIO_5					        0x0020
#define CP2114_MASK_GPIO_6					        0x0040
#define CP2114_MASK_GPIO_7					        0x0080
#define CP2114_MASK_GPIO_8					        0x0100
#define CP2114_MASK_GPIO_9					        0x0200
#define CP2114_MASK_TX						        0x0400
#define CP2114_MASK_RX						        0x0800
#define CP2114_MASK_SUSPEND				            0x1000
#define CP2114_MASK_SUSPEND_BAR			            0x2000


  // Pin Config Mode Array Indices
#define CP2110_INDEX_GPIO_0_CLK			            0
#define CP2110_INDEX_GPIO_1_RTS			            1
#define CP2110_INDEX_GPIO_2_CTS			            2
#define CP2110_INDEX_GPIO_3_RS485			        3
#define CP2110_INDEX_GPIO_4_TX_TOGGLE		        4
#define CP2110_INDEX_GPIO_5_RX_TOGGLE		        5
#define CP2110_INDEX_GPIO_6				            6
#define CP2110_INDEX_GPIO_7				            7
#define CP2110_INDEX_GPIO_8				            8
#define CP2110_INDEX_GPIO_9				            9
#define CP2110_INDEX_TX					            10
#define CP2110_INDEX_SUSPEND				        11
#define CP2110_INDEX_SUSPEND_BAR			        12


  // Pin Config Modes
#define HID_UART_GPIO_MODE_INPUT					0x00
#define HID_UART_GPIO_MODE_OUTPUT_OD				0x01
#define HID_UART_GPIO_MODE_OUTPUT_PP				0x02
#define HID_UART_GPIO_MODE_FUNCTION1				0x03
#define HID_UART_GPIO_MODE_FUNCTION2				0x04


// Set latch values based on dialog selections
- (IBAction)OnSet:(id)sender
{
	unsigned short			latchValue	= 0x0000;
	unsigned short			latchMask	= 0xFFFF;
  int opened;
	
	// Check if the device is opened
	if (HidUartIsOpened(hidUart, &opened) == 0 && opened)
	{
		if (partNumber == HID_UART_PART_CP2110)
		{
			// Set latch values based on dialog selections
			if ([checkGpio0 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_0_CLK;
			if ([checkGpio1 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_1_RTS;
			if ([checkGpio2 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_2_CTS;
			if ([checkGpio3 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_3_RS485;
			if ([checkGpio4 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_4_TX_TOGGLE;
			if ([checkGpio5 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_5_RX_TOGGLE;
			if ([checkGpio6 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_6;
			if ([checkGpio7 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_7;
			if ([checkGpio8 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_8;
			if ([checkGpio9 state] == NSOnState)	latchValue |= CP2110_MASK_GPIO_9;
		}
		else if (partNumber == HID_UART_PART_CP2114)
		{
			// Set latch values based on dialog selections
			if ([checkGpio0 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_0;
			if ([checkGpio1 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_1;
			if ([checkGpio2 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_2;
			if ([checkGpio3 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_3;
			if ([checkGpio4 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_4;
			if ([checkGpio5 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_5;
			if ([checkGpio6 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_6;
			if ([checkGpio7 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_7;
			if ([checkGpio8 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_8;
			if ([checkGpio9 state] == NSOnState)	latchValue |= CP2114_MASK_GPIO_9;
			if ([checkGpio10 state] == NSOnState)	latchValue |= CP2114_MASK_TX;
			if ([checkGpio11 state] == NSOnState)	latchValue |= CP2114_MASK_RX;
		}

		// Set latch values
		int status = HidUartWriteLatch(hidUart, latchValue, latchMask);

		if (status != 0)
		{
			// Notify the user that an error occurred
			NSRunAlertPanel(@"Failed to write latch values", @"Failed to write latch values: %@", [NSString stringWithUTF8String:GetHidUartStatusStr(status)], @"OK", nil, nil);
		}
	}

}

// Transmit entered text using ASCII or hex format
- (IBAction)OnTransmit:(id)sender
{

	int opened;
	
	// Check if the device is opened
	if (HidUartIsOpened(hidUart, &opened) == 0 && opened)
	{	
		NSString* transmitStr;
		
		// Get the transmit edit text
		transmitStr = [textTransmit stringValue];
		
		// String is empty
		if ([transmitStr length] == 0)
		{
			// Do nothing
			return;
		}
		
		// Interpret edit text as ASCII
		if ([radioAscii state] == NSOnState)
		{
			int		status;
			unsigned long				numBytesWritten = 0;
			unsigned long				numBytesToWrite = [transmitStr length];
			unsigned char *				buffer			= (unsigned char *)malloc(numBytesToWrite);
			int				i;
			
			// Copy ASCII values to the new array
			for (i = 0; i < numBytesToWrite; i++)
			{
				// Use LSB of the 2-byte unicode value
				buffer[i] = (unsigned char)[transmitStr characterAtIndex:i];
			}
			
			// Send the UART data to the device to transmit
			status = HidUartWrite(hidUart, buffer, numBytesToWrite, &numBytesWritten);
			
			// Notify the user that an error occurred
			if (status != 0)
			{
				NSRunAlertPanel(@"Failed to transmit", @"Failed to transmit: %@", [NSString stringWithUTF8String:GetHidUartStatusStr(status)], @"OK", nil, nil);
			}
			
			free(buffer);
		}
		// Interpret edit text as hex
		else if ([radioHex state] == NSOnState)
		{
			// Remove invalid hex characters
			transmitStr = [self CleanHexString:transmitStr];
			
			if ([transmitStr length] > 0)
			{
				int		status;
				unsigned long				numBytesWritten = 0;
				unsigned long				numBytesToWrite = [transmitStr length]/2;
				unsigned char *				buffer			= (unsigned char *)malloc(numBytesToWrite);
				NSMutableString*	outputStr		= [NSMutableString stringWithCapacity:255];
				int					i;
				unsigned			value;
				
				// Convert each hex byte string to a BYTE value
				for (i = 0; i < numBytesToWrite; i++)
				{
					// Extract each 2-character hex string
					NSScanner* hexVal = [NSScanner scannerWithString:[transmitStr substringWithRange:NSMakeRange(i*2, 2)]];
					
					// Convert the hex byte to a numeric value
					[hexVal scanHexInt:&value];
					
					buffer[i] = value;
				}
				
				// Copy clean hex string
				[outputStr setString:transmitStr];
				
				// Separate each hex pair with a space
				for (i = [outputStr length] - 2; i >= 2; i -= 2)
				{
					[outputStr insertString:@" " atIndex:i];
				}
				
				// Set transmit window text to the cleaned up string
				[textTransmit setStringValue:outputStr];
				
				// Send the UART data to the device to transmit
				status = HidUartWrite(hidUart, buffer, numBytesToWrite, &numBytesWritten);
				
				// Notify the user that an error occurred
				if (status != 0)
				{
					NSRunAlertPanel(@"Failed to transmit", @"Failed to transmit: %@", [NSString stringWithUTF8String:GetHidUartStatusStr(status)], @"OK", nil, nil);
				}
				
				free(buffer);
			}
		}
	}

}

// Clear the receive window
- (IBAction)OnClear:(id)sender
{
	[textReceive setString:@""];
}

// Periodically call read and append to the receive window
- (void)OnTimer:(NSTimer*)timer
{
	[self ReceiveData];
}

// Called just before the window closes
- (void)windowWillClose:(NSNotification*)notification
{
	// Disconnect from the device
	if ([buttonConnect state] == NSOnState)
	{
		// Stop the read timer
		[self StopReadTimer];
		
		// Close the device
		HidUartClose(hidUart);
	}	
}

// Called just before the device list combo box is popped up
- (void)comboBoxWillPopUp:(NSNotification*)notification
{
	// Refresh the device list and reselect the
	// previous selection if possible
	[self UpdateDeviceList];
}

// Called just before the device list combo box is closed
- (void)comboBoxWillDismiss:(NSNotification*)notification
{
	// Refresh the device list and reselect the
	// previous selection if possible
	[self UpdateDeviceList];	
}

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Utilities
////////////////////////////////////////////////////////////////////////////////



// Remove whitespace and invalid characters from a string
// and return
- (NSString*)CleanHexString:(NSString*)editStr
{
	NSMutableString*	cleanStr	= [NSMutableString stringWithCapacity:255];
	NSMutableString*	hexStr		= [NSMutableString stringWithCapacity:255];
	
	int i;
	
	[cleanStr setString:editStr];
	
	// Remove spaces
	[cleanStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [cleanStr length])];

	// Remove commas
	[cleanStr replaceOccurrencesOfString:@"," withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [cleanStr length])];

	// Only parse text including valid hex characters
	// (stop at the first invalid character)
	for (i = 0; i < [cleanStr length]; i++)
	{
		char letter = [cleanStr characterAtIndex:i];
		
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

////////////////////////////////////////////////////////////////////////////////
// Controller Class - Methods
////////////////////////////////////////////////////////////////////////////////

- (NSButton*)GetButton:(int)i
{
	NSButton* button = nil;
	
	switch (i)
	{
		case 0: button = checkGpio0;	break;
		case 1: button = checkGpio1;	break;
		case 2: button = checkGpio2;	break;
		case 3: button = checkGpio3;	break;
		case 4: button = checkGpio4;	break;
		case 5: button = checkGpio5;	break;
		case 6: button = checkGpio6;	break;
		case 7: button = checkGpio7;	break;
		case 8: button = checkGpio8;	break;
		case 9: button = checkGpio9;	break;
		case 10: button = checkGpio10;	break;
		case 11: button = checkGpio11;	break;
	}
	
	return button;
}

- (NSTextField*)GetDirection:(int)i
{
	NSTextField* text = nil;
	
	switch (i)
	{
		case 0: text = textGpio0;	break;
		case 1: text = textGpio1;	break;
		case 2: text = textGpio2;	break;
		case 3: text = textGpio3;	break;
		case 4: text = textGpio4;	break;
		case 5: text = textGpio5;	break;
		case 6: text = textGpio6;	break;
		case 7: text = textGpio7;	break;
		case 8: text = textGpio8;	break;
		case 9: text = textGpio9;	break;
		case 10: text = textGpio10;	break;
		case 11: text = textGpio11;	break;
	}
	
	return text;
}

// Set status bar pane text
- (void)SetStatusText:(NSString*)statusStr
{
	[textStatusBar setStringValue:statusStr];
}

- (void)awakeFromNib
{
	[self InitializeWindow];
}

- (void)InitializeWindow
{
	[self InitStatusBar];
	[self InitUartSettings];
	[self InitTransferSettings];
	[self InitHexEditCtrl];
	[self InitLibraryVersion];
	[textReceive setString:@""];
	
	[self UpdateDeviceList];
}

// Initialize the status bar
// - Set default status bar text to "Not Connected"
- (void)InitStatusBar
{
	[self SetStatusText:@"Not Connected"];
}

// Set the default UART control values
// - Set default baud rate to 115200
// - Set default UART combo settings to 8N1 (No flow control)
- (void)InitUartSettings
{
	// Set defafult baud rate
	[textBaudRate setIntValue:115200];
	
	// Set default UART settings
	[comboDataBits selectItemWithObjectValue:@"8"];
	[comboParity selectItemWithObjectValue:@"N"];
	[comboStopBits selectItemWithObjectValue:@"1"];
	[comboFlowControl selectItemWithObjectValue:@"No"];
}

// Set the default transfer data settings
// - Set transmit format to ASCII
- (void)InitTransferSettings
{
	// Select ASCII format
	[radioAscii setState:NSOnState];
	[radioHex setState:NSOffState];
}

- (void)InitHexEditCtrl
{
	[textReceive setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
}

- (void)InitLibraryVersion
{
	int				major;
	int				minor;
	int				release;
	NSMutableString*	libStr		= [[NSMutableString alloc] init];
	
	if (GetHidUartLibraryVersion(&major, &minor, &release) == 0)
	{
		[libStr appendFormat:@"Library Version: %u.%u (%s)", major, minor, (release) ? "Release" : "Debug"];
	}
	
	if (GetHIDDeviceLibraryVersion(&major, &minor, &release) == 0)
	{
		[libStr appendFormat:@"\tHID Library Version: %u.%u (%s)", major, minor, (release) ? "Release" : "Debug"];
	}
	
	[textLibrary setStringValue:libStr];
}

  // Product String Types
#define HID_UART_GET_VID_STR						0x01
#define HID_UART_GET_PID_STR						0x02
#define HID_UART_GET_PATH_STR						0x03
#define HID_UART_GET_SERIAL_STR						0x04
#define HID_UART_GET_MANUFACTURER_STR				0x05
#define HID_UART_GET_PRODUCT_STR					0x06// Product String Types
#define HID_UART_GET_VID_STR						0x01
#define HID_UART_GET_PID_STR						0x02
#define HID_UART_GET_PATH_STR						0x03
#define HID_UART_GET_SERIAL_STR						0x04
#define HID_UART_GET_MANUFACTURER_STR				0x05
#define HID_UART_GET_PRODUCT_STR					0x06

// Populate the device list combo box with connected device serial strings
// - Save previous device serial string selection
// - Fill the device list with connected device serial strings
// - Restore previous device selection
- (void)UpdateDeviceList
{
	int					numDevices;
	int					i;
	char		str[512];
	NSString*				selText;
	
	// Get current device selection
	selText = [comboDeviceList objectValueOfSelectedItem];
	
	// Reset the device list
	[comboDeviceList removeAllItems];
	[comboDeviceList setStringValue:@""];
	
	HidUartGetNumDevices(&numDevices, VID, PID);
	
	// Display connected HID UART device serial strings in the combo box
	for (i = 0; i < numDevices; i++)
	{
		if (HidUartGetString(i, 0, 0, str, HID_UART_GET_SERIAL_STR) == 0)
		{
			[comboDeviceList addItemWithObjectValue:[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
		}
	}
	
	// Reselect the old device
	[comboDeviceList selectItemWithObjectValue:selText];
	
	// If no device is selected, then select the first available
	// device
	if ([comboDeviceList indexOfSelectedItem] == -1 &&
		[comboDeviceList numberOfItems] > 0)
	{
		[comboDeviceList selectItemAtIndex:0];
	}
}

// Enable/disable the device settings controls
// - Device list
// - Update button
// - Baud rate edit box
// - Data bits, parity, stop bits, and flow control combo boxes
- (void)EnableSettingsCtrls:(BOOL)enable
{
	// Enable/disable the controls
	[comboDeviceList setEnabled:enable];
	[buttonUpdate setEnabled:enable];
	[textBaudRate setEnabled:enable];
	[comboDataBits setEnabled:enable];
	[comboParity setEnabled:enable];
	[comboStopBits setEnabled:enable];
	[comboFlowControl setEnabled:enable];
}

// Return the UART control settings
// - Get UART setting combo selections
// - Get device list serial string
- (BOOL)GetConnectionSettings:(NSString**)serial baud:(int *)baudRate data:(int *)data parity:(int *)parity stop:(int*)stop flow:(int*)flowControl
{
	*serial			= [comboDeviceList objectValueOfSelectedItem];
	*baudRate		= [textBaudRate intValue];
	*data			= [comboDataBits indexOfSelectedItem];
	*parity			= [comboParity indexOfSelectedItem];
	*stop			= [comboStopBits indexOfSelectedItem];
	*flowControl	= [comboFlowControl indexOfSelectedItem];
	
	if (*serial == nil)
	{
		return NO;
	}
	else
	{
		return YES;
	}
}

// Connect to the device with the serial string selected
// in the device list using the device settings specified
// on the dialog
// - Read settings from the dialog controls
// - Connect to the device specified in the device list
// - Disable device settings controls
// - Update the device information text boxes
// - Set Connect checkbox/button caption and pressed state
// - Start the read timer
- (BOOL)Connect
{
	NSString* serial;
	int baudRate;
	int dataBits;
	int parity;
	int stopBits;
	int flowControl;
	
	// Retrieve UART settings from the dialog
	if ([self GetConnectionSettings:&serial baud:&baudRate data:&dataBits parity:&parity stop:&stopBits flow:&flowControl])
	{
		// Connect to the device and configure the UART
		if ([self ConnectTo:serial baud:baudRate data:dataBits parity:parity stop:stopBits flow:flowControl])
		{
			// Disable the device list, update button, and UART settings
			[self EnableSettingsCtrls:FALSE];
			
			// Get pin configuration and set checkbox properties
			// accordingly
			[self UpdateGpioButtonProperties];

			// Update the latch values
			[self GetLatch:TRUE];
			
			// Update device information strings
			[self UpdateDeviceInformation];
			
			// Check the connect checkbox/button
			[buttonConnect setState:NSOnState];
			
			// Next button press should disconnect
			[buttonConnect setTitle:@"Disconnect"];
			
			// Start read timer to display received data in the receive window
			[self StartReadTimer];
			
			return TRUE;
		}
	}

	// Connect failed, uncheck the button
	[buttonConnect setState:NSOffState];

	// Next button press should connect
	[buttonConnect setTitle:@"Connect"];

	return FALSE;
}

// Connect to the device with the specified serial string and configure the UART
// - Search for device with matching serial
// - Open matching device
// - Configure device UART settings
// - Output any error messages
// - Display "Not Connected" or "Connected to..." in the status bar
- (BOOL)ConnectTo:(NSString*)serial baud:(int)baudRate data:(int)dataBits parity:(int)parity stop:(int)stopBits flow:(int)flowControl
{
	int			status		= -1;
	int					numDevices	= 0;
	int					i;
	char		deviceString[512];
	
	if (HidUartGetNumDevices(&numDevices, VID, PID) == 0)
	{
		for (i = 0; i < numDevices; i++)
		{
			// Search through all HID devices for a matching serial string
			if (HidUartGetString(i, VID, PID, deviceString, HID_UART_GET_SERIAL_STR) == 0)
			{
				// Found a matching device
				if ([serial isEqualToString:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]])
				{
					// Open the device
					status = HidUartOpen(&hidUart, i, VID, PID);
					break;
				}
			}
		}
	}
	
	// Found and opened the device
	if (status == 0)
	{
		// Get part number and version
		status = HidUartGetPartNumber(hidUart, &partNumber, &version);
	}
	
	// Got part number
	if (status == 0)
	{
		// Configure the UART
		status = HidUartSetUartConfig(hidUart, baudRate, dataBits, parity, stopBits, flowControl);
	}
	
	// Confirm UART settings
	if (status == 0)
	{
		int vBaudRate;
		int vDataBits;
		int vParity;
		int vStopBits;
		int vFlowControl;
		
		int status = HidUartGetUartConfig(hidUart, &vBaudRate, &vDataBits, &vParity, &vStopBits, &vFlowControl);
		
		if (status == 0)
		{
			if (vBaudRate != baudRate ||
				vDataBits != dataBits ||
				vParity != parity ||
				vStopBits != stopBits ||
				vFlowControl != flowControl)
			{
				status = -1;
			}
		}
	}
	
	// Configured the UART
	if (status == 0)
	{
		// Set short read timeouts for periodic read timer
		// Set longer write timeouts for user transmits
		status = HidUartSetTimeouts(hidUart, READ_TIMEOUT, WRITE_TIMEOUT);
	}
	
	// Fully connected to the device
	if (status == 0)
	{
		// Output the connection status to the status bar
		NSString* statusMsg = [NSString stringWithFormat:@"Connected to %@", serial];
		[self SetStatusText:statusMsg];
	}
	// Connect failed
	else
	{
		// Disconnect
		HidUartClose(hidUart);
		
		// Notify the user that an error occurred

		NSRunAlertPanel(@"Connection Failed", @"Failed to connect to %@: %@", serial, [NSString stringWithUTF8String:GetHidUartStatusStr(status)], @"OK", nil, nil);
		
		// Update status bar text
		[self SetStatusText:@"Not Connected"];
	}	
	
	return (status == 0);
}

// Disconnect from the currently connected device
// - Stop the read timer
// - Disconnect from the current device
// - Output any error messages
// - Display "Not Connected" in the status bar
// - Re-enable all device settings controls
// - Update the device information text boxes (clear text)
// - Set Connect checkbox/button caption and pressed state
- (BOOL)Disconnect
{
	// Stop the read timer
	[self StopReadTimer];
	
	// Close the device
	int status = HidUartClose(hidUart);
	
	// Disconnect failed
	if (status != 0)
	{
		// Notify the user that an error occurred
		NSRunAlertPanel(@"Disconnect Failed", @"Failed to disconnect: %@", [NSString stringWithUTF8String:GetHidUartStatusStr(status)], @"OK", nil, nil);
	}
	
	// Output the disconnect status to the status bar
	[self SetStatusText:@"Not Connected"];
	
	// Re-enable the device list, update button, and UART settings
	[self EnableSettingsCtrls:TRUE];
	
	// Hide CLK Output controls
	[self ShowClkOutputCtrls:FALSE];
	
	// Update device information strings
	[self UpdateDeviceInformation];
	
	// Uncheck the connect checkbox/button
	[buttonConnect setState:NSOffState];
	
	// Next button press should connect
	[buttonConnect setTitle:@"Connect"];
	
	// Return YES if the device was closed successfully
	return (status == 0);
}

// Update GPIO checkboes to display the current value of the latch
- (void)GetLatch:(BOOL)silent
{
	int status;
	unsigned short			latchValue = 0x0000;
	int			opened;
	
	// Check if the device is opened
	if (HidUartIsOpened(hidUart, &opened) == 0 && opened)
	{
		// Retrieve the GPIO latch values
		status = HidUartReadLatch(hidUart, &latchValue);
		
		if (status == 0)
		{
			if (partNumber == HID_UART_PART_CP2110)
			{
				// Update GPIO checkboxes
				[self UpdateGpioState:checkGpio0 latch:(latchValue & CP2110_MASK_GPIO_0_CLK) != 0];
				[self UpdateGpioState:checkGpio1 latch:(latchValue & CP2110_MASK_GPIO_1_RTS) != 0];
				[self UpdateGpioState:checkGpio2 latch:(latchValue & CP2110_MASK_GPIO_2_CTS) != 0];
				[self UpdateGpioState:checkGpio3 latch:(latchValue & CP2110_MASK_GPIO_3_RS485) != 0];
				[self UpdateGpioState:checkGpio4 latch:(latchValue & CP2110_MASK_GPIO_4_TX_TOGGLE) != 0];
				[self UpdateGpioState:checkGpio5 latch:(latchValue & CP2110_MASK_GPIO_5_RX_TOGGLE) != 0];
				[self UpdateGpioState:checkGpio6 latch:(latchValue & CP2110_MASK_GPIO_6) != 0];
				[self UpdateGpioState:checkGpio7 latch:(latchValue & CP2110_MASK_GPIO_7) != 0];
				[self UpdateGpioState:checkGpio8 latch:(latchValue & CP2110_MASK_GPIO_8) != 0];
				[self UpdateGpioState:checkGpio9 latch:(latchValue & CP2110_MASK_GPIO_9) != 0];
			}
			else if (partNumber == HID_UART_PART_CP2114)
			{
				// Update GPIO checkboxes
				[self UpdateGpioState:checkGpio0 latch:(latchValue & CP2114_MASK_GPIO_0) != 0];
				[self UpdateGpioState:checkGpio1 latch:(latchValue & CP2114_MASK_GPIO_1) != 0];
				[self UpdateGpioState:checkGpio2 latch:(latchValue & CP2114_MASK_GPIO_2) != 0];
				[self UpdateGpioState:checkGpio3 latch:(latchValue & CP2114_MASK_GPIO_3) != 0];
				[self UpdateGpioState:checkGpio4 latch:(latchValue & CP2114_MASK_GPIO_4) != 0];
				[self UpdateGpioState:checkGpio5 latch:(latchValue & CP2114_MASK_GPIO_5) != 0];
				[self UpdateGpioState:checkGpio6 latch:(latchValue & CP2114_MASK_GPIO_6) != 0];
				[self UpdateGpioState:checkGpio7 latch:(latchValue & CP2114_MASK_GPIO_7) != 0];
				[self UpdateGpioState:checkGpio8 latch:(latchValue & CP2114_MASK_GPIO_8) != 0];
				[self UpdateGpioState:checkGpio9 latch:(latchValue & CP2114_MASK_GPIO_9) != 0];
				[self UpdateGpioState:checkGpio10 latch:(latchValue & CP2114_MASK_TX) != 0];
				[self UpdateGpioState:checkGpio11 latch:(latchValue & CP2114_MASK_RX) != 0];
			}
		}
		else
		{
			if (!silent)
			{
				// Notify the user that an error occurred
				NSRunAlertPanel(@"Failed to read latch values", @"Failed to read latch values: %@", [NSString stringWithUTF8String:GetHidUartStatusStr(status)], @"OK", nil, nil);
			}
		}
	}
}

// Retrieves device information strings and display on the dialog
- (void)UpdateDeviceInformation
{
	char		deviceString[512];
	int					opened;
	
	// Clear all string text boxes
	[textVid setStringValue:@""];
	[textPid setStringValue:@""];
	[textSerial setStringValue:@""];
	[textPath setStringValue:@""];
	[textPartNumber setStringValue:@""];
	[textVersion setStringValue:@""];
	[textManufacturer setStringValue:@""];
	[textProduct setStringValue:@""];
	
	if (HidUartGetOpenedString(hidUart, deviceString, HID_UART_GET_VID_STR) == 0)
	{
		[textVid setStringValue:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]];
	}
	if (HidUartGetOpenedString(hidUart, deviceString, HID_UART_GET_PID_STR) == 0)
	{
		[textPid setStringValue:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]];
	}
	if (HidUartGetOpenedString(hidUart, deviceString, HID_UART_GET_SERIAL_STR) == 0)
	{
		[textSerial setStringValue:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]];
	}
	if (HidUartGetOpenedString(hidUart, deviceString, HID_UART_GET_PATH_STR) == 0)
	{
		[textPath setStringValue:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]];
	}
	if (HidUartGetOpenedString(hidUart, deviceString, HID_UART_GET_MANUFACTURER_STR) == 0)
	{
		[textManufacturer setStringValue:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]];
	}
	if (HidUartGetOpenedString(hidUart, deviceString, HID_UART_GET_PRODUCT_STR) == 0)
	{
		[textProduct setStringValue:[NSString stringWithCString:deviceString encoding:NSASCIIStringEncoding]];
	}
	
	// Update part number and version
	if (HidUartIsOpened(hidUart, &opened) == 0 && opened)
	{
		[textPartNumber setIntValue:partNumber];
		[textVersion setIntValue:version];
	}
}

// Calculate and display the CLK output speed in Hz
// CLK = 24000000 Hz / (2 x clkDiv)
// If clkDiv = 0, then CLK = 24000000 Hz
- (void)UpdateClkOutputSpeed:(int)clkDiv
{
	if (clkDiv == 0)
	{
		[textClkOutputValue setIntValue:24000000];
	}
	else
	{
		[textClkOutputValue setIntValue:(24000000/(2*clkDiv))];
	}
}

// Get the GPIO configuration from the device (input, output, function mode)
// Set GPIO checkbox properties
- (int)UpdateGpioButtonProperties
{
	int status;
	
	unsigned char pinConfig[14];
	int useSuspendValues;
	unsigned short suspendValue;
	unsigned short suspendMode;
	unsigned char rs485Level;
	unsigned char clkDiv;
	int i;
	
	if (partNumber == HID_UART_PART_CP2110)
	{
		if (0 == HidUartGetPinConfig(hidUart, pinConfig, &useSuspendValues, &suspendValue, &suspendMode, &rs485Level, &clkDiv))
		{
			for (i = 0; i < 10; i++)
			{
				// The offset into the pin arrays for the current pin configuration
                int pinModeIndex = i * 5 + pinConfig[i];
				
				NSButton*		pBtn			= [self GetButton:i];
				NSTextField*	pText			= [self GetDirection:i];
				NSString*		pinCaption		= [NSString stringWithUTF8String:CP2110_PinCaptions[pinModeIndex]];
				NSString*		pinDirection	= [NSString stringWithUTF8String:CP2110_PinDirections[pinModeIndex]];
				CHECKBOX_STYLE	pinStyle		= CP2110_PinStyle[pinModeIndex];
				
				// Set the pin caption and direction labels
				[pBtn setTitle:pinCaption];
				[pText setStringValue:pinDirection];
				
                // Set the checkbox styles
                if (pinStyle == CBS_Default)
                {
					[pBtn setAllowsMixedState:FALSE];
					[pBtn setState:NSOffState];
					[pBtn setEnabled:TRUE];
                }
                else if (pinStyle == CBS_ReadOnly)
                {
					[pBtn setAllowsMixedState:FALSE];
					[pBtn setState:NSOffState];
					[pBtn setEnabled:FALSE];
                }
                else
                {
					[pBtn setAllowsMixedState:TRUE];
					[pBtn setState:NSMixedState];
					[pBtn setEnabled:FALSE];
                }
			}
			
            // Hide GPIO.10 and GPIO.11 for CP2114
			[[self GetButton:10] setTransparent:TRUE];
			[[self GetButton:11] setTransparent:TRUE];
			[[self GetDirection:10] setStringValue:@""];
			[[self GetDirection:11] setStringValue:@""];
			
			// GPIO.0 is configured as CLK output
			if (pinConfig[CP2110_INDEX_GPIO_0_CLK] == HID_UART_GPIO_MODE_FUNCTION1)
			{
				// Show CLK Output controls
				// (controls are disabled by default in Disconnect()
				[self ShowClkOutputCtrls:TRUE];
			}
			
			// Calculate and display the CLK output speed in Hz
			[self UpdateClkOutputSpeed:clkDiv];
		}
	}
	else if (partNumber == HID_UART_PART_CP2114)
	{
		if (ok == CP2114GetPinConfig(hidUart, pinConfig, &useSuspendValues, &suspendValue, &suspendMode, &clkDiv))
		{
			for (i = 0; i < 12; i++)
			{
				// The offset into the pin arrays for the current pin configuration
                int pinModeIndex = i * 5 + pinConfig[i];
				
				NSButton*		pBtn			= [self GetButton:i];
				NSTextField*	pText			= [self GetDirection:i];
				NSString*		pinCaption		= [NSString stringWithUTF8String:CP2114_PinCaptions[pinModeIndex]];
				NSString*		pinDirection	= [NSString stringWithUTF8String:CP2114_PinDirections[pinModeIndex]];
				CHECKBOX_STYLE	pinStyle		= CP2114_PinStyle[pinModeIndex];
				
				// Set the pin caption and direction labels
				[pBtn setTitle:pinCaption];
				[pText setStringValue:pinDirection];
				
                // Set the checkbox styles
                if (pinStyle == CBS_Default)
                {
					[pBtn setAllowsMixedState:FALSE];
					[pBtn setState:NSOffState];
					[pBtn setEnabled:TRUE];
                }
                else if (pinStyle == CBS_ReadOnly)
                {
					[pBtn setAllowsMixedState:FALSE];
					[pBtn setState:NSOffState];
					[pBtn setEnabled:FALSE];
                }
                else
                {
					[pBtn setAllowsMixedState:TRUE];
					[pBtn setState:NSMixedState];
					[pBtn setEnabled:FALSE];
                }
			}
			
			// Show GPIO.10 and GPIO.11 for CP2114
			[[self GetButton:10] setTransparent:FALSE];
			[[self GetButton:11] setTransparent:FALSE];
			
			// Hide CLK Output controls
			// (controls are disabled by default in Disconnect())
			[self ShowClkOutputCtrls:FALSE];
		}
	}
	
	return status;
}

// Set the GPIO checkbox check state
- (void)UpdateGpioState:(NSButton*)pBtn latch:(BOOL)bit
{
	// If the pin is in function mode, then
	// the checkbox state is indeterminate
	if ([pBtn allowsMixedState])
	{
		[pBtn setState:NSMixedState];
	}
	else
	{
		// Latch bit value is 1
		if (bit)
		{
			[pBtn setState:NSOnState];
		}
		// Latch bit value is 0
		else
		{
			[pBtn setState:NSOffState];
		}
	}
}

// Show/hide the CLK Output controls:
// - CLK Output labels
// - CLK Output edit box
- (void)ShowClkOutputCtrls:(BOOL)show
{
	[textClkOutputPrefix setHidden:(!show)];
	[textClkOutputValue setHidden:(!show)];
	[textClkOutputSuffix setHidden:(!show)];
}

// Receive UART data from the device and output to the receive window
- (void)ReceiveData
{
	int		status;
	unsigned long				numBytesRead	= 0;
	unsigned long				numBytesToRead	= READ_SIZE;
	int *				buffer			= (int*)malloc(numBytesToRead);
	
	// Receive UART data from the device (up to 1000 bytes)
	status = HidUartRead(hidUart, (unsigned char*) buffer, numBytesToRead, &numBytesRead);
	
	// HidUart_Read() returns HID_UART_SUCCESS if numBytesRead == numBytesToRead
	// and returns HID_UART_READ_TIMED_OUT if numBytesRead < numBytesToRead

  // Note: -2 means timed out from the bridge call.
  if (status == 0 || status == -2)
	{
		// Output received data to the receive window
		if (numBytesRead > 0)
		{
			// Append received data to the receive text view
			[[[textReceive textStorage] mutableString] appendString:[self DisplayHexData:buffer ofSize:numBytesRead]];
			
			// Once the text view exceeds the max character limit
			if ([[textReceive textStorage] length] > READ_EDIT_LIMIT)
			{
				// Resize the text to half of the max character limit
				[[[textReceive textStorage] mutableString] deleteCharactersInRange:NSMakeRange(0, [[textReceive textStorage] length] - (READ_EDIT_LIMIT / 2))];
			}
			
			// Scroll to the end
			[textReceive scrollRangeToVisible:NSMakeRange([[textReceive string] length], 0)];
			
			// Use a fixed-width font
			[textReceive setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
		}
	}
	
	free(buffer);
}

// Convert a buffer of byte values to a string
// showing hex value and ASCII value
// i.e.
// If buffer[] = {0x31, 0x32, 0x33}
// Then return "31 32 33 :123"
- (NSString*)DisplayHexData:(int*)buffer ofSize:(int)size
{
	NSMutableString*	readStr		= [NSMutableString stringWithCapacity:READ_SIZE * 4];
	NSMutableString*	hexStr		= [NSMutableString stringWithCapacity:READ_SIZE * 3];
	NSMutableString*	asciiStr	= [NSMutableString stringWithCapacity:READ_SIZE * 1];
	int				i;
	int				j;
	
	for (i = 0; i < size; i++)
	{
		// Add the hex representation of the byte value to the
		// hex part of the string
		[hexStr appendFormat:@"%02X ", buffer[i]];
		
		// Add the ASCII representation of the byte value
		// to the ASCII part of the string
		if (buffer[i] >= 0x20 && buffer[i] <= 0x7e)
		{
			// Display standard ASCII values
			[asciiStr appendFormat:@"%c", buffer[i]];
		}
		else
		{
			// Don't display extended ASCII values
			// or non-displayable characters
			[asciiStr appendString:@"."];
		}
		
		// Fit READ_EDIT_COLUMNS number of byte values on a single line
		if (((i % READ_EDIT_COLUMNS) == (READ_EDIT_COLUMNS - 1)) ||
			(i == (size - 1)))
		{
			// The last line might be a little short
			// so pad the hex and ASCII values with spaces
			int padNumBytes = READ_EDIT_COLUMNS - (i % READ_EDIT_COLUMNS) - 1;
			
			for (j = 0; j < padNumBytes; j++)
			{
				[hexStr appendString:@"   "];
				[asciiStr appendString:@" "];
			}
			
			// Append the line with hex and ASCII values
			[readStr appendString:hexStr];
			[readStr appendString:@":"];
			[readStr appendString:asciiStr];
			[readStr appendString:@"\n"];
			
			// Clear the intermediate strings for the next line
			[hexStr setString:@""];
			[asciiStr setString:@""];
		}
	}
	
	return readStr;
}

- (void)StartReadTimer
{
	// Start the timer to read UART data from the device every 50 ms
	timer = [NSTimer scheduledTimerWithTimeInterval:(READ_TIMER_ELAPSE/1000.0f) target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
}

- (void)StopReadTimer
{
	[timer invalidate];
}

@end
