//
//  NKApiHelper.m
//  nk-common
//
//  Created by jack on 6/13/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import "JKHelper.h"

//------------------------------------------------------------------------------

@implementation NSNull (NKApi)
- (NSString*) noEmptyString
{
    return nil;
}
@end


//------------------------------------------------------------------------------
@implementation NSString (NKApi)
- (NSString*) noEmptyString
{
    if ([self isEqualToString:@""]) {
        return nil;
    }else{
        return self;
    }
}

@end
