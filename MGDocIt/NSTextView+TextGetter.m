//
//  NSTextView+TextGetter.m
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import "NSTextView+TextGetter.h"
#import "NSString+TextGetter.h"

@implementation NSTextView (TextGetter)

-(NSInteger) currentCursorLocation
{
	return [[[self selectedRanges] objectAtIndex:0] rangeValue].location;
}


-(MGTextResult *) textResultOfCurrentLine
{
	return [self.textStorage.string textResultOfCurrentLineCurrentLocation: [self currentCursorLocation]];
}

@end
