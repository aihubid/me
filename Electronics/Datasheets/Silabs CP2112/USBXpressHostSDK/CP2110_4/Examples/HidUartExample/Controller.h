////////////////////////////////////////////////////////////////////////////////
// Controller.h
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
// Definitions
////////////////////////////////////////////////////////////////////////////////

#define VID					0
#define PID					0

#define READ_TIMEOUT		0
#define WRITE_TIMEOUT		2000

#define READ_TIMER_ID		1
#define READ_TIMER_ELAPSE	50

#define READ_SIZE			1000

#define	READ_EDIT_LIMIT		10000
#define READ_EDIT_COLUMNS	14

////////////////////////////////////////////////////////////////////////////////
// Controller Class
////////////////////////////////////////////////////////////////////////////////

@interface Controller : NSObject {
	IBOutlet NSComboBox*	comboDeviceList;
	IBOutlet NSButton*		buttonConnect;
	IBOutlet NSButton*		buttonUpdate;

	IBOutlet NSTextField*	textVid;
	IBOutlet NSTextField*	textPid;
	IBOutlet NSTextField*	textSerial;
	IBOutlet NSTextField*	textPath;
	IBOutlet NSTextField*	textPartNumber;
	IBOutlet NSTextField*	textVersion;
	IBOutlet NSTextField*	textManufacturer;
	IBOutlet NSTextField*	textProduct;
	IBOutlet NSTextField*	textLibrary;
	
	IBOutlet NSTextField*	textBaudRate;
	IBOutlet NSComboBox*	comboDataBits;
	IBOutlet NSComboBox*	comboParity;
	IBOutlet NSComboBox*	comboStopBits;
	IBOutlet NSComboBox*	comboFlowControl;
	
	IBOutlet NSBox*			groupBox;
	IBOutlet NSButton*		checkGpio0;
	IBOutlet NSButton*		checkGpio1;
	IBOutlet NSButton*		checkGpio2;
	IBOutlet NSButton*		checkGpio3;
	IBOutlet NSButton*		checkGpio4;
	IBOutlet NSButton*		checkGpio5;
	IBOutlet NSButton*		checkGpio6;
	IBOutlet NSButton*		checkGpio7;
	IBOutlet NSButton*		checkGpio8;
	IBOutlet NSButton*		checkGpio9;
	IBOutlet NSButton*		checkGpio10;
	IBOutlet NSButton*		checkGpio11;

	IBOutlet NSTextField*	textGpio0;
	IBOutlet NSTextField*	textGpio1;
	IBOutlet NSTextField*	textGpio2;
	IBOutlet NSTextField*	textGpio3;
	IBOutlet NSTextField*	textGpio4;
	IBOutlet NSTextField*	textGpio5;
	IBOutlet NSTextField*	textGpio6;
	IBOutlet NSTextField*	textGpio7;
	IBOutlet NSTextField*	textGpio8;
	IBOutlet NSTextField*	textGpio9;
	IBOutlet NSTextField*	textGpio10;
	IBOutlet NSTextField*	textGpio11;
	
	IBOutlet NSTextField*	textClkOutputPrefix;
	IBOutlet NSTextField*	textClkOutputValue;
	IBOutlet NSTextField*	textClkOutputSuffix;
	
	IBOutlet NSTextField*	textTransmit;
	IBOutlet NSButtonCell*	radioAscii;
	IBOutlet NSButtonCell*	radioHex;
	IBOutlet NSTextView*	textReceive;
	
	IBOutlet NSTextField*	textStatusBar;	
	
	void *			hidUart;
	NSTimer*				timer;
	int					partNumber;
	int					version;
}

// Actions
- (IBAction)OnConnect:(id)sender;
- (IBAction)OnGet:(id)sender;
- (IBAction)OnSet:(id)sender;
- (IBAction)OnTransmit:(id)sender;
- (IBAction)OnClear:(id)sender;

- (void)OnTimer:(NSTimer*)timer;
- (void)windowWillClose:(NSNotification*)notification;
- (void)comboBoxWillPopUp:(NSNotification*)notification;
- (void)comboBoxWillDismiss:(NSNotification*)notification;


- (NSString*)CleanHexString:(NSString*)editStr;

- (NSButton*)GetButton:(int)i;
- (NSTextField*)GetDirection:(int)i;
- (void)SetStatusText:(NSString*)statusStr;

- (void)awakeFromNib;
- (void)InitializeWindow;
- (void)InitStatusBar;
- (void)InitUartSettings;
- (void)InitTransferSettings;
- (void)InitHexEditCtrl;
- (void)InitLibraryVersion;

- (void)UpdateDeviceList;
- (void)EnableSettingsCtrls:(BOOL)enable;
- (BOOL)GetConnectionSettings:(NSString**)serial baud:(int *)baudRate data:(int *)data parity:(int *)parity stop:(int*)stop flow:(int*)flowControl;
- (BOOL)Connect;
- (BOOL)ConnectTo:(NSString*)serial baud:(int)baudRate data:(int)dataBits parity:(int)parity stop:(int)stopBits flow:(int)flowControl;
- (BOOL)Disconnect;
- (void)GetLatch:(BOOL)silent;
- (void)UpdateDeviceInformation;
- (void)UpdateClkOutputSpeed:(int)clkDiv;
- (int)UpdateGpioButtonProperties;
- (void)UpdateGpioState:(NSButton*)pBtn latch:(BOOL)bit;
- (void)ShowClkOutputCtrls:(BOOL)show;
- (void)ReceiveData;
- (NSString*)DisplayHexData:(int*)buffer ofSize:(int)size;

- (void)StartReadTimer;
- (void)StopReadTimer;
@end
