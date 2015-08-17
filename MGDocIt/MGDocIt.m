//
//  MGDocIt.m
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import "MGDocIt.h"
#import "MGTextResult.h"
#import "NSTextView+TextGetter.h"
#import "MGDocIt-Swift.h"
#include <Carbon/Carbon.h> /* For kVK_ constants, and TIS functions. */

/** Returns string representation of key, if it is printable.
 * Ownership follows the Create Rule; that is, it is the caller's
 * responsibility to release the returned object. */
CFStringRef createStringForKey(CGKeyCode keyCode)
{
	TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
	CFDataRef layoutData =
	TISGetInputSourceProperty(currentKeyboard,
							  kTISPropertyUnicodeKeyLayoutData);
	const UCKeyboardLayout *keyboardLayout =
	(const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
	
	UInt32 keysDown = 0;
	UniChar chars[4];
	UniCharCount realLength;
	
	UCKeyTranslate(keyboardLayout,
				   keyCode,
				   kUCKeyActionDisplay,
				   0,
				   LMGetKbdType(),
				   kUCKeyTranslateNoDeadKeysBit,
				   &keysDown,
				   sizeof(chars) / sizeof(chars[0]),
				   &realLength,
				   chars);
	CFRelease(currentKeyboard);
	
	return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

/** Returns key code for given character via the above function, or UINT16_MAX
 * on error. */
CGKeyCode keyCodeForChar(const char c)
{
	static CFMutableDictionaryRef charToCodeDict = NULL;
	CGKeyCode code;
	UniChar character = c;
	CFStringRef charStr = NULL;
	
	/* Generate table of keycodes and characters. */
	if (charToCodeDict == NULL) {
		size_t i;
		charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
												   128,
												   &kCFCopyStringDictionaryKeyCallBacks,
												   NULL);
		if (charToCodeDict == NULL) return UINT16_MAX;
		
		/* Loop through every keycode (0 - 127) to find its current mapping. */
		for (i = 0; i < 128; ++i) {
			CFStringRef string = createStringForKey((CGKeyCode)i);
			if (string != NULL) {
				CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
				CFRelease(string);
			}
		}
	}
	
	charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
	
	/* Our values may be NULL (0), so we need to use this function. */
	if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
									   (const void **)&code)) {
		code = UINT16_MAX;
	}
	
	CFRelease(charStr);
	return code;
}


@interface MGDocIt()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, weak, nullable) NSObject * currentController;

@end

@implementation MGDocIt

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
		self.lock = [[NSLock alloc] init];
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    // removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
	// Now inject code into this process using nc observers.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textStorageDidChange:)
												 name:NSTextDidChangeNotification
											   object:nil];
	
	// Create menu items, initialize UI, etc.
    // Sample Menu Item:
//    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
//    if (menuItem) {
//        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
//        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
//        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
//        [actionMenuItem setTarget:self];
//        [[menuItem submenu] addItem:actionMenuItem];
//    }
}

- (void)dealloc
{
	if (self.mainMonitor)
	{
		[NSEvent removeMonitor:self.mainMonitor];
	}
	self.mainMonitor = nil;
 	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) textStorageDidChange: (NSNotification *) notif
{
	if ([notif.object isKindOfClass:[NSTextView class]])
	{
		if (![[self.currentController valueForKey:@"window"] isEqual:[NSApp keyWindow]])
		{
			NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
			for (id controller in workspaceWindowControllers)
			{
				if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]])
				{
					self.currentController = controller;
				}
			}
		}
		NSURL *fileURL = [[self.currentController valueForKey:@"_lastObservedEditorDocument"] valueForKey:@"_fileURL"];
		if (fileURL)
		{
			NSTextView *textView = (NSTextView *)notif.object;
			[self handleStorageChange:fileURL textStorage:textView];
		}
	}
}

-(CGKeyCode) keyCodeForChar:(const char) c
{
	return keyCodeForChar(c);
}


-(NSArray<MGCXToken *> *) tokenizeTranslationUnit: (CXTranslationUnit) unit withRange: (CXSourceRange) range
{
	CXToken *tokens;
	unsigned int numTokens;
	clang_tokenize(unit, range, &tokens, &numTokens);
	NSMutableArray<MGCXToken *> *array = [[NSMutableArray alloc] initWithCapacity:numTokens];
	for (int i = 0; i < numTokens; ++i)
	{
		CXToken currentToken = *(tokens + i);
		[array addObject:[[MGCXToken alloc] initWithToken:currentToken]];
	}
	if (numTokens)
	{
		clang_disposeTokens(unit, tokens, numTokens);
	}
	return array;
}

-(void) performPasteAction
{
	[NSApp sendAction:@selector(paste:) to:nil from:self];
}

@end
