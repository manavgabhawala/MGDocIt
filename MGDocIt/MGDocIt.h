//
//  MGDocIt.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MGCXToken.h"
#import "Index.h"

NS_ASSUME_NONNULL_BEGIN

@class MGDocIt;

static MGDocIt *sharedPlugin;

@interface MGDocIt : NSObject

/// The shared plugin instance
+ (instancetype)sharedPlugin;

/// Main initializer for Xcode plugin
- (id)initWithBundle:(NSBundle *)plugin;

/// The bundle for the Xcode plugin
@property (nonatomic, strong, readonly) NSBundle *bundle;


/// This function triggers a paste command in the app using a Keyboard Preference agnostic method.
-(void) performPasteAction;

/**
 *	Calculates and returns the keycode for a particular character.
 *
 *	@param c The character for which to calculate the keycode.
 *
 *	@returns A CGKeyCode that represents the character in a keyboard preference agnostic manner.
 */
-(CGKeyCode) keyCodeForChar:(const char) c;

/**
 *	Tokenizes an entire range of a translation unit and returns an array of the associated tokens.
 *
 *	@param unit The translation unit to tokenize
 *	@param range The range in the unit to tokenize
 *
 *	@returns An array of tokens for the unit inside the range provided.
 */
-(NSArray<MGCXToken *> *) tokenizeTranslationUnit: (CXTranslationUnit) unit withRange: (CXSourceRange) range;


/// This lock provides a mutual exclusion in that only one notification of a text storage change is processed at a time. This protects against multiple simulatenous notifications.
@property (atomic, strong) NSLock *lock;

/// This event monitor is used so that the paste operation only occurs after the trigger string is deleted.
@property (nonatomic, strong, nullable) id eventMonitor;

/// This monitor is used to track the last key entered. Only if it matches with the last character of the trigger string will a trigger be executed so that common keys like delete and undo/redo work properly.
@property (nonatomic, strong, nullable) id mainMonitor;
/// This boolean is set by the `mainMonitor` to true whenever the last character typed matches the last character of the trigger string and false otherwise.
@property (atomic) BOOL lastCharTyped;

@end

NS_ASSUME_NONNULL_END