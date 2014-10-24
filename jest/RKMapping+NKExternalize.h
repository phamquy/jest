//
//  NKm.h
//  nk-common
//
//  Created by jack on 6/18/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class RKMapping;

@interface RKMapping (NKExternalize)
+ (RKMapping*) responseMapFromDictionary:(NSDictionary*) mapDict;
+ (RKMapping*) requestMapFromDictionary:(NSDictionary*) mapDict;
@end
