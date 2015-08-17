//
//  MGCXToken.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 17/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Index.h"

@interface MGCXToken : NSObject

-(instancetype) initWithToken:(CXToken) token;

@property (nonatomic) CXToken token;

@end
