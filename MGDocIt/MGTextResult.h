//
//  MGTextResult.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGTextResult : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *string;

-(instancetype) initWithString:(NSString *)aString range: (NSRange) aRange;


@end

NS_ASSUME_NONNULL_END