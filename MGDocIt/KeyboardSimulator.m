//
//  KeyboardSimulator.m
//  MGDocIt
//
//  Created by Manav Gabhawala on 15/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import "KeyboardSimulator.h"

@interface KeyboardSimulator()
{
	CGEventSourceRef _source;
	CGEventTapLocation _location;
}
@end

@implementation KeyboardSimulator

+(instancetype) defaultSimulator
{
	static dispatch_once_t onceToken;
	static KeyboardSimulator * instance;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

-(void) beginKeyboardEvents
{
	_source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
	_location = kCGHIDEventTap;
}

-(void) sendKeyCode:(NSInteger)keyCode
{
	[self sendKeyCode:keyCode withModifier:0];
}

-(void) sendKeyCode:(NSInteger)keyCode withModifierCommand:(BOOL)command
				alt:(BOOL)alt
			  shift:(BOOL)shift
			control:(BOOL)control
{
	NSInteger modifier = 0;
	if (command)
	{
		modifier = modifier ^ kCGEventFlagMaskCommand;
	}
	if (alt)
	{
		modifier = modifier ^ kCGEventFlagMaskAlternate;
	}
	if (shift)
	{
		modifier = modifier ^ kCGEventFlagMaskShift;
	}
	if (control)
	{
		modifier = modifier ^ kCGEventFlagMaskControl;
	}
	[self sendKeyCode:keyCode withModifier:modifier];
}

-(void) sendKeyCode:(NSInteger)keyCode withModifier:(NSInteger)modifierMask
{
	NSAssert(_source != NULL, @"You should call -beginKeyboardEvents before sending a key event");
	CGEventRef event;
	event = CGEventCreateKeyboardEvent(_source, keyCode, true);
	CGEventSetFlags(event, modifierMask);
	CGEventPost(_location, event);
	CFRelease(event);
	event = CGEventCreateKeyboardEvent(_source, keyCode, false);
	CGEventSetFlags(event, modifierMask);
	CGEventPost(_location, event);
	CFRelease(event);
}

-(void) endKeyboardEvents
{
	NSAssert(_source != NULL, @"You should call -beginKeyboardEvents before end current keyboard event");
	CFRelease(_source);
	_source = nil;
}


@end
