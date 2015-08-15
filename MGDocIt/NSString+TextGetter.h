//
//  NSString+TextGetter.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTextResult.h"
NS_ASSUME_NONNULL_BEGIN
@interface NSString (TextGetter)

-(MGTextResult * _Nullable) textResultOfCurrentLineCurrentLocation:(NSInteger)location;
//-(MGTextResult * _Nullable) textResultOfPreviousLineCurrentLocation:(NSInteger) location;
//-(MGTextResult * _Nullable) textResultOfNextLineCurrentLocation:(NSInteger) location;

//-(MGTextResult * _Nullable) textResultUntilNextString:(NSString *)findString currentLocation:(NSInteger)location;
//
//
//-(MGTextResult * _Nullable) textResultWithPairOpenString:(NSString *)open
//									  closeString:(NSString *)close
//								  currentLocation:(NSInteger)location;
//
//-(MGTextResult * _Nullable) textResultMatchPartWithPairOpenString:(NSString *)open
//											   closeString:(NSString *)close
//										   currentLocation:(NSInteger)location;
//
//-(MGTextResult * _Nullable) textResultToEndOfFileCurrentLocation:(NSInteger)location;


@end
NS_ASSUME_NONNULL_END