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

-(MGTextResult *) textResultOfPreviousLine
{
	return [self.textStorage.string textResultOfPreviousLineCurrentLocation:[self currentCursorLocation]];
}
-(MGTextResult *) textResultOfNextLine
{
	return [self.textStorage.string textResultOfNextLineCurrentLocation:[self currentCursorLocation]];
}

//-(MGTextResult *) textResultUntilNextString:(NSString *)findString
//{
//	return [self.textStorage.string vv_textResultUntilNextString:findString currentLocation:[self currentCursorLocation]];
//}
//
//-(MGTextResult *) textResultWithPairOpenString:(NSString *)open closeString:(NSString *)close
//{
//	return [self.textStorage.string vv_textResultWithPairOpenString:open closeString:close currentLocation:[self currentCursorLocation]];
//}
//
//-(MGTextResult *) textResultToEndOfFile
//{
//	return [self.textStorage.string vv_textResultToEndOfFileCurrentLocation:[self currentCursorLocation]];
//}


@end
