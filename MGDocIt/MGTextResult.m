//
//  MGTextResult.m
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import "MGTextResult.h"

@implementation MGTextResult

-(instancetype) initWithString:(NSString *)aString range:(NSRange) aRange
{
	self = [super init];
	if (self)
	{
		_range = aRange;
		_string = aString;
	}
	return self;
}


-( NSString * _Nonnull) description
{
	return [NSString stringWithFormat:@"%@ at %ld with length %ld", self.string, self.range.location, self.range.length];
}

@end
