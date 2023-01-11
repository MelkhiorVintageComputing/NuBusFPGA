/*
  File:		NuBusFPGAHDMIAudio.c
  Contains:	NuBusFGPA HDMI sound output component
  Written by:	Romain Dolbeau
  Copyright:	© 2023 by Romain Dolbeau
 
  Based upon the following reference code from 'Develop Magazine, issue 20':
  File:		NoiseMaker.c
  Contains:	Sample sound output component
  Written by:	Kip Olson
  Copyright:	© 1994 by Apple Computer, Inc.
*/

#include <Memory.h>
#include <Errors.h>
#include <SoundInput.h>
#include <Components.h>
#include <Gestalt.h>

#include "Sound.h"
#include "SoundComponents.h"

#include "Slots.h"
#include "ROMDefs.h"
 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Hardware
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define GOBLIN_BT_OFFSET       0x00900000

#define u_int32_t volatile unsigned long

//#define BT_DEBUG 1
// this is the DAC registers, not needed for audio except 'debug' is handy
struct goblin_bt_regs {
  u_int32_t mode;
  u_int32_t vblmask;
  u_int32_t videoctrl;
  u_int32_t intrclear;
  u_int32_t reset;
  u_int32_t lutaddr;
  u_int32_t lut;
  u_int32_t debug;
};

#define GOBLIN_CSR_OFFSET 0x00a01000

// those are the CSRs, we don't touch the VTG but the audio stuff is in there as well
struct goblin_csr {
  u_int32_t goblin_video_framebuffer_vtg_hres;
  u_int32_t goblin_video_framebuffer_vtg_hsync_start;
  u_int32_t goblin_video_framebuffer_vtg_hsync_end;
  u_int32_t goblin_video_framebuffer_vtg_hscan;
  u_int32_t goblin_video_framebuffer_vtg_vres;
  u_int32_t goblin_video_framebuffer_vtg_vsync_start;
  u_int32_t goblin_video_framebuffer_vtg_vsync_end;
  u_int32_t goblin_video_framebuffer_vtg_vscan;
  u_int32_t goblin_goblin_audio_irqctrl;
  u_int32_t goblin_goblin_audio_irqstatus;
  u_int32_t goblin_goblin_audio_ctrl;
  u_int32_t goblin_goblin_audio_bufstatus;
  u_int32_t goblin_goblin_audio_buf0_addr;
  u_int32_t goblin_goblin_audio_buf0_size;
  u_int32_t goblin_goblin_audio_buf1_addr;
  u_int32_t goblin_goblin_audio_buf1_size;
  u_int32_t goblin_goblin_audio_buf_desc;
};

#define GOBLIN_AUDIOBUFFER_OFFSET 0x00920000
#define GOBLIN_AUDIOBUFFER_SIZE   0x00002000
// we currently have 8 KiB (0x2000) of SRAM there, but perhaps we could move that to the SDRAM?

static inline unsigned long brev(const unsigned long r) {
  return (((r&0xFF000000)>>24) | ((r&0xFF0000)>>8) | ((r&0xFF00)<<8) | ((r&0xFF)<<24));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Constants
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define kDelegateComponentCall			((ComponentRoutine) -1L)	// flag that selector should be delegated instead of called

#define kNoiseMakerVersion				0x00010000		// version for this sound component
#define kRequiredSndMgrMajorRev			3				// Sound Manager version required to run this component

// hardware settings

#define kSampleSizesCount				2
#define 	k8BitSamples				8				// 8-bit samples
#define 	k16BitSamples				16				// 16-bit samples

#define kSampleRatesCount				1 // 3
#define 	kSupportsSampleRateRange	false			// set to true to use sample rate range
#define 	kSampleRateMin				0x2B110000		// sample rate min = 11.025 kHz
#define 	kSampleRateMax				0xAC440000		// sample rate max = 44.100 kHz

#define 	kSampleRate44				0xAC440000		// 44.1000 kHz rate
#define 	kSampleRate22				0x56220000		// 22.050 kHz rate
#define 	kSampleRate11				0x2B110000		// 11.025 kHz rate

#define kChannelsCount					2
#define 	kNumChannelsMono			1				// mono
#define 	kNumChannelsStereo			2				// stereo

#define kInterruptBufferSamples			GOBLIN_AUDIOBUFFER_SIZE/(4 * kNumChannelsStereo * k16BitSamples >> 3)				// size of interrupt buffer in samples

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Data Structures
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* Data structure passed to some GetInfo calls */

typedef struct {
  short	count;
  Handle	handle;
} HandleList, *HandleListPtr;

/* Preferences data structure. A handle containing this data structure is stored in the
   Sound Preferences file and is loaded into the sound component refcon when it is opened. */

typedef struct {
  UnsignedFixed		sampleRate;
  short				sampleSize;
  short				numChannels;
  unsigned long		volume;
} PreferencesRecord, *PreferencesPtr, **PreferencesHandle;

/* Sound component globals */

typedef struct {

  // these are general purpose variables that every sound component will need
  ComponentInstance		self;					// ourselves
  ComponentInstance		sourceComponent;		// component to call when hardware needs more data
  SoundComponentDataPtr	sourceDataPtr;			// pointer to source data structure
  Handle					globalsHandle;			// handle to component globals
  Boolean					inSystemHeap;			// true if component loaded in system heap, false if in app heap
  Boolean					prefsChanged;			// true if preferences have changed
  PreferencesHandle		prefsHandle;			// global preferences

  // these are variables specific to this implementation
  SoundComponentData		hwSettings;				// current hardware settings
  unsigned long			hwVolume;				// current hardware volume
  Boolean					hwInterruptsOn;			// true if sound is playing
  Boolean					hwInitialized;			// true if hardware was initialized by __InitOutputDevice 
  SlotIntQElement         *siqel;
  struct goblin_bt_regs*  bt; // for debug
  struct goblin_csr*      csr; // CSR, including audio control
  u_int32_t*              buf0; // primary address for first buffer (host view)
  u_int32_t*              buf1; // primary address for second buffer (host view)
  unsigned char           lastbuf;
  unsigned char           slot;
}
  GlobalsRecord, *GlobalsPtr;
 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Compatibility with old names (?)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
typedef ComponentFunctionUPP ComponentRoutine;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Prototypes
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pascal ComponentResult	main(ComponentParameters *params, GlobalsPtr globals);

ComponentRoutine		GetComponentRoutine(short selector);
pascal ComponentResult	__ComponentRegister(GlobalsPtr globals);
pascal ComponentResult	__ComponentVersion(void *unused1);
pascal ComponentResult	__ComponentCanDo(void *unused1, short selector);
pascal ComponentResult	__ComponentOpen(void *unused1, ComponentInstance self);
pascal ComponentResult	__ComponentClose(GlobalsPtr globals, ComponentInstance self);
pascal ComponentResult	__InitOutputDevice(GlobalsPtr globals, long actions);
pascal ComponentResult	__GetInfo(GlobalsPtr globals, SoundSource sourceID, OSType selector, void *infoPtr);
pascal ComponentResult	__SetInfo(GlobalsPtr globals, SoundSource sourceID, OSType selector, void *infoPtr);
pascal ComponentResult	__StartSource(GlobalsPtr globals, short count, SoundSource *sources);
pascal ComponentResult	__PlaySourceBuffer(GlobalsPtr globals, SoundSource sourceID, SoundParamBlockPtr pb, long actions);

Handle					NewHandleLockClear(long len, Boolean inSystemHeap);
PreferencesHandle		GetPreferences(ComponentInstance self, Boolean inSystemHeap);
void					SavePreferences(ComponentInstance self, PreferencesHandle prefsHandle);
OSErr					SetupHardware(GlobalsPtr globals);
void					ReleaseHardware(GlobalsPtr globals);
OSErr					StartHardware(GlobalsPtr globals);
void					StopHardware(GlobalsPtr globals);
void					SuspendHardware(GlobalsPtr globals);
void					ResumeHardware(GlobalsPtr globals);
OSErr					SetHardwareVolume(GlobalsPtr globals, unsigned long volume);
pascal void				InterruptRoutine(SndChannelPtr chan, SndCommand *cmd);
SoundComponentDataPtr	GetMoreSource(GlobalsPtr globals);
void					CopySamplesToHardware(GlobalsPtr globals, SoundComponentDataPtr sourceDataPtr);

asm pascal void irqTrampoline(void);


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Main Component Entry Point
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*	=======================================================================================
	NuBusFPGAHDMIAudio

	The function of this routine is to dispatch to the appropriate component method. It first
	calls finds the address of the method to dispatch to using the selector provided in the
	what field of the parameter block. If the address is -1L, then this selector should
	be delegated. If the address is nil, this selector is not supported.
	======================================================================================= */

pascal ComponentResult main(ComponentParameters *params, GlobalsPtr globals)
{
  ComponentRoutine	theRtn;
  ComponentResult		result;

#ifdef BT_DEBUG
  if (globals) {
    if ((*globals).bt) {
      (*(*globals).bt).debug = 'MAIN';
      (*(*globals).bt).debug = params->what;
    } else {
      (*(struct goblin_bt_regs*)0xfc900000).debug = 'MaIn';
      (*(struct goblin_bt_regs*)0xfc900000).debug = params->what;
    }
  } else {
    (*(struct goblin_bt_regs*)0xfc900000).debug = 'main';
    (*(struct goblin_bt_regs*)0xfc900000).debug = params->what;
  }
#endif

  theRtn = GetComponentRoutine(params->what);				// get address of component routine

  if (theRtn == nil)										// selector not implemented
    result = badComponentSelector;
  else if (theRtn == kDelegateComponentCall)				// selector should be delegated
    result = DelegateComponentCall(params, globals->sourceComponent);
  else
    result = CallComponentFunctionWithStorage((Handle) globals, params, (ComponentFunctionUPP) theRtn);

  return (result);
}

/*	=======================================================================================
	GetComponentRoutine

	The function of this routine is to return the address of the appropriate component method.
	To do this, the routine must deal with 3 selector ranges:

	-5 to -1	These are the standard Component Manager selectors that all components
	must share. Refer to the Component Manager documentation for more info.

	0 to 255	These selectors cannot be delegated. If the sound component does not implement
	one of these selectors, it should return the badComponentSelector error.

	256 to °	These selectors should be delegated. If the sound component does not implement
	one of these selectors, it should use DelegateComponentCall() to pass
	this selector on up the chain. If the sound component does implement this
	selector, it should first delegate the selector, then perform the function.
	======================================================================================= */

ComponentRoutine GetComponentRoutine(short selector)
{
  void 	*theRtn;

  if (selector < 0)
    switch (selector)									// standard component selectors
      {
      case kComponentRegisterSelect:
	theRtn = __ComponentRegister;
	break;

      case kComponentVersionSelect:
	theRtn = __ComponentVersion;
	break;

      case kComponentCanDoSelect:
	theRtn = __ComponentCanDo;
	break;

      case kComponentCloseSelect:
	theRtn = __ComponentClose;
	break;

      case kComponentOpenSelect:
	theRtn = __ComponentOpen;
	break;

      default:
	theRtn = nil;								// unknown selector, so fail
	break;
      }
  else if (selector < kDelegatedSoundComponentSelectors)	// selectors that cannot be delegated
    switch (selector)
      {
      case kSoundComponentInitOutputDeviceSelect:
	theRtn = __InitOutputDevice;
	break;

      default:
	theRtn = nil;								// unknown selector, so fail
	break;
      }
  else													// selectors that can be delegated
    switch (selector)
      {
      case kSoundComponentGetInfoSelect:
	theRtn = __GetInfo;
	break;

      case kSoundComponentSetInfoSelect:
	theRtn = __SetInfo;
	break;

      case kSoundComponentStartSourceSelect:
	theRtn = __StartSource;
	break;

      case kSoundComponentPlaySourceBufferSelect:
	theRtn = __PlaySourceBuffer;
	break;

      default:
	theRtn = kDelegateComponentCall;			// unknown selector, so delegate it
	break;
      }

  return (theRtn);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Component Manager Methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


/*	==============================================================================
	Component Register

	This routine is called once, usually at boot time, when the Component Manager
	is first registering this sound component. This routine should check to see if the proper
	hardware is installed and return 0 if it is. If the hardware is not installed,
	the routine should return 1 and this component will not be registered. This is
	also an opportunity to do one-time initializations and perhaps register this
	component again if more than one hardware device is available. Global state information
	can also be saved in the component refcon by calling SetComponentRefCon();

	NOTE: The cmpWantsRegisterMessage bit must be set in the component flags of the
	sound component in order for this routine to be called.
	NOTE: This routine is never called at interrupt time.
	============================================================================== */

pascal ComponentResult __ComponentRegister(GlobalsPtr globals)
{
  long		result;
  NumVersion	version;

  if ((Gestalt(gestaltSoundAttr, &result) == noErr) &&		// snd gestalt is available
      (result & (1L << gestaltSoundIOMgrPresent)))			// snd dispatcher is available
    {
      version = SndSoundManagerVersion();						// get the Sound Manager version
      if (version.majorRev >= kRequiredSndMgrMajorRev)		// it's what we need
	{
	  //	Check for hardware here. We are always installed, so we return 0
	  OSErr ret = noErr;
	  SpBlock mySpBlock;
	  SInfoRecord mySInfoRecord;
				
	  mySpBlock.spResult = (long)&mySInfoRecord;
	  mySpBlock.spSlot = 0x9;
	  mySpBlock.spID = 0;
	  mySpBlock.spExtDev = 0;
	  mySpBlock.spCategory = catProto;
	  mySpBlock.spCType = 0x1001;
	  mySpBlock.spDrvrSW = drSwApple;
	  mySpBlock.spDrvrHW = 0xbeed;
	  mySpBlock.spTBMask = 0;
			
	  ret = SNextTypeSRsrc(&mySpBlock);
	  if (ret)
	    return 1; // oups
				
	  (*globals).slot = mySpBlock.spSlot;
	  (*globals).bt = (struct goblin_bt_regs*)(0xF0000000 |
						   ((unsigned long)mySpBlock.spSlot)<<24 |
						   GOBLIN_BT_OFFSET);
	  
#ifdef BT_DEBUG
	  (*(*globals).bt).debug = 'REGI';
			
	  (*(*globals).bt).debug = 'slot';
	  (*(*globals).bt).debug = mySpBlock.spSlot;
#endif
													 
	  (*globals).csr = (struct goblin_csr*)(0xF0000000 |
						((unsigned long)mySpBlock.spSlot)<<24 |
						GOBLIN_CSR_OFFSET);
	  
#ifdef BT_DEBUG							  
	  (*(*globals).bt).debug = 'csr ';
	  (*(*globals).bt).debug = (unsigned long)(*globals).csr;
#endif

	  return (0);											// install this sound component
	}
    }
	
  return (1);													// do not install component
}

/*	==============================================================================
	Component Version

	This routine is called to determine the current version of the sound component.
	It should return a fixed-point value containing the version, like 0x10001
	for version 1.1. The version given here must match the version stored in
	the 'thng' resource.

	NOTE: This routine is never called at interrupt time.
	============================================================================== */

pascal ComponentResult __ComponentVersion(void *unused1)
{
#pragma unused (unused1)

  return (kNoiseMakerVersion);								// return sound component version
}

/*	==============================================================================
	Component CanDo

	This routine is called to determine if a particular selector is implemented.
	It should return 1 if this is a valid selector, or 0 if the selector is not
	implemented or if the selector is always delegated.

	NOTE: This routine is never called at interrupt time.
	============================================================================== */

pascal ComponentResult __ComponentCanDo(void *unused1, short selector)
{
#pragma unused (unused1)

  ComponentRoutine	theRtn;

  theRtn = GetComponentRoutine(selector);						// see if this selector is implemented

  if ((theRtn == nil) ||										// selector is not implemented
      (theRtn == kDelegateComponentCall))						// or selector is always delegated
    return (0);												// no can do
  else
    return (1);												// selector is implemented
}

/*	==============================================================================
	Component Open

	This routine is called when the Component Manager creates an instance of this
	component. The routine should allocate global variables in the appropriate heap
	and call SetComponentInstanceStorage() so the Component Manager can remember
	the globals and pass them to all the method calls.
	
	Determining the heap to use can be tricky. The Component Manager will normally
	load the component code into the system heap, which is good, since many applications
	will be sharing this component to play sound. In this case, the components's global
	variable storage should also be created in the system heap.

	However, if system heap memory is tight, the Component Manager will load
	the component into the application heap of the first application that plays sound.
	When this happens, the component should create global storage in the application heap
	instead. The Sound Manager will make sure that other applications will not try
	to play sound while the component is in this application heap.

	To determine the proper heap to use, call GetComponentInstanceA5(). If the value
	returned is 0, then the component was loaded into the system heap, and all storage
	should be allocated there. If the value returned is non-zero, the component is in
	the application heap specifed by returned A5 value, and all storage should be
	allocated in this application heap.
	
	NOTE: If the component is loaded into the application heap, the value returned by
	GetComponentRefCon() will be 0.
	NOTE: Do not attempt to initialize or access hardware in this call, since the
	Component Manager will call Open() BEFORE calling Register().
	Instead, initialize the hardware during InitOutputDevice(), described below.
	NOTE: This routine is never called at interrupt time.
	============================================================================== */

pascal ComponentResult __ComponentOpen(void *unused1, ComponentInstance self)
{
#pragma unused (unused1)

  Handle			h;
  GlobalsPtr		globals;
  Boolean			inSystemHeap;

  inSystemHeap = GetComponentInstanceA5(self) == 0;		// find out if we were loaded in app heap or system heap

  h = NewHandleLockClear(sizeof(GlobalsRecord), inSystemHeap);	// get space for globals in appropriate heap
  if (h == nil)
    return(MemError());
		
  globals = (GlobalsPtr) *h;
		
  (*globals).siqel = (SlotIntQElement*)NewPtrSysClear(sizeof(SlotIntQElement));
  if ((*globals).siqel == nil) {
    DisposeHandle(h);
    return(MemError());
  }

  SetComponentInstanceStorage (self, (Handle) globals); 	// save pointer to our globals

  globals->self = self;									// remember ourselves
  globals->globalsHandle = h;								// remember the handle
  globals->inSystemHeap = inSystemHeap;					// remember which heap we are in
  globals->prefsHandle = GetPreferences(self, inSystemHeap);	// retrieve or create preferences
  if (globals->prefsHandle == nil)						// could create preferences
    return (memFullErr);								// we can't run

  return (noErr);
}

/*	==============================================================================
	Component Close

	This routine is called when the Component Manager is closing the instance of
	this component. If the hardware was initialized, the routine should make sure
	all remaining data is written to the hardware and that the hardware is completely
	turned off. It should delete all global storage and close any other components
	that were opened.
	
	NOTE: Be sure to check that the globals pointer passed in to this routine is
	not set to NIL. If the Open() routine fails for any reason, the Component
	Manager will call this routine passing in a NIL for the globals.
	NOTE: This routine is never called at interrupt time.
	============================================================================== */

pascal ComponentResult __ComponentClose(GlobalsPtr globals, ComponentInstance self)
{
  if (globals)											// we have some globals
    {
      if (globals->hwInitialized)							// hardware was initialized
	{
	  ReleaseHardware(globals);						// make sure the hardware is off and release it
	  HUnlock((Handle) globals->prefsHandle);			// let prefs handle roam now
	}

      if (globals->sourceComponent)						// we opened a mixer
	CloseMixerSoundComponent(globals->sourceComponent);	// close it

      if (globals->prefsChanged)							// preferences changed
	SavePreferences(self, globals->prefsHandle);	// save them

      if (!globals->inSystemHeap)							// prefs are in app heap
	DisposeHandle((Handle) globals->prefsHandle);	// dispose of them
	
      DisposePtr((char*)globals->siqel);
      DisposeHandle(globals->globalsHandle);				// dispose our storage
    }

  return (noErr);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Standard Sound Component Methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


/*	==============================================================================
	InitOutputDevice

	This routine is called once when the Sound Manager first opens this sound component.
	The routine should initialize the hardware to default values, allocate the
	appropriate mixer and create any other memory that is required.

	NOTE: This routine is never called at interrupt time.
	============================================================================== */

pascal ComponentResult __InitOutputDevice(GlobalsPtr globals, long actions)
{
#pragma unused (actions)

  ComponentResult		result;
  PreferencesPtr		prefsPtr;
  OSErr ret = noErr;
  SpBlock mySpBlock;
  SInfoRecord mySInfoRecord;
				
  mySpBlock.spResult = (long)&mySInfoRecord;
  mySpBlock.spSlot = 0x9;
  mySpBlock.spID = 0;
  mySpBlock.spExtDev = 0;
  mySpBlock.spCategory = catProto;
  mySpBlock.spCType = 0x1001;
  mySpBlock.spDrvrSW = drSwApple;
  mySpBlock.spDrvrHW = 0xbeed;
  mySpBlock.spTBMask = 0;
			
  ret = SNextTypeSRsrc(&mySpBlock);
  if (ret)
    return notEnoughHardware; // oups
				
  (*globals).slot = mySpBlock.spSlot;
  (*globals).bt = (struct goblin_bt_regs*)(0xF0000000 |
					   ((unsigned long)mySpBlock.spSlot)<<24 |
					   GOBLIN_BT_OFFSET);

#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'INIT'; 

  (*(*globals).bt).debug = 'SLOT';
  (*(*globals).bt).debug = mySpBlock.spSlot;
#endif

  (*globals).csr = (struct goblin_csr*)(0xF0000000 |
					((unsigned long)mySpBlock.spSlot)<<24 |
					GOBLIN_CSR_OFFSET);

#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'CSR ';
  (*(*globals).bt).debug = (unsigned long)(*globals).csr;
#endif

  // Open the mixer and tell it the type of data it should output. The
  // description includes sample format, sample rate, sample size, number of channels
  // and the size of your optimal interrupt buffer. If a mixer cannot be found that
  // will output this type of data, an error will be returned.

  prefsPtr = *globals->prefsHandle;						// get settings from preferences

  // set to hardware defaults

  globals->hwSettings.flags = 0;
  globals->hwSettings.format = (prefsPtr->sampleSize == k8BitSamples) ? kOffsetBinary : kTwosComplement;
  globals->hwSettings.sampleRate = prefsPtr->sampleRate;
  globals->hwSettings.sampleSize = prefsPtr->sampleSize;
  globals->hwSettings.numChannels = prefsPtr->numChannels;
  globals->hwSettings.sampleCount = kInterruptBufferSamples * 2;

  // open mixer that will output this format
	
  result = OpenMixerSoundComponent(&globals->hwSettings, 0, &globals->sourceComponent);
  if (result != noErr)
    return (result);

  result = SetupHardware(globals);						// setup the hardware to these settings

  if (result == noErr)
    {
      globals->hwInitialized = true;						// hardware is ready to go
      HLock((Handle) globals->prefsHandle);				// lock prefs so we can use them at interrupt time
    }

  return (result);
}

/*	==============================================================================
	GetInfo

	This routine returns information about this output component to the Sound Manager.
	A 4-byte OSType selector is used to determine the type and size of the information
	to return. If the component does not support a selector, it should delegate this
	call on up the chain.

	NOTE: This can be called at interrupt time. However, selectors that return
	a handle will not be called at interrupt time.
	============================================================================== */

pascal ComponentResult __GetInfo(GlobalsPtr globals, SoundSource sourceID,
				 OSType selector, void *infoPtr)
{
  HandleListPtr		listPtr;
  short				*sp;
  UnsignedFixed		*lp;
  Handle				h;
  PreferencesPtr		prefsPtr;
  ComponentResult		result = noErr;

  prefsPtr = *globals->prefsHandle;					// get settings from preferences

  switch (selector)
    {
    case siSampleSize:								// return current sample size
      *((short *) infoPtr) = prefsPtr->sampleSize;
      break;

    case siSampleSizeAvailable:						// return samples sizes available
      h = NewHandle(sizeof(short) * kSampleSizesCount);	// space for sample sizes
      if (h == nil)
	return (MemError());

      listPtr = (HandleListPtr) infoPtr;
      listPtr->count = kSampleSizesCount;			// no. sample sizes in handle
      listPtr->handle = h;						// handle to be returned

      sp = (short *) *h;							// store sample sizes in handle
      *sp++ = k8BitSamples;
      *sp++ = k16BitSamples;
      break;

    case siSampleRate:								// return current sample rate
      *((Fixed *) infoPtr) = prefsPtr->sampleRate;
      break;

    case siSampleRateAvailable:						// return sample rates available
      h = NewHandle(sizeof(UnsignedFixed) * kSampleRatesCount);	// space for sample rates
      if (h == nil)
	return (MemError());

      listPtr = (HandleListPtr) infoPtr;
      listPtr->count = kSampleRatesCount;			// no. sample rates in handle
      listPtr->handle = h;						// handle to be returned

      lp = (UnsignedFixed *) *h;

      // If the hardware can support a range of sample rate values, then the
      // list count should be set to zero and the min and max sample rate values
      // should be stored in the handle.
			
      if (kSupportsSampleRateRange)
	{
	  listPtr->count = 0;
	  *lp++ = kSampleRateMin;					// min
	  *lp++ = kSampleRateMax;					// max
	}
		
      // If the hardware supports a limited set of sample rates, then the list count
      // should be set to the number of sample rates and this list of rates should be
      // stored in the handle.

      else
	{
	  //*lp++ = kSampleRate11;					// store sample rates in handle
	  //*lp++ = kSampleRate22;
	  *lp++ = kSampleRate44;
	}
      break;

    case siNumberChannels:							// return current no. channels
      *((short *) infoPtr) = prefsPtr->numChannels;
      break;

    case siChannelAvailable:						// return channels available
      h = NewHandle(sizeof(short) * kChannelsCount);	// space for channels
      if (h == nil)
	return (MemError());

      listPtr = (HandleListPtr) infoPtr;
      listPtr->count = kChannelsCount;			// no. channels in handle
      listPtr->handle = h;						// handle to be returned

      sp = (short *) *h;							// store channels in handle
      *sp++ = kNumChannelsMono;
      *sp++ = kNumChannelsStereo;
      break;

    case siHardwareVolume:
      *((long *)infoPtr) = prefsPtr->volume;
      break;

      // if you do not handle this selector, then delegate it up the chain
    default:
      result = SoundComponentGetInfo(globals->sourceComponent, sourceID, selector, infoPtr);
      break;

    }

  return (result);
}

/*	==============================================================================
	SetInfo

	This routine sets information about this component. A 4-byte OSType selector is
	used to determine the type and size of the information to apply. If the component
	does not support a selector, it should delegate this call on up the chain.

	NOTE: This can be called at interrupt time.
	============================================================================== */

pascal ComponentResult __SetInfo(GlobalsPtr globals, SoundSource sourceID,
				 OSType selector, void *infoPtr)
{
  PreferencesPtr		prefsPtr;
  ComponentResult		result = noErr;

  prefsPtr = *globals->prefsHandle;					// get settings from preferences

  switch (selector)
    {
    case siSampleSize:								// set sample size
      {
	short	sampleSize = (short) infoPtr;
			
	if ((sampleSize == k8BitSamples) ||			// make sure it is a valid sample size
	    (sampleSize == k16BitSamples))
	  {
	    prefsPtr->sampleSize = sampleSize;		// save new size in prefs
	    globals->prefsChanged = true;			// save prefs on close
	  }
	else
	  result = siInvalidSampleSize;
	break;
      }

    case siSampleRate:								// set sample rate
      {
	UnsignedFixed	sampleRate = (UnsignedFixed) infoPtr;

	if (kSupportsSampleRateRange)				// sample rate range
	  {
	    if ((kSampleRateMin <= sampleRate) && (sampleRate <= kSampleRateMax))	// make sure it is a valid sample rate
	      {
		prefsPtr->sampleRate = sampleRate;	// save new rate in prefs
		globals->prefsChanged = true;		// save prefs on close
	      }
	    else
	      result = siInvalidSampleRate;
	  }
	else
	  {
	    if (/*(sampleRate == kSampleRate11) ||	// make sure it is a valid sample rate
		  (sampleRate == kSampleRate22) ||*/
		(sampleRate == kSampleRate44))
	      {
		prefsPtr->sampleRate = sampleRate;	// save new rate in prefs
		globals->prefsChanged = true;		// save prefs on close
	      }
	    else
	      result = siInvalidSampleSize;
	  }
	break;
      }

    case siNumberChannels:							// set no. channels
      {
	short	numChannels = (short) infoPtr;

	if ((numChannels == kNumChannelsMono) ||	// make sure it is a valid no. channels
	    (numChannels == kNumChannelsStereo))
	  {
	    prefsPtr->numChannels = numChannels;	// save new num channels in prefs
	    globals->prefsChanged = true;			// save prefs on close
	  }
	else
	  result = notEnoughHardware;
	break;
      }

    case siHardwareVolume:
      prefsPtr->volume = (long) infoPtr;			// save volume in prefs
      globals->prefsChanged = true;				// save prefs on close
      result = SetHardwareVolume(globals, prefsPtr->volume);
      break;

      // if you do not handle this selector, then call up the chain
    default:
      result = SoundComponentSetInfo(globals->sourceComponent, sourceID, selector, infoPtr);
      break;
    }

  return (result);
}

/*	==============================================================================
	StartSource

	This routine is used to start sounds playing that are currently paused. It should
	first delegate this call up the chain so the rest of the chain can prepare
	to play this sound. Then, if the hardware is not already started it should be
	turned on.

	NOTE: This can be called at interrupt time.
	============================================================================== */

pascal ComponentResult __StartSource(GlobalsPtr globals, short count, SoundSource *sources)
{
  ComponentResult		result;

  // tell the mixer to start these sources
  result = SoundComponentStartSource(globals->sourceComponent, count, sources);
  if (result != noErr)
    return (result);

  // make sure hardware interrupts are running
  result = StartHardware(globals);

  return (result);
}

/*	==============================================================================
	PlaySourceBuffer

	This routine is used to specify a new sound to play and conditionally start
	the hardware playing that sound.It should first delegate this call up the
	chain so the rest of the chain can prepare to play this sound. Then, if the
	hardware is not already started it should be turned on.

	NOTE: This can be called at interrupt time.
	============================================================================== */

pascal ComponentResult __PlaySourceBuffer(GlobalsPtr globals, SoundSource sourceID, SoundParamBlockPtr pb, long actions)
{
  ComponentResult		result;
	
#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'PLAY';
#endif

  // tell mixer to start playing this new buffer
  result = SoundComponentPlaySourceBuffer(globals->sourceComponent, sourceID, pb, actions);
  if (result != noErr)
    return (result);

  // if the kSourcePaused bit is set, then do not turn on your hardware just yet
  // (the assumption is that StartSource() will later be used to start this sound playing).
  // If this bit is not set, turn your hardware interrupts on.

  if (!(actions & kSourcePaused))
    result = StartHardware(globals);
  
#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'YALP';
  (*(*globals).bt).debug = result;
#endif
  
  return (result);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This routine creates a locked handle in the requested heap.

Handle NewHandleLockClear(long len, Boolean inSystemHeap)	// allocate a new handle, lock it down and clear it
{
  Handle		h;

  if (inSystemHeap)										// we are loaded into the system heap
    {
      ReserveMemSys(len);									// create it low down in system heap
      h = NewHandleSysClear(len);
    }
  else													// we are loaded into the app heap
    {
      h = NewHandleClear(len);							// create our memory there and move it out of the way
      if (h) MoveHHi(h);
    }

  if (h) HLock(h);										// lock it down
  return (h);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This routine gets the preferences from the refCon or the preferences file
// or creates default preferences if it has to.

PreferencesHandle GetPreferences(ComponentInstance self, Boolean inSystemHeap)
{
  Handle					prefsHandle, componentName;
  PreferencesPtr			prefsPtr;
  ComponentDescription	componentDesc;
  OSErr					err;

  prefsHandle = (Handle) GetComponentRefcon((Component) self);	// get prefs from component refcon
  if (prefsHandle)
    return ((PreferencesHandle) prefsHandle);			// valid prefs in refcon, so we are done

  componentName = NewHandle(0);							// make space for name
  if (componentName == nil)
    goto NewNameHandleFailed;

  err = GetComponentInfo((Component) self, &componentDesc, componentName, nil, nil);	// get component name and subtype
  if (err != noErr)
    goto InfoFailed;

  prefsHandle = NewHandleLockClear(sizeof(PreferencesRecord), inSystemHeap);	// create space for prefs handle
  if (prefsHandle == nil)
    goto NewPrefsHandleFailed;

  HUnlock(prefsHandle);									// don't leave prefs handle locked down forever
  HLock(componentName);

  err = GetSoundPreference(componentDesc.componentSubType, (StringPtr) *componentName, prefsHandle);	// get prefs handle from file
  if (err != noErr)										// no file or prefs not in file
    goto GetPrefsFailed;

  if (GetHandleSize(prefsHandle) != sizeof(PreferencesRecord))	// older version of preferences
    goto GetPrefsFailed;								// start with all new preferences

  DisposeHandle(componentName);
  SetComponentRefcon((Component) self, (long) prefsHandle);	// save prefs in refcon

  return ((PreferencesHandle) prefsHandle);				// we are done


  /*	If we end up here, it means that the preferences could not be loaded out of the
	sound preferences file for some reason, so we need to generate some default preferences. */

 GetPrefsFailed:
  DisposeHandle(prefsHandle);
 NewPrefsHandleFailed:
 InfoFailed:
  DisposeHandle(componentName);
 NewNameHandleFailed:

  prefsHandle = NewHandleLockClear(sizeof(PreferencesRecord), inSystemHeap);	// create space for prefs handle
  if (prefsHandle == nil)
    return (nil);

  HUnlock(prefsHandle);									// don't leave prefs handle locked down forever
  prefsPtr = (PreferencesPtr) *prefsHandle;

  prefsPtr->sampleSize = k16BitSamples;//k8BitSamples;					// initialize prefs to defaults
  prefsPtr->sampleRate = kSampleRate44;//kSampleRate22;
  prefsPtr->numChannels = kNumChannelsStereo;
  prefsPtr->volume = (kFullVolume << 16) | kFullVolume;

  SetComponentRefcon((Component) self, (long) prefsHandle);	// save prefs in refcon

  return ((PreferencesHandle) prefsHandle);				// we are done
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This routine saves the hardware globals in the preferences file

void SavePreferences(ComponentInstance self, PreferencesHandle prefsHandle)
{
  Handle					componentName;
  ComponentDescription	componentDesc;
  OSErr					err;

  componentName = NewHandle(0);							// make space for name
  if (componentName == nil)
    goto NewNameHandleFailed;

  err = GetComponentInfo((Component) self, &componentDesc, componentName, nil, nil);	// get component name and subtype
  if (err != noErr)
    goto InfoFailed;

  HLock(componentName);
  err = SetSoundPreference(componentDesc.componentSubType, (StringPtr) *componentName, (Handle) prefsHandle);

 InfoFailed:
  DisposeHandle(componentName);
 NewNameHandleFailed:

  return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Hardware-specific Methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialize the hardware. Our "hardware" just uses the Sound Manager to
// play sounds. Your hardware would probably do something completely different.
//
// We have to find another output component to play sound with, or the Sound Manager
// will try to use our component by default when we call SndNewChannel. We do this
// by searching for another output component, and passing that component to SndNewChannel
// with a flag set telling the Sound Manager to use this component instead of the default. 


OSErr SetupHardware(GlobalsPtr globals)
{
  OSErr					err = noErr;
			
  // host view ; currently mapped to the SRAM, could be anywhere
  // in fact, I'm not sure how MacOS would handle it, but it could be in host memory
  // using the wishbone DMA word-by-word
  // (or using a more sophisticated approach and using block request for 8/16/32/64 bytes)
  (*globals).buf0 = (u_int32_t*)(0xF0000000 |
				 ((unsigned long)(*globals).slot)<<24 |
				 GOBLIN_AUDIOBUFFER_OFFSET);
  (*globals).buf1 = (u_int32_t*)(0xF0000000 |
				 ((unsigned long)(*globals).slot)<<24 |
				 GOBLIN_AUDIOBUFFER_OFFSET |
				 (GOBLIN_AUDIOBUFFER_SIZE >> 1)); // offset by 4 KiB

#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'bufX';
  (*(*globals).bt).debug = (unsigned long)(*globals).buf0;
  (*(*globals).bt).debug = (unsigned long)(*globals).buf1;
  (*(*globals).bt).debug = brev((unsigned long)&(*(*globals).csr).goblin_goblin_audio_buf0_addr);
  (*(*globals).bt).debug = brev((unsigned long)&(*(*globals).csr).goblin_goblin_audio_buf1_addr);
#endif

  // HW view (internal Wishbone addresses, so w/o the slot number)
  (*(*globals).csr).goblin_goblin_audio_buf0_addr = brev((unsigned long)(0xF0000000 |
									 GOBLIN_AUDIOBUFFER_OFFSET));
  (*(*globals).csr).goblin_goblin_audio_buf1_addr = brev((unsigned long)(0xF0000000 |
									 GOBLIN_AUDIOBUFFER_OFFSET |
									 (GOBLIN_AUDIOBUFFER_SIZE >> 1)));

  (*(*globals).siqel).sqType = sIQType;
  (*(*globals).siqel).sqPrio = 6;
  (*(*globals).siqel).sqAddr = irqTrampoline;
  (*(*globals).siqel).sqParm = (long)globals;
	
  SIntInstall((*globals).siqel, (*globals).slot);

  return (err);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Release the hardware. 

void ReleaseHardware(GlobalsPtr globals)
{
  StopHardware(globals);										// make sure hardware is off
	
  // remove interrupt
  SIntRemove((*globals).siqel, (*globals).slot);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Turn on hardware interrupts.

OSErr StartHardware(GlobalsPtr globals)
{
  OSErr	err = noErr;

  if (!globals->hwInterruptsOn)
    {
      globals->hwInterruptsOn = true;							// the hardware will soon be on
		
      (*(*globals).csr).goblin_goblin_audio_irqctrl = brev(0x3); // enable interrup, clear previous
		
      (*(*globals).csr).goblin_goblin_audio_buf1_size = brev(1); // make pretend
      (*globals).buf1[0] = 0; // silence
		
      (*globals).lastbuf = 1;
		
      (*(*globals).csr).goblin_goblin_audio_ctrl = brev(0x00010101); // auto-stop play buf1, this will just force an interrupt
		
		
    }

  return (err);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Turn off hardware interrupts.

void StopHardware(GlobalsPtr globals)
{
	
  // stop playing
  // race condition ?
  (*(*globals).csr).goblin_goblin_audio_ctrl = (*(*globals).csr).goblin_goblin_audio_ctrl | brev(0x00010000); // add auto-stop
	
  if (globals->hwInterruptsOn)
    {	
      (*(*globals).csr).goblin_goblin_audio_irqctrl = brev(0x2); // clear low-order bit (enable) & clear irq (second bit)

      globals->hwInterruptsOn = false;						// the hardware is now off
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Temporarily suspend hardware interrupts, so the interrupt routine can work in peace.

void SuspendHardware(GlobalsPtr globals)
{
  if (globals->hwInterruptsOn)
    {
      // Suspend hardware interrupts here
      (*(*globals).csr).goblin_goblin_audio_irqctrl = 0; // clear low-order bit (enable)
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Resume hardware interrupts after they were suspended.

void ResumeHardware(GlobalsPtr globals)
{
  if (globals->hwInterruptsOn)
    {
      (*(*globals).csr).goblin_goblin_audio_irqctrl = brev(0x1); // set low-order bit (enable)
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Set hardware volume.

OSErr SetHardwareVolume(GlobalsPtr globals, unsigned long volume)
{
  OSErr		err = noErr;
	
  // fixme TODO
	
  return (err);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This routine is called every hardware interrupt to fill the hardware
// with audio data. First it should suspend interrupts so it will not
// be interrupted again. Then it should get more data from the source mixer,
// and copy the data to the hardware. On the way out, if all data was copied,
// try to get some more so it will be available immediately next interrupt.
/*
  pascal void InterruptRoutine(SndChannelPtr chan, SndCommand *cmd)
  {
  #pragma unused (chan)

  GlobalsPtr				globals;
  SoundComponentDataPtr	sourceDataPtr;

  globals = (GlobalsPtr) cmd->param2;						// get globals from command

  SuspendHardware(globals);								// suspend interrupts while we are processing

  sourceDataPtr = GetMoreSource(globals);					// get source from mixer
  if (sourceDataPtr == nil)								// no more source
  {
  StopHardware(globals);								// turn hardware off
  return;
  }

  CopySamplesToHardware(globals, sourceDataPtr);			// fulfill hardware request

  //	Normally, you will want to check to see if you have run out
  // 	of data here and get more right away so you will be ready for
  //	the next interrupt. This example does not have any hardware
  //	to copy the data to, so it leaves the data in the mixer buffer and
  //	thus cannot call for more until it has been played.

  //	if (sourceDataPtr->sampleCount == 0)					// exhausted the source
  //		sourceDataPtr = GetMoreSource(globals);				// get more for next time

  ResumeHardware(globals);								// resume interrupts
  }
*/
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This routine returns the data pointer to your mixer source. If there
// is no source or it is empty, it will call down the chain to fill it up.

SoundComponentDataPtr GetMoreSource(GlobalsPtr globals)
{
  ComponentResult			result;
  SoundComponentDataPtr	sourceDataPtr = globals->sourceDataPtr;

  if ((sourceDataPtr == nil) || (sourceDataPtr->sampleCount == 0))	// no data - better get some
    {
      result = SoundComponentGetSourceData(globals->sourceComponent, &globals->sourceDataPtr);
      sourceDataPtr = globals->sourceDataPtr;

      if ((result != noErr) ||							// error getting data
	  (sourceDataPtr == nil) ||						// source has no data pointer to return
	  (sourceDataPtr->sampleCount == 0))				// source has no more data
	{
	  return (nil);									// stop the presses
	}
    }

#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'srcd';
  (*(*globals).bt).debug = sourceDataPtr->numChannels;
  (*(*globals).bt).debug = sourceDataPtr->sampleSize;
  (*(*globals).bt).debug = sourceDataPtr->sampleRate;
  (*(*globals).bt).debug = sourceDataPtr->sampleCount;
#endif
	
  return (sourceDataPtr);									// return pointer to source
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Example-specific Methods
//
// These routines are only needed to make this example work and as such should not be
// used in your sound component.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This routine copies the data returned by the mixer to the hardware.

static void CopySamplesToHardware(GlobalsPtr globals, SoundComponentDataPtr sourceDataPtr)
{
  OSErr			err = noErr;
  const unsigned long status = brev((*(*globals).csr).goblin_goblin_audio_ctrl);
  const int sampleBytes = sourceDataPtr->sampleSize >> 3;
  const int sampleChannel = sourceDataPtr->numChannels;
	
  if (status & 0x0100) {
#ifdef BT_DEBUG
    (*(*globals).bt).debug = 'cont';
#endif
    // already playing, so the 'lastbuf' is empty
    // and we are playing lastbuf xor 1
    switch ((*globals).lastbuf) {
    case 0:
      BlockMove(sourceDataPtr->buffer, (void*)((*globals).buf0), sampleBytes * sampleChannel * sourceDataPtr->sampleCount);
      (*(*globals).csr).goblin_goblin_audio_buf0_size = brev(sourceDataPtr->sampleCount);
      (*globals).lastbuf = 1;
      //(*(*globals).csr).goblin_goblin_audio_ctrl = brev(0x0100); // play buf0 // redundant ?
      break;
    case 1:
    default:
      BlockMove(sourceDataPtr->buffer, (void*)((*globals).buf1), sampleBytes * sampleChannel * sourceDataPtr->sampleCount);
      (*(*globals).csr).goblin_goblin_audio_buf1_size = brev(sourceDataPtr->sampleCount);
      (*globals).lastbuf = 0;
      //(*(*globals).csr).goblin_goblin_audio_ctrl = brev(0x0101); // play buf1 // redundant ?
      break;
    }
    sourceDataPtr->sampleCount = 0;							// sound has been played
  } else {
    // not yet playing, put half of the samples in each buffer
    // so that when the first buffer is empty, we'll be playing the second while reloading
    const long buf0count = sourceDataPtr->sampleCount / 2;
    const long buf1count = sourceDataPtr->sampleCount - buf0count;
#ifdef BT_DEBUG
    (*(*globals).bt).debug = 'new ';
    (*(*globals).bt).debug = buf0count;
    (*(*globals).bt).debug = buf1count;
#endif
    BlockMove(sourceDataPtr->buffer,                                           (void*)((*globals).buf0), sampleBytes * sampleChannel * buf0count);
    BlockMove(sourceDataPtr->buffer + sampleBytes * sampleChannel * buf0count, (void*)((*globals).buf1), sampleBytes * sampleChannel * buf1count);
    (*(*globals).csr).goblin_goblin_audio_buf0_size = brev(buf0count);
    (*(*globals).csr).goblin_goblin_audio_buf1_size = brev(buf1count);
    (*globals).lastbuf = 0;
    sourceDataPtr->sampleCount = 0;							// sound has been played
    // now play for real
    (*(*globals).csr).goblin_goblin_audio_buf_desc = brev((sourceDataPtr->sampleSize == k8BitSamples ? 0x1 : 0x0) | // default 16-bits
							  (sampleChannel == 1 ? 0x40 : 0) | // default stereo
							  (sourceDataPtr->format == kOffsetBinary ? 0x0080 : 0x0000)); // otherwise assume kTwosComplement
    (*(*globals).csr).goblin_goblin_audio_ctrl = brev(0x0100); // play buf0
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Hardware IRQ handling

short irqFct(GlobalsPtr globals);
#pragma parameter __D0 irqFct(__A1)
short irqFct(GlobalsPtr globals)
{
  SoundComponentDataPtr	sourceDataPtr;
  long irqstatus;
	
#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'irq ';
#endif
	
  // first, is that one of ours ?
  irqstatus = brev((*(*globals).csr).goblin_goblin_audio_irqstatus);
  if ((irqstatus & 1) == 0) {
    // nope
    return 0;
  }

#ifdef BT_DEBUG
  (*(*globals).bt).debug = 'irqA';
#endif
	
  // yes, ours, clear & suspend it before dealing with it
  (*(*globals).csr).goblin_goblin_audio_irqctrl = brev(0x2);

  sourceDataPtr = GetMoreSource(globals);					// get source from mixer
  if (sourceDataPtr == nil)								// no more source
    {
      StopHardware(globals);								// turn hardware off
    }
  else 
    {
      CopySamplesToHardware(globals, sourceDataPtr);			// fulfill hardware request

      (*(*globals).csr).goblin_goblin_audio_irqctrl = brev(0x1); // restart interrupt
    }
	
  return 1;
}
// only save what needs to preserve, then call the 'real' function
asm pascal void irqTrampoline(void)
{
  MOVEM.L   D1-D6/A0/A2-A5,-(A7)
    BSR irqFct
    MOVEM.L   (A7)+,D1-D6/A0/A2-A5
    RTS
    }
