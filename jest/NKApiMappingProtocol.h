//
//  NKApiMapping.h
//  nk-common
//
//  Created by jack on 6/12/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//
#import <RestKit/RestKit.h>
//@class RKResponseDescriptor;

@protocol NKApiMapper <NSObject>
@required
/**
  Return response descriptor for a given request. This method inspects attribute of the request such as path, HTTP method, or even parameter have enough information about what response the client should expect to receive, and create response descriptor to mapp server response to internal data model.

 @param request The request
 
 @return a `NKResponseDescriptor` object
 */
- (NSArray*) responseDescriptorForRequest:(NSURLRequest*) request;
- (NSArray*) requestDescriptorsForClass: (Class) sourceClass
                                 method: (RKRequestMethod) method;

@optional
/**
 Return the every descriptors for `NKObjectManager`, instead of generate response descriptor for each request, mapper can return the array of descriptors that describe every response mapper of api. This methods will be suilable for a well design rest api.
 */
- (NSArray*) responseDescriptors;
- (NSArray*) responseDescriptorsForPath:(NSString*) path;
- (NSArray*) requestDescriptors;

@end

typedef id<NKApiMapper> NKApiMapperImpl;