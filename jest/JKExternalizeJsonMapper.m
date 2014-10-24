//
//  NKExternalizeJsonMapper.m
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
#import "JKHelper.h"
#import "JKExternalizeJsonMapper.h"
#import "JKApiMappingProtocol.h"
#import "RKPathMatcher.h"
#import "JKExternalMapperDict.h"
#import "RKMapping+Jest.h"
#import "RKObjectMapping+Jest.h"
#import "RKDynamicMapping+Jest.h"

@interface JKExternalizeJsonMapper ()
{
    NSMutableArray* _resDescriptors;
    NSMutableArray* _reqDescriptors;
}
@end

@implementation JKExternalizeJsonMapper

+ (instancetype) mapperWithFileInFolder:(NSString*) folderPath
{
    JKExternalizeJsonMapper* mapper =
        [[JKExternalizeJsonMapper alloc] initWithFileInPath:folderPath];

    return mapper;
}

//------------------------------------------------------------------------------
+ (instancetype) mapperWithFile:(NSString*) filePath
{
    JKExternalizeJsonMapper* mapper =
        [[JKExternalizeJsonMapper alloc] initWithFile:filePath];
    return mapper;
}

//------------------------------------------------------------------------------
+ (instancetype) mapperWithJson:(NSString*) jsonStr
{
    JKExternalizeJsonMapper* mapper =
        [[JKExternalizeJsonMapper alloc] initWithJson:jsonStr];
    return mapper;
}

//------------------------------------------------------------------------------
- (instancetype) initWithFileInPath:(NSString*) folderPath
{
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Check if given path is of a directory
        BOOL isDir;
        BOOL exists = [fileManager fileExistsAtPath:folderPath
                                        isDirectory:&isDir];
        
        if (!exists || !isDir) {
            self = nil;
        }else{
            NSError* error = nil;
            NSArray *dirContents = [fileManager
                                    contentsOfDirectoryAtPath:folderPath
                                    error:&error];
            if (error) {
                self = nil;
            }else{
                for (NSString *tString in dirContents) {
                    if ([tString hasSuffix:@".json"]) {
                        [self addResponseDescriptorFromContentOfFile:
                         [folderPath stringByAppendingPathComponent:tString]];
                    }
                }
            }
        }
    }
    return self;
}

//------------------------------------------------------------------------------
- (instancetype) initWithFile:(NSString*) filePath
{
    self = [super init];
    if (self) {
        BOOL isDir;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath
                                                           isDirectory:&isDir];
        if (!exists || isDir) {
            self = nil;
        }else{
            [self addResponseDescriptorFromContentOfFile:filePath];
        }
    }
    return self;
}

//------------------------------------------------------------------------------
- (instancetype) initWithJson:(NSString*) jsonString
{
    self = [super init];
    if (self) {
        [self addResponseDescriptorFromJsonString:jsonString];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Private Methods
- (NSMutableArray*) resDescriptors
{
    if (!_resDescriptors) {
        _resDescriptors = [NSMutableArray array];
    }
    return _resDescriptors;
}
//------------------------------------------------------------------------------
- (NSMutableArray*) reqDescriptors
{
    if (!_reqDescriptors) {
        _reqDescriptors = [NSMutableArray array];
    }
    return _reqDescriptors;
}
//------------------------------------------------------------------------------
- (void) addResponseDescriptorFromContentOfFile:(NSString*) filepath {
    
    NSError* error = nil;
    NSString* jsonString = [NSString
                            stringWithContentsOfFile:filepath
                            encoding:NSUTF8StringEncoding
                            error:&error];
    
    if (error) {
        return;
    }
    
    [self addResponseDescriptorFromJsonString:jsonString];
}

//------------------------------------------------------------------------------
- (void)addResponseDescriptorFromJsonString:(NSString *)jsonString
{
    
    NSError* error = nil;
    
    id jsonData =
    [NSJSONSerialization
     JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
     options:(NSJSONReadingMutableContainers)
     error:&error];

    if(error || !jsonData || ![jsonData isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    // Create response descriptors
    id responseDescs = [(NSDictionary*)jsonData objectForKey:NKDescriptorResponseDecs];
    if (responseDescs) {
        if ([responseDescs isKindOfClass:[NSDictionary class]]) {
            [self addResponseDescriptorFromDictionary:(NSDictionary*)responseDescs];
        }else if ([responseDescs isKindOfClass:[NSArray class]]) {
            for (NSDictionary* desDict in (NSArray*)responseDescs) {
                [self addResponseDescriptorFromDictionary:desDict];
            }
        }
    }
    
    // Create request descriptors
    id requestDesc = [(NSDictionary*)jsonData objectForKey:NKDescriptorRequestDecs];
    if (requestDesc) {
        if ([requestDesc isKindOfClass:[NSDictionary class]]) {
            [self addRequestDescriptorFromDictionary:(NSDictionary*)requestDesc];
        }else if ([requestDesc isKindOfClass:[NSArray class]]) {
            for (NSDictionary* desDict in (NSArray*)requestDesc) {
                [self addRequestDescriptorFromDictionary:desDict];
            }
        }
    }
}

//------------------------------------------------------------------------------
- (void) addResponseDescriptorFromDictionary :(NSDictionary*) descriptorDict
{
    if (!descriptorDict) return;
    NSArray* requestInfoDicts = [descriptorDict objectForKey:NKDescriptorRequests];
    if (!requestInfoDicts || !requestInfoDicts.count) return;

    
    NSArray* maps = [descriptorDict objectForKey:NKDescriptorMaps];
    NSMutableDictionary* mappingDict = [self createResponseMappingTable:maps];
    
    
    
    for (NSDictionary* requestInfoDict in requestInfoDicts) {
        
        NSString* rootMapperId = [[requestInfoDict
                                   objectForKey:NKDescriptorRootMap] noEmptyString];
        
        RKResponseDescriptor* descriptor = nil;
        RKMapping* rootMapper = [mappingDict objectForKey:rootMapperId];
        
        if (rootMapper)
        {
            NSString* path = [[requestInfoDict objectForKey: NKDescriptorPath] noEmptyString];
            NSString* keyPath = [[requestInfoDict objectForKey: NKDescriptorKeyPath] noEmptyString];
            
            // TODO: make use of statusCode information from json
            NSString* method = [[requestInfoDict objectForKey:NKDescriptorMethod] noEmptyString];
            NSArray* statusCodes = [requestInfoDict objectForKey:NKDescriptorStatusCodes];
            
            descriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:rootMapper
                          method:(method ? RKRequestMethodFromString(method) : RKRequestMethodAny)
                          pathPattern:path
                          keyPath:keyPath
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
            [[self resDescriptors] addObject:descriptor];
        }
    }
}

//------------------------------------------------------------------------------
- (NSMutableDictionary*) createResponseMappingTable: (NSArray*) maps {

    // Create dictionary of object mapper: key is id, and value is mapper object
    NSMutableDictionary* mappingDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* relationShips = [NSMutableDictionary dictionary];
    NSMutableDictionary* dynamicMatchers = [NSMutableDictionary dictionary];
    
    for (NSDictionary* mapDict in maps) {
        NSString* mapId  = [mapDict objectForKey:NKDescriptorMapId];
        RKMapping* map = [RKMapping responseMapFromDictionary:mapDict];
        if (mapId && map) {
            [mappingDict setObject:map forKey:mapId];
        }
        
        NSArray* rels = [mapDict objectForKey:NKDescriptorMapRelationships];
        if (rels && mapId) {
            [relationShips setObject:rels forKey:mapId];
        }
        
        NSArray* matchers = [mapDict objectForKey:NKDescriptorMapMatchers];
        if (matchers && mapId) {
            [dynamicMatchers setObject:matchers forKey:mapId];
        }
    }
    
    [self linkRelationships: relationShips mappings: mappingDict];
    [self linkDynamicMapping: mappingDict matchers: dynamicMatchers];
    
    return mappingDict;
}


//------------------------------------------------------------------------------
- (void) addRequestDescriptorFromDictionary:(NSDictionary*) descriptorDict
{
    if (!descriptorDict) return;
    
    NSArray* requestInfoDicts = [descriptorDict objectForKey:NKDescriptorRequests];
    if (!requestInfoDicts || !requestInfoDicts.count) return;

    NSArray* maps = [descriptorDict objectForKey:NKDescriptorMaps];
    NSMutableDictionary* mappingDict = [self createRequestMappingTable:maps];
    
    for (NSDictionary* requestInfoDict in requestInfoDicts) {
        
        NSString* rootMapperId = [[requestInfoDict
                                   objectForKey:NKDescriptorRootMap] noEmptyString];
        NSString* sourceName = [[requestInfoDict
                                      objectForKey:NKDescriptorMapSourceName] noEmptyString];
        Class sourceClass = NSClassFromString(sourceName);
        RKRequestDescriptor* descriptor = nil;
        RKMapping* rootMapper = [mappingDict objectForKey:rootMapperId];
        
        if (rootMapper && sourceClass)
        {
            NSString* keyPath = [[requestInfoDict objectForKey: NKDescriptorKeyPath] noEmptyString];
            
            // TODO: make use of statusCode information from json
            NSString* method = [[requestInfoDict objectForKey:NKDescriptorMethod] noEmptyString];

            descriptor = [RKRequestDescriptor
                          requestDescriptorWithMapping:rootMapper
                          objectClass:sourceClass
                          rootKeyPath:keyPath method:RKRequestMethodAny];
            
            [[self reqDescriptors] addObject:descriptor];
        }
    }
}

//------------------------------------------------------------------------------
- (NSMutableDictionary*) createRequestMappingTable: (NSArray*) maps {
        
    // Create dictionary of object mapper: key is id, and value is mapper object
    NSMutableDictionary* mappingDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* relationShips = [NSMutableDictionary dictionary];
    NSMutableDictionary* dynamicMatchers = [NSMutableDictionary dictionary];
    
    for (NSDictionary* mapDict in maps) {
        NSString* mapId  = [mapDict objectForKey:NKDescriptorMapId];
        RKMapping* map = [RKMapping requestMapFromDictionary:mapDict];
        if (mapId && map) {
            [mappingDict setObject:map forKey:mapId];
        }
        
        NSArray* rels = [mapDict objectForKey:NKDescriptorMapRelationships];
        if (rels && mapId) {
            [relationShips setObject:rels forKey:mapId];
        }
        
        NSArray* matchers = [mapDict objectForKey:NKDescriptorMapMatchers];
        if (matchers && mapId) {
            [dynamicMatchers setObject:matchers forKey:mapId];
        }
    }
    
    [self linkRelationships:relationShips mappings:mappingDict];
    [self linkDynamicMapping:mappingDict matchers:dynamicMatchers];
    
    return mappingDict;
}


//------------------------------------------------------------------------------
- (void) linkRelationships:(NSDictionary*) relationShips
                  mappings:(NSDictionary*) mappingDict
{
    // Link relationship
    for (NSString* mapId in [mappingDict allKeys])
    {
        NSArray* relDicts = [relationShips objectForKey:mapId];
        if (relDicts && relDicts.count)
        {
            for (NSDictionary* relDict in relDicts)
            {
                NSString* fromPath = [[relDict
                                       objectForKey:NKDescriptorMapRelFrom]
                                      noEmptyString];
                
                NSString* toPath  = [[relDict
                                      objectForKey:NKDescriptorMapRelTo]
                                     noEmptyString];
                
                NSString* mapRefId = [[relDict
                                       objectForKey:NKDescriptorMapMapRef]
                                      noEmptyString];
                
                RKMapping* targetMap = mapRefId ? [mappingDict objectForKey:mapRefId] : nil;
                RKMapping* map = [mappingDict objectForKey:mapId];
                
                [(RKObjectMapping*)map addRelationshipFrom: fromPath
                                                    toPath: toPath
                                                  usingMap: targetMap];
                
            }
        }
    }
}

//------------------------------------------------------------------------------
- (void) linkDynamicMapping: (NSDictionary* ) mappingDict
                   matchers: (NSDictionary*) dynamicMatchers
{
    // Link dynamic mapping
    for (NSString* mapId in [mappingDict allKeys]) {
        NSArray* matchers = [dynamicMatchers objectForKey:mapId];
        if (matchers && matchers.count) {
            for (NSDictionary* matcher in matchers) {
                NSString* keyPath = [matcher objectForKey:NKDescriptorKeyPath];
                NSString* expectVal = [matcher objectForKey:NKDescriptorMapMatcherExpect];
                NSString* mapRefId =  [matcher objectForKey:NKDescriptorMapMapRef];
                RKMapping* targetMap = [mappingDict objectForKey:mapRefId];
                RKMapping* dynamicMap = [mappingDict objectForKey:mapId];
                
                if (keyPath && expectVal && mapRefId &&
                    [targetMap isKindOfClass:[RKObjectMapping class]])
                {
                    [(RKDynamicMapping*)dynamicMap
                     addMatcherForKeyPath: keyPath
                     expectVal: expectVal
                     usingMap: (RKObjectMapping*)targetMap];
                }
            }
        }
    }
}


//------------------------------------------------------------------------------
#pragma mark - NKApiMapper Implementation
- (NSArray* ) responseDescriptorForRequest:(NSURLRequest *)request
{    
    return [self responseDescriptorsForPath:request.URL.path];
}

//------------------------------------------------------------------------------
- (NSArray*) responseDescriptorsForPath:(NSString*) path
{
    if (!_resDescriptors || ![_resDescriptors count]) {
        return nil;
    }
    
    NSMutableArray* foundDescriptors = [NSMutableArray array];
    for (RKResponseDescriptor* descriptor in _resDescriptors) {
        RKPathMatcher* matcher = [RKPathMatcher
                                  pathMatcherWithPattern:descriptor.pathPattern];
        
        if ([matcher matchesPath:path
            tokenizeQueryStrings:NO
                 parsedArguments:NO])
        {
            [foundDescriptors addObject: descriptor];
            break;
        }
    }
    
    return foundDescriptors;
}
//------------------------------------------------------------------------------
- (NSArray*) responseDescriptors
{
    
    if (!_resDescriptors || ![_resDescriptors count]) {
        return nil;
    }
    return _resDescriptors;
}

//------------------------------------------------------------------------------
- (RKRequestDescriptor*) requestDescriptorForClass:(Class) sourceClass
                                            method:(RKRequestMethod) method
{
    if (!_reqDescriptors || ![_reqDescriptors count]) {
        return nil;
    }
    
    do {
        for (RKRequestDescriptor *requestDescriptor in _reqDescriptors) {
            if ([requestDescriptor.objectClass isEqual:sourceClass] &&
                (method == requestDescriptor.method))
            {
                return requestDescriptor;
            }
        }
        
        for (RKRequestDescriptor *requestDescriptor in _reqDescriptors) {
            if ([requestDescriptor.objectClass isEqual:sourceClass] &&
                (method & requestDescriptor.method))
            {
                return requestDescriptor;
            }
        }
        sourceClass = [sourceClass superclass];
    } while (sourceClass);
    
    return nil;
}

//------------------------------------------------------------------------------
- (NSArray*) requestDescriptors
{
    if (!_reqDescriptors || ![_reqDescriptors count]) {
        return nil;
    }
    return _reqDescriptors;
}

@end
