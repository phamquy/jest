//
//  RKDynamicMapping+NKExternalize.h
//  nk-common
//
//  Created by jack on 6/18/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface RKDynamicMapping(NKExternalize)
- (void) addMatcherForKeyPath: (NSString*) keyPath
                    expectVal: (NSString*) expectVal
                     usingMap: (RKObjectMapping*) targetMap;

@end
