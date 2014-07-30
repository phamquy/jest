//
//  RKObjectMapping+NKExternalize.h
//  nk-common
//
//  Created by jack on 6/18/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
@class RKObjectMapping;

@interface RKObjectMapping (NKExternalize)
- (void) addRelationshipFrom: (NSString*) fromPath
                      toPath: (NSString*) toPath
                    usingMap: (RKMapping*)targetMap;

@end
