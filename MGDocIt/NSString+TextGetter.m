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
	NSInteger curseLocation = location;
	NSRange range = NSMakeRange(0, curseLocation);
	NSRange thisLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:range];
	
	NSString *line = nil;
	if (thisLineRange.location != NSNotFound)
	{
		NSRange lineRange = NSMakeRange(thisLineRange.location + 1, curseLocation - thisLineRange.location - 1);
		if (lineRange.location < [self length] && NSMaxRange(lineRange) < [self length])
		{
			line = [self substringWithRange:lineRange];
			return [[MGTextResult alloc] initWithString:line range:lineRange];
		}
	}
	return nil;
}

-(MGTextResult *) textResultOfPreviousLineCurrentLocation:(NSInteger) location
{
	NSInteger curseLocation = location;
	NSRange range = NSMakeRange(0, curseLocation);
	NSRange thisLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:range];
	
	NSString *line = nil;
	if (thisLineRange.location != NSNotFound)
	{
		range = NSMakeRange(0, thisLineRange.location);
		NSRange previousLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:range];
		
		if (previousLineRange.location != NSNotFound)
		{
			NSRange lineRange = NSMakeRange(previousLineRange.location + 1, thisLineRange.location - previousLineRange.location);
			if (lineRange.location < [self length] && NSMaxRange(lineRange) < [self length])
			{
				line = [self substringWithRange:lineRange];
				return [[MGTextResult alloc] initWithString:line range:lineRange];
			}
		}
	}
	return nil;
}


-(MGTextResult *) textResultOfNextLineCurrentLocation:(NSInteger) location
{
	NSInteger curseLocation = location;
	NSRange range = NSMakeRange(curseLocation, self.length - curseLocation);
	NSRange thisLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:0 range:range];
	
	NSString *line = nil;
	if (thisLineRange.location != NSNotFound)
	{
		range = NSMakeRange(thisLineRange.location + 1, self.length - thisLineRange.location - 1);
		NSRange nextLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:0 range:range];
		if (nextLineRange.location != NSNotFound)
		{
			NSRange lineRange = NSMakeRange(thisLineRange.location + 1, NSMaxRange(nextLineRange) - NSMaxRange(thisLineRange));
			if (lineRange.location < [self length] && NSMaxRange(lineRange) < [self length])
			{
				line = [self substringWithRange:lineRange];
				return [[MGTextResult alloc] initWithString:line range:lineRange];
			}
		}
	}
	return nil;
}

//-(MGTextResult *) textResultUntilNextString:(NSString *)findString currentLocation:(NSInteger)location
//{
//	
//	self rangeOfString:<#(nonnull NSString *)#> options:<#(NSStringCompareOptions)#> range:<#(NSRange)#>
//	
//	NSInteger curseLocation = location;
//	
//	NSRange range = NSMakeRange(curseLocation, self.length - curseLocation);
//	NSRange nextLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:0 range:range];
//	NSRange rangeToString = [self rangeOfString:findString options:0 range:range];
//	
//	NSString *line = nil;
//	if (nextLineRange.location != NSNotFound && rangeToString.location != NSNotFound && nextLineRange.location <= rangeToString.location)
//	{
//		NSRange lineRange = NSMakeRange(nextLineRange.location + 1, rangeToString.location - nextLineRange.location);
//		if (lineRange.location < [self length] && NSMaxRange(lineRange) < [self length])
//		{
//			line = [self substringWithRange:lineRange];
//			return [[MGTextResult alloc] initWithString:line range:lineRange];
//		}
//	}
//	return nil;
//
//}
//
//
//-(MGTextResult *) textResultWithPairOpenString:(NSString *)open
//											 closeString:(NSString *)close
//										 currentLocation:(NSInteger)location
//{
//	
//}
//
//-(MGTextResult *) textResultMatchPartWithPairOpenString:(NSString *)open
//													  closeString:(NSString *)close
//												  currentLocation:(NSInteger)location
//{
//	
//}
//
//-(MGTextResult *) textResultToEndOfFileCurrentLocation:(NSInteger)location
//{
//	
//}



@end
