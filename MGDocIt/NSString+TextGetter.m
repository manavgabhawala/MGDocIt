//
//  NSString+TextGetter.m
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import "NSString+TextGetter.h"

@implementation NSString (TextGetter)

-(MGTextResult *) textResultOfCurrentLineCurrentLocation:(NSInteger)location;
{
	NSUInteger cursorLocation = location;
	NSRange frontRange = NSMakeRange(0, cursorLocation);
	NSRange frontPart = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:frontRange];
	if (frontPart.location == NSNotFound)
	{
		frontPart = NSMakeRange(0, 0);
	}
	NSUInteger startingPoint = frontPart.location + frontPart.length;
	NSRange lineRange = NSMakeRange(startingPoint, cursorLocation - startingPoint);
	if (lineRange.location >= [self length] && NSMaxRange(lineRange) >= [self length])
	{
		return nil;
	}
	NSString *line = [self substringWithRange: lineRange];
	
	return [[MGTextResult alloc] initWithString:line range:lineRange];
}

@end
