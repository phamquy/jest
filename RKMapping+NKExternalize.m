//
//  NKm.m
//  nk-common
//
//  Created by jack on 6/18/14.
//  Copyright (c) 2014 SK Planet. All rights reserved.
//

#import "RKMapping+NKExternalize.h"
#import "NKExternalMapperDict.h"
#import "NKApiHelper.h"

@implementation RKMapping (NKExternalize)
+ (RKMapping*) requestMapFromDictionary:(NSDictionary*) mapDict
{
    NSMutableDictionary* attributeDict = [NSMutableDictionary dictionary];
    id attributes = [mapDict objectForKey:NKDescriptorMapAttributes];
    
    if ([attributes isKindOfClass:[NSDictionary class]])
    {
        [attributeDict addEntriesFromDictionary:attributes];
    }
    else if ([attributes isKindOfClass:[NSArray class]])
    {
        NSDictionary* retDict = [self attributeDictionaryFromArray:attributes];
        if (retDict) {
            [attributeDict addEntriesFromDictionary:retDict];
        }
    }else{
        attributeDict = nil;
    }
    
    // if get empty dictionary, nil it
    if (attributeDict && ![[attributeDict allKeys] count]) {
        attributeDict = nil;
    }
    
    NSString* keyAttribute = [[mapDict objectForKey:NKDescriptorMapKeyAttribute] noEmptyString];
    // Handle case with key attribute
    if (attributeDict && keyAttribute) {
        attributeDict = [self adjustForRequestKeyAttribute: keyAttribute
                                             attributeDict: attributeDict];
    }
    
    // Construct mapping
    RKMapping* mapping = nil;
    
    BOOL isDynamic = [[mapDict objectForKey:NKDescriptorMapDynamic] boolValue];
    if (isDynamic) {
        mapping = [RKDynamicMapping new];
    }else {
//        NSString* sourceName = [[mapDict objectForKey:NKDescriptorMapTargetName] noEmptyString];
//        Class sourceClass = NSClassFromString(sourceName);
//        if (sourceClass)
//        {
            mapping = [RKObjectMapping requestMapping];
            if (attributeDict)
            {
                if (keyAttribute) {
                    [(RKObjectMapping*)mapping addAttributeMappingToKeyOfRepresentationFromAttribute:keyAttribute];
                }
                [(RKObjectMapping*)mapping addAttributeMappingsFromDictionary:attributeDict];
            }
//        }
    }
    return mapping;
}

//------------------------------------------------------------------------------
+ (RKMapping*) responseMapFromDictionary:(NSDictionary *)mapDict
{
    BOOL isEntity = [[mapDict objectForKey:NKDescriptorMapIsEntity ] boolValue];
    NSString* targetName  = [[mapDict objectForKey:NKDescriptorMapTargetName] noEmptyString];
    id identification = [mapDict objectForKey:NKDescriptorMapIdentification];

    
    // Key for special cases
    NSString* keyAttribute = [[mapDict objectForKey:NKDescriptorMapKeyAttribute] noEmptyString];
    BOOL isForceCollection = [[mapDict objectForKey:NKDescriptorMapForceCollection] boolValue];
    BOOL isDynamic = [[mapDict objectForKey:NKDescriptorMapDynamic] boolValue];
    
    // Obtain attributes dictionary
    NSMutableDictionary* attributeDict = [NSMutableDictionary dictionary];
    id attributes = [mapDict objectForKey:NKDescriptorMapAttributes];
    
    if ([attributes isKindOfClass:[NSDictionary class]])
    {
        [attributeDict addEntriesFromDictionary:attributes];
    }
    else if ([attributes isKindOfClass:[NSArray class]])
    {
        NSDictionary* retDict = [self attributeDictionaryFromArray:attributes];
        if (retDict) {
            [attributeDict addEntriesFromDictionary:retDict];
        }
    }else{
        attributeDict = nil;
    }
    
    // if get empty dictionary, nil it
    if (attributeDict && ![[attributeDict allKeys] count]) {
        attributeDict = nil;
    }
    
    // Handle case with key attribute
    if (attributeDict && keyAttribute) {
        attributeDict = [self adjustForReponseKeyAttribute: keyAttribute  attributeDict: attributeDict];
    }
    
    // Construct mapping
    RKMapping* mapping = nil;
    
    if (isDynamic) {
        mapping = [RKDynamicMapping new];
    }else {
        if (isEntity)
        {
            if ([[RKObjectManager sharedManager] managedObjectStore])
            {
                NSEntityDescription* entityDesc = [self entityDescriptionFromTargetName:targetName];
                NSAssert1(entityDesc, @"Couldnt find entity description for name: %@", entityDesc);
                if (entityDesc) {
                    mapping  =  [RKEntityMapping
                                 mappingForEntityForName:entityDesc.name
                                 inManagedObjectStore:[[RKObjectManager sharedManager]
                                                       managedObjectStore]];
                    if (attributeDict)
                    {
                        if (keyAttribute) {
                            [(RKObjectMapping*)mapping addAttributeMappingFromKeyOfRepresentationToAttribute:keyAttribute];
                        }
                        
                        [(RKObjectMapping*)mapping setForceCollectionMapping:isForceCollection];
                        [(RKObjectMapping*)mapping addAttributeMappingsFromDictionary:attributeDict];
                        
                        if (identification)
                        {
                            NSArray* ids = [self identificationOfEntity:entityDesc from:identification];
                            if (ids) {
                                [(RKEntityMapping*)mapping setIdentificationAttributes:ids];
                            }
                        }
                    }
                }
            }
        }
        else
        {
            Class targetClass = NSClassFromString(targetName);
            if (targetClass)
            {
                mapping = [RKObjectMapping mappingForClass:targetClass];
                if (attributeDict)
                {
                    if (keyAttribute) {
                        [(RKObjectMapping*)mapping addAttributeMappingToKeyOfRepresentationFromAttribute:keyAttribute];
                    }
                    
                    [(RKObjectMapping*)mapping setForceCollectionMapping:isForceCollection];
                    [(RKObjectMapping*)mapping addAttributeMappingsFromDictionary:attributeDict];
                }
            }
        }
    }
    
    return mapping;
}

//------------------------------------------------------------------------------
+ (NSDictionary*) attributeDictionaryFromArray:(NSArray*) attrArray
{
    NSMutableDictionary* attributeDict = [NSMutableDictionary dictionary];
    for (id object in attrArray)
    {
        if ([object isKindOfClass:[NSArray class]])
        {
            NSDictionary* retDict = [self attributeDictionaryFromArray:object];
            if (retDict) {
                [attributeDict addEntriesFromDictionary:retDict];
            }
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            [attributeDict addEntriesFromDictionary:object];
        }
    }
    
    if (![[attributeDict allKeys] count]) {
        attributeDict = nil;
    }
    
    return attributeDict;
}

//------------------------------------------------------------------------------
+ (NSEntityDescription*) entityDescriptionFromTargetName:(NSString*) targetName
{
    NSEntityDescription* resultEntityDesc = nil;
    RKManagedObjectStore* store = [[RKObjectManager sharedManager]
                                   managedObjectStore];
    NSArray* entitiNamesInStore = [[store.managedObjectModel entitiesByName] allKeys];
    
    // If target name is valid entity name, return it
    if ([entitiNamesInStore containsObject:targetName])
    {
        resultEntityDesc = [[store.managedObjectModel entitiesByName] objectForKey:targetName];
    }
    // Otherwise, check if target name is ManagedClass name
    else
    {
        for (NSEntityDescription* entityDescription  in [store.managedObjectModel entities])
        {
            if ([[entityDescription managedObjectClassName] isEqualToString:targetName]) {
                resultEntityDesc = entityDescription;
                break;
            }
        }
    }
    
    return resultEntityDesc;
}

//------------------------------------------------------------------------------
+ (NSMutableDictionary*)adjustForReponseKeyAttribute: (NSString*) keyAttribute
                                       attributeDict: (NSDictionary*) attributeDict
{
    NSMutableDictionary* adjustedDict = [NSMutableDictionary dictionaryWithCapacity:attributeDict.count];
    for (NSString* key in [attributeDict allKeys]) {
        NSString* newKey = [NSString stringWithFormat:@"{%@}.%@", keyAttribute, key];
        [adjustedDict setObject:[attributeDict objectForKey:key]
                         forKey:newKey];
    }
    return adjustedDict;
}

//------------------------------------------------------------------------------
+ (NSMutableDictionary*)adjustForRequestKeyAttribute: (NSString*) keyAttribute
                                       attributeDict: (NSDictionary*) attributeDict
{
    NSMutableDictionary* adjustedDict = [NSMutableDictionary dictionaryWithCapacity:attributeDict.count];
    for (NSString* key in [attributeDict allKeys]) {
        NSString* newVal = [NSString stringWithFormat:@"{%@}.%@",
                            keyAttribute, [attributeDict valueForKey:key]];
        
        [adjustedDict setObject:newVal forKey:key];
    }
    return adjustedDict;
}


//------------------------------------------------------------------------------
+ (NSArray*) identificationOfEntity: (NSEntityDescription*) entityDesc from: (id) identificationObj
{
    NSMutableArray* ids = [NSMutableArray array];
    if ([identificationObj isKindOfClass:[NSArray class]]) {
        for (NSString* identifier in identificationObj) {
            if ([[[entityDesc attributesByName] allKeys] containsObject:identifier]) {
                [ids addObject:identifier];
            }
        }
    }else{
        if ([[[entityDesc attributesByName] allKeys] containsObject:identificationObj]) {
            [ids addObject:identificationObj];
        }
    }
    return ids;
}
@end
