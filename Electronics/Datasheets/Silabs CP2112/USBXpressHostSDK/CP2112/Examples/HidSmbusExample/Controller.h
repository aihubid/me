////////////////////////////////////////////////////////////////////////////////
// Controller.h
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "SLABCP2112.h"

////////////////////////////////////////////////////////////////////////////////
// Definitions
////////////////////////////////////////////////////////////////////////////////

#define VID									0
#define PID									0

// GPIO ComboBox Selections
#define GPIO_INPUT_OPEN_DRAIN				0
#define GPIO_OUTPUT_OPEN_DRAIN				1
#define GPIO_OUTPUT_PUSH_PULL				2
#define GPIO_SPECIAL_PUSH_PULL				3

#define GPIO_OUTPUT_START					GPIO_OUTPUT_OPEN_DRAIN
#define GPIO_PUSH_PULL_START				GPIO_OUTPUT_PUSH_PULL

////////////////////////////////////////////////////////////////////////////////
// Controller Class
////////////////////////////////////////////////////////////////////////////////

@interface Controller : NSObject {
// Control Variables
@protected
	// Main Dialog
	IBOutlet NSComboBox*	m_comboDeviceList;
	IBOutlet NSButton*		m_btnConnect;
	IBOutlet NSButton*		m_btnReset;
	IBOutlet NSTabView*		m_tabCtrl;
	IBOutlet NSTextField*	m_textConnection;
	IBOutlet NSTextField*	m_textStatus;
	IBOutlet NSTextField*	m_textVid;
	IBOutlet NSTextField*	m_textPid;
	IBOutlet NSTextField*	m_textReleaseNumber;
	IBOutlet NSTextField*	m_textPartNumber;
	IBOutlet NSTextField*	m_textVersion;
	IBOutlet NSTextField*	m_textPath;
	IBOutlet NSTextField*	m_textSerial;
	IBOutlet NSTextField*	m_textManufacturer;
	IBOutlet NSTextField*	m_textProduct;
	
	// Configuration Tab
	IBOutlet NSTextField*	m_textBitRate;
	IBOutlet NSTextField*	m_textMasterSlaveAddress;
	IBOutlet NSButton*		m_btnAutoRespond;
	IBOutlet NSTextField*	m_textWriteTimeout;
	IBOutlet NSTextField*	m_textReadTimeout;
	IBOutlet NSButton*		m_btnSclLowTimeout;
	IBOutlet NSTextField*	m_textTransferRetries;
	IBOutlet NSTextField*	m_textResponseTimeout;
	IBOutlet NSButton*		m_btnGetConfig;
	IBOutlet NSButton*		m_btnSetConfig;
	IBOutlet NSButton*		m_btnGetTimeout;
	IBOutlet NSButton*		m_btnSetTimeout;
	
	// Data Transfer Tab
	IBOutlet NSTextField*	m_textReadAddress;
	IBOutlet NSTextField*	m_textReadBytesToRead;
	IBOutlet NSButton*		m_btnRead;
	IBOutlet NSTextField*	m_textAddressedAddress;
	IBOutlet NSTextField*	m_textTargetAddressSize;
	IBOutlet NSTextField*	m_textTargetAddress;
	IBOutlet NSTextField*	m_textAddressedBytesToRead;
	IBOutlet NSButton*		m_btnAddressedRead;
	IBOutlet NSTextField*	m_textReceivedData;
	IBOutlet NSTextField*	m_textForceBytesToRead;
	IBOutlet NSButton*		m_btnForceReadResponse;
	IBOutlet NSButton*		m_btnGetReadResponse;
	IBOutlet NSTextField*	m_textDataToWrite;
	IBOutlet NSTextField*	m_textWriteAddress;
	IBOutlet NSButton*		m_btnWriteRequest;
	IBOutlet NSButton*		m_btnCancelTransfer;
	IBOutlet NSButton*		m_btnGetTransferStatus;
	
	// Pin Configuration Tab
	IBOutlet NSButton*		m_btnGetGpioConfig;
	IBOutlet NSButton*		m_btnSetGpioConfig;
	IBOutlet NSComboBox*	m_comboGpio0;
	IBOutlet NSComboBox*	m_comboGpio1;
	IBOutlet NSComboBox*	m_comboGpio2;
	IBOutlet NSComboBox*	m_comboGpio3;
	IBOutlet NSComboBox*	m_comboGpio4;
	IBOutlet NSComboBox*	m_comboGpio5;
	IBOutlet NSComboBox*	m_comboGpio6;
	IBOutlet NSComboBox*	m_comboGpio7;
	IBOutlet NSTextField*	m_textClkDiv;
	IBOutlet NSTextField*	m_textClkFreq;
	IBOutlet NSButton*		m_btnReadLatch;
	IBOutlet NSButton*		m_btnWriteLatch;
	IBOutlet NSButton*		m_btnGpio0;
	IBOutlet NSButton*		m_btnGpio1;
	IBOutlet NSButton*		m_btnGpio2;
	IBOutlet NSButton*		m_btnGpio3;
	IBOutlet NSButton*		m_btnGpio4;
	IBOutlet NSButton*		m_btnGpio5;
	IBOutlet NSButton*		m_btnGpio6;
	IBOutlet NSButton*		m_btnGpio7;
	
	// Customization Tab
	IBOutlet NSButton*		m_btnGetUsbConfig;
	IBOutlet NSButton*		m_btnSetUsbConfig;
	IBOutlet NSButton*		m_btnCustomVid;
	IBOutlet NSTextField*	m_textCustomVid;
	IBOutlet NSButton*		m_btnCustomPid;
	IBOutlet NSTextField*	m_textCustomPid;
	IBOutlet NSButton*		m_btnCustomPower;
	IBOutlet NSTextField*	m_textCustomPower;
	IBOutlet NSButton*		m_btnCustomPowerMode;
	IBOutlet NSMatrix*		m_mtxCustomPowerMode;
	IBOutlet NSButton*		m_btnCustomRelease;
	IBOutlet NSTextField*	m_textCustomReleaseMsb;
	IBOutlet NSTextField*	m_textCustomReleaseLsb;
	IBOutlet NSButton*		m_btnGetLock;
	IBOutlet NSButton*		m_btnSetLock;
	IBOutlet NSButton*		m_btnLockVid;
	IBOutlet NSButton*		m_btnLockPid;
	IBOutlet NSButton*		m_btnLockPower;
	IBOutlet NSButton*		m_btnLockPowerMode;
	IBOutlet NSButton*		m_btnLockRelease;
	IBOutlet NSButton*		m_btnLockManufacturer;
	IBOutlet NSButton*		m_btnLockProduct;
	IBOutlet NSButton*		m_btnLockSerial;
	IBOutlet NSButton*		m_btnGetManufacturer;
	IBOutlet NSButton*		m_btnSetManufacturer;
	IBOutlet NSTextField*	m_textCustomManufacturer;
	IBOutlet NSButton*		m_btnGetProduct;
	IBOutlet NSButton*		m_btnSetProduct;
	IBOutlet NSTextField*	m_textCustomProduct;
	IBOutlet NSButton*		m_btnGetSerial;
	IBOutlet NSButton*		m_btnSetSerial;
	IBOutlet NSTextField*	m_textCustomSerial;

// Protected Members
@protected
	HID_SMBUS_DEVICE		m_hidSmbus;
}

////////////////////////////////////////////////////////////////////////////////
// Actions
////////////////////////////////////////////////////////////////////////////////

// Main Dialog
- (IBAction)OnConnect:(id)sender;
- (IBAction)OnReset:(id)sender;

// Configuration Tab
- (void)GetSmbusConfig:(BOOL)silent;
- (void)GetTimeouts:(BOOL)silent;
- (IBAction)OnGetSmbusConfig:(id)sender;
- (IBAction)OnSetSmbusConfig:(id)sender;
- (IBAction)OnGetTimeouts:(id)sender;
- (IBAction)OnSetTimeouts:(id)sender;

// Data Transfer Tab
- (IBAction)OnReadRequest:(id)sender;
- (IBAction)OnAddressedReadRequest:(id)sender;
- (IBAction)OnForceReadResponse:(id)sender;
- (IBAction)OnGetReadResponse:(id)sender;
- (IBAction)OnWriteRequest:(id)sender;
- (IBAction)OnCancelTransfer:(id)sender;
- (IBAction)OnGetTransferStatus:(id)sender;

// Pin Configuration Tab
- (void)GetGpioConfig:(BOOL)silent;
- (void)ReadLatch:(BOOL)silent;
- (IBAction)OnGetGpioConfig:(id)sender;
- (IBAction)OnSetGpioConfig:(id)sender;
- (IBAction)OnReadLatch:(id)sender;
- (IBAction)OnWriteLatch:(id)sender;

// Customization Tab
- (void)GetUsbConfig:(BOOL)silent;
- (void)GetLock:(BOOL)silent;
- (void)GetManufacturer:(BOOL)silent;
- (void)GetProduct:(BOOL)silent;
- (void)GetSerial:(BOOL)silent;
- (IBAction)OnGetUsbConfig:(id)sender;
- (IBAction)OnSetUsbConfig:(id)sender;
- (IBAction)OnGetLock:(id)sender;
- (IBAction)OnSetLock:(id)sender;
- (IBAction)OnGetManufacturer:(id)sender;
- (IBAction)OnSetManufacturer:(id)sender;
- (IBAction)OnGetProduct:(id)sender;
- (IBAction)OnSetProduct:(id)sender;
- (IBAction)OnGetSerial:(id)sender;
- (IBAction)OnSetSerial:(id)sender;

////////////////////////////////////////////////////////////////////////////////
// Validation
////////////////////////////////////////////////////////////////////////////////

- (NSString*)CleanHexString:(NSString*)editStr;
- (NSArray*)GetHexArray:(NSString*)hexStr;
- (DWORD)GetHexValue:(NSString*)hexStr;
- (WORD)GetShortHexValue:(NSString *)hexStr;

- (BOOL)ValidateHexField:(NSTextField*)textField numBytes:(int)numBytes minimum:(DWORD)min maximum:(DWORD)max isEven:(BOOL)even isOdd:(BOOL)odd;

- (BOOL)ValidateConfiguration;
- (BOOL)ValidateDataTransferRead;
- (BOOL)ValidateDataTransferAddressedRead;
- (BOOL)ValidateDataTransferReadResponse;
- (BOOL)ValidateDataTransferWrite;
- (BOOL)ValidatePinConfiguration;
- (BOOL)ValidateCustomizationUsbConfig;
- (BOOL)ValidateCustomizationManufacturer;
- (BOOL)ValidateCustomizationProduct;
- (BOOL)ValidateCustomizationSerial;

////////////////////////////////////////////////////////////////////////////////
// Delegates
////////////////////////////////////////////////////////////////////////////////

- (void)windowWillClose:(NSNotification*)notification;
- (void)comboBoxSelectionDidChange:(NSNotification *)notification;
- (void)comboBoxWillDismiss:(NSNotification *)notification;
- (void)comboBoxWillPopUp:(NSNotification *)notification;
- (void)controlTextDidChange:(NSNotification *)aNotification;

////////////////////////////////////////////////////////////////////////////////
// Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib;

////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////

- (void)InitializeDialog;
- (void)InitStatusBar;

////////////////////////////////////////////////////////////////////////////////
// Methods
////////////////////////////////////////////////////////////////////////////////

- (void)SetConnectionText:(NSString*)text;
- (void)SetStatusText:(NSString*)text;
- (void)UpdateDeviceList;
- (void)UpdateDeviceInformation:(BOOL)connected;
- (void)EnableDeviceCtrls:(BOOL)enable;
- (BOOL)GetSelectedDevice:(NSString**)serial;
- (BOOL)FindDevice:(NSString*)serial deviceNum:(DWORD*)deviceNum;
- (BOOL)Connect;
- (BOOL)Disconnect;
- (void)UpdateClkFrequency;
- (void)SetPinDirection:(BYTE)direction withMode:(BYTE)mode withFunction:(BYTE)function;
- (void)GetPinDirection:(BYTE*)direction getMode:(BYTE*)mode getFunction:(BYTE*)function;
- (void)SetLatchValue:(BYTE)latchValue;
- (BYTE)GetLatchValue:(BYTE*)mask;
- (void)OutputStatus:(NSString*)functionName withStatus:(HID_SMBUS_STATUS)status;
- (void)SetDefaults;
- (void)SetFromDevice;

- (void)runModalInfoMessage:(NSString *)title withMessage:(NSString *)message;

@end
