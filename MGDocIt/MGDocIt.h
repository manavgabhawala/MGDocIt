//
//  MGDocIt.h
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

#import <AppKit/AppKit.h>



NS_ASSUME_NONNULL_BEGIN

@class MGDocIt;

static MGDocIt *sharedPlugin;

@interface MGDocIt : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

-(CGKeyCode) keyCodeForChar:(const char) c;


@property (nonatomic, strong, readonly) NSBundle *bundle;

@property (atomic, strong) NSLock *lock;

@property (nonatomic, strong, nullable) id eventMonitor;

@property (nonatomic, strong, nullable) id mainMonitor;
@property (atomic) BOOL lastCharTyped;

@end

NS_ASSUME_NONNULL_END