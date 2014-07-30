//
//  RKObjectMapping+NKExternalize.m
//  nk-common
//
//  Created by jack on 6/18/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import "RKObjectMapping+NKExternalize.h"

@implementation RKObjectMapping (NKExternalize)
//------------------------------------------------------------------------------
- (void) addRelationshipFrom: (NSString*) fromPath
                      toPath: (NSString*) toPath
                    usingMap: (RKMapping*)targetMap
{
    if (targetMap) {
        [self addPropertyMapping:[RKRelationshipMapping
                                  relationshipMappingFromKeyPath:fromPath
                                  toKeyPath:toPath
                                  withMapping:targetMap]];
    }else{
        [self addPropertyMapping:[RKAttributeMapping
                                  attributeMappingFromKeyPath:fromPath
                                  toKeyPath:toPath]];
    }
}
@end
