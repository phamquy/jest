//
//  NKExternalizeJsonMapper.h
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

#import <Foundation/Foundation.h>

@protocol JKApiMapper;

/**
 Implementation of `NKApiMapper`, which uses external json file as descriptor, this mapper will read content of external json and construct an array of `NKResponseDescriptor`.
 */
@interface JKExternalizeJsonMapper : NSObject <JKApiMapper>
/**
 Utilities class methods to create mapper
 */
+ (instancetype) mapperWithFileInFolder:(NSString*) folderPath;
+ (instancetype) mapperWithFile:(NSString*) filePath;
+ (instancetype) mapperWithJson:(NSString*) jsonStr;




/**
 This initializer will read all .json file from input folder, and construct descriptor accordingly.
 
 This methods is useful if you have multiple json file, each of which describe a single or set of response descriptors.
 For example: authencation.json contain information about descriptor for request relate to authentication
 
 @param folderPath path of folder that contains descriptor files
 */
- (instancetype) initWithFileInPath:(NSString*) folderPath;

/**
 This initializer read content of file at given path and construct response desrciptors
 
 @param filePath path of input file
 */
- (instancetype) initWithFile:(NSString*) filePath;

/**
 if you already have a descriptor string inmemory in form of a `NSString`, use this initializer to construct the mapper
 
 @param jsonString input json string
 */
- (instancetype) initWithJson:(NSString*) jsonString;
@end

