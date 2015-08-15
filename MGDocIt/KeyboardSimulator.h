//
//  KeyboardSimulator.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 15/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface KeyboardSimulator : NSObject

+(instancetype) defaultSimulator;

-(void) beginKeyboardEvents;

-(void) sendKeyCode:(NSInteger)keyCode;

-(void) sendKeyCode:(NSInteger)keyCode withModifierCommand:(BOOL)command
				alt:(BOOL)alt
			  shift:(BOOL)shift
			control:(BOOL)control;

//-(void) sendKeyCode:(NSInteger)keyCode withModifier:(NSInteger)modifierMask;

-(void) endKeyboardEvents;


@end
NS_ASSUME_NONNULL_END