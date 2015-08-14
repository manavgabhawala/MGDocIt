//
//  NSTextView+TextGetter.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGTextResult.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSTextView (TextGetter)

-(NSInteger) currentCursorLocation;
-(MGTextResult * _Nullable) textResultOfCurrentLine;
-(MGTextResult * _Nullable) textResultOfPreviousLine;
-(MGTextResult * _Nullable) textResultOfNextLine;


//-(MGTextResult * _Nullable) textResultUntilNextString:(NSString *)findString;
//-(MGTextResult * _Nullable) textResultWithPairOpenString:(NSString *)open closeString:(NSString *)close;
//-(MGTextResult * _Nullable) textResultToEndOfFile;


@end
NS_ASSUME_NONNULL_END