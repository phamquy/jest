//
//  RKDynamicMapping+NKExternalize.m
//  nk-common
//
//  Created by jack on 6/18/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import "RKDynamicMapping+Jest.h"

@implementation RKDynamicMapping(NKExternalize)
- (void) addMatcherForKeyPath: (NSString*) keyPath
                    expectVal: (NSString*) expectVal
                     usingMap: (RKObjectMapping*) targetMap
{    
    RKObjectMappingMatcher* objMatcher = [RKObjectMappingMatcher
                                          matcherWithKeyPath:keyPath
                                          expectedValue:expectVal
                                          objectMapping:targetMap];
    [self addMatcher:objMatcher];
}
@end
