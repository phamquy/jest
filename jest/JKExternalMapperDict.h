//
//  NKExternalMapperDict.h
//  nk-common
//
//  Created by jack on 6/17/14.
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
/**
 This header file contains dictionary key for json descriptor
 */

#pragma mark Top Level Keys

#define NKDescriptorRequests        @"requests"
#define NKDescriptorPath            @"path"
#define NKDescriptorKeyPath         @"keyPath"
#define NKDescriptorRootMap         @"root-map-ref"
#define NKDescriptorStatusCodes     @"statusCodes"
#define NKDescriptorMethod          @"method"
#define NKDescriptorMaps            @"maps"


#pragma mark - Map Dictionary Keys

#define NKDescriptorResponseDecs            @"responseDescriptors"
#define NKDescriptorRequestDecs             @"requestDescriptors"

#define NKDescriptorMapId                   @"id"
#define NKDescriptorMapIsEntity             @"entity"
#define NKDescriptorMapTargetName           @"targetName"
#define NKDescriptorMapSourceName           @"sourceName"
#define NKDescriptorMapAttributes           @"attributes"
#define NKDescriptorMapKeyAttribute         @"keyAttribute"
#define NKDescriptorMapForceCollection      @"forceCollection"
#define NKDescriptorMapDynamic              @"dynamic"
#define NKDescriptorMapIdentification       @"identifications"
#define NKDescriptorMapRelationships        @"relationships"
#define NKDescriptorMapRelFrom              @"from"
#define NKDescriptorMapRelTo                @"to"
#define NKDescriptorMapMapRef               @"map-ref"
#define NKDescriptorMapMatchers             @"matchers"
#define NKDescriptorMapMatcherExpect        @"expectValue"


#pragma mark - Map Constant

// HTTP Methods
#define NKDescriptorMethodPOST              @"POST"
#define NKDescriptorMethodGET               @"GET"
#define NKDescriptorMethodDELETE            @"DELETE"
#define NKDescriptorMethodUPDATE            @"UPDATE"

// HTTP status code
#define NKDescriptorStatus2XX               @"2XX"
#define NKDescriptorMethod3XX               @"3XX"
#define NKDescriptorMethod4XX               @"4XX"
#define NKDescriptorMethod5XX               @"5XX"

