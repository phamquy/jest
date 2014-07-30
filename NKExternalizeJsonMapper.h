//
//  NKExternalizeJsonMapper.h
//  nk-common
//
//  Created by jack on 6/17/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NKApiMapper;

/**
 Implementation of `NKApiMapper`, which uses external json file as descriptor, this mapper will read content of external json and construct an array of `NKResponseDescriptor`.
 */
@interface NKExternalizeJsonMapper : NSObject <NKApiMapper>
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

