//
//  NKApiMapping.h
//  nk-common
//
//  Created by jack on 6/12/14.
//  Copyright (c) 2014 Jest. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.



#import <RestKit/RestKit.h>

@protocol JKApiMapper <NSObject>
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

typedef id<JKApiMapper> JKApiMapperImpl;