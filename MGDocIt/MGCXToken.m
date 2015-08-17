//
//  MGCXToken.m
//  MGDocIt
//
//  Created by Manav Gabhawala on 17/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import "MGCXToken.h"

@implementation MGCXToken

-(instancetype) initWithToken:(CXToken)token
{
	self = [super init];
	if (self)
	{
		self.token = token;
	}
	return self;
}

@end
