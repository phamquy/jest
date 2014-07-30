# Mapping description for RestKit

## Quick example 
**RestKit source code**

```

	[RKEntityMapping mappingForEntityForName:[NKHouseStaff entityName]
                            inManagedObjectStore:managedObjectStore];

        [staffEntityMapping addAttributeMappingsFromDictionary:
         @{
           @"memIdx": @"userId",
           @"memNm" : @"name"}];
        staffEntityMapping.identificationAttributes = @[ @"userId" ];

        RKEntityMapping* houseEntityMapping =
        [RKEntityMapping mappingForEntityForName:[NKHouse entityName]
                            inManagedObjectStore:managedObjectStore];

        [houseEntityMapping addAttributeMappingsFromDictionary:
         @{ @"orgId":@"houseId" ,
            @"orgNm": @"name"}];

        [staffEntityMapping
         addPropertyMapping:[RKRelationshipMapping
                             relationshipMappingFromKeyPath:nil
                             toKeyPath:@"house"
                             withMapping:houseEntityMapping]];


        RKResponseDescriptor* responseDescriptor =
        [RKResponseDescriptor
         responseDescriptorWithMapping:staffEntityMapping
         method:(RKRequestMethodPOST)
         pathPattern:NKApiPathLogin
         keyPath:@"member_info"
         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
```

**Corresponding Json description **


```
{
	"path" : "api/login",
    "keyPath" : "member_info",
    "statusCodes" : [201, 2XX, 3XX, 302],
    "root-map-ref" : "staffEntity",
	"methods" : ["POST", "GET"],
    "mappers" : [
    	{
        	"id" : "staffEntity",
            "entity" : "YES",
            "targetName" : "NKHouseStaff",
            "attributes" : {
            	 "memIdx" : "userId",
                 "memNm" : "name"
            },
            "identification" : "userId",
            "relationships" : [
            	{
            		"from" : "",
                    "to" : "house"
                    "map-ref" : "houseEntity"
                }
            ]
        },
        {
        	"id" : "houseEntity",
            "entity" : "YES",
            "targetName" : "NKHouse",
            "attributes" : {
            	"orgId" : "houseId",
                "orgNm" : "name"
            },
            "identification" : "houseId"
        }
    ]
}
```

## Example 1 ##

** From RestKit **

```

RKObjectMapping* articleMapping = [RKObjectMapping mappingForClass:[Article class]];
[articleMapping addAttributeMappingsFromDictionary:@{
    @"title": @"title",
    @"body": @"body",
    @"author": @"author",
    @"publication_date": @"publicationDate"
}];

RKResponseDescriptor *responseDescriptor =
[RKResponseDescriptor
responseDescriptorWithMapping:articleMapping
method:RKRequestMethodAny
pathPattern:nil
keyPath:@"articles"
statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

```

** JSON description **

```
{
	"path" : "",
    "keyPath" : "articles"
    "statusCodes" : ["2XX"],
    "mappers" : [
    	{
        	"id" : "articleObj",
            "entity" : "NO",
            "targetName" : "Article",
            "attributes" : {
            	"title" : "title",
                "body" : "body",
                "author" : "author",
                "publication_date" : "publicationDate"
            }
        }
    ]
}
```

## Example 2: Relationship

```
// Create our new Author mapping
RKObjectMapping* authorMapping = [RKObjectMapping mappingForClass:[Author class] ];
// NOTE: When your source and destination key paths are symmetrical, you can use addAttributesFromArray: as a shortcut instead of addAttributesFromDictionary:
[authorMapping addAttributeMappingsFromArray:@[ @"name", @"email" ]];

// Now configure the Article mapping
RKObjectMapping* articleMapping = [RKObjectMapping mappingForClass:[Article class] ];
[articleMapping addAttributeMappingsFromDictionary:@{
    @"title": @"title",
    @"body": @"body",
    @"publication_date": @"publicationDate"
}];

// Define the relationship mapping
[articleMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                               toKeyPath:@"author"
                                                                             withMapping:authorMapping]];

RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:articleMapping
                                                                                        method:RKRequestMethodAny
                                                                                   pathPattern:nil
                                                                                       keyPath:@"articles"
                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
```

** JSON Description **

```
{
	"path" : "articles",
    "keyPath" : "articles"
    "statusCodes" : ["2XX"],
    "root-map-ref" : "articleObj",
    "methods" : ["POST"],
    "mappers" : [
    	{
        	"id" : "authorObj",
            "entity" : "NO",
            "target" : "Author",
            "attributes" : ["name", "email"]
        },
        {
        	"id" : "articleObj",
            "entity" : "NO",
            "target" : "Article",
            "attributes" : {
            	"title" : "title",
                "body" : "body",
                "publication_date" : "publicationDate"
            }
            "relationships" : [
            	{
                	"from" : "author",
                    "to" : "author"
                    "map-ref" : "authorObj"
                }
            ]
        }
    ]
}
```

## Example 3 : Mapping Values without Key Paths

**Response data:**

```
 { "user_ids": [1234, 5678] }
```


**Mapping configuration**

```
RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
[userMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"userID"]];

RKResponseDescriptor *responseDescriptor =
[RKResponseDescriptor
        responseDescriptorWithMapping:userMapping
        method:RKRequestMethodAny
        pathPattern:nil
        keyPath:@"user_ids"
        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

[[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
```

**JSON Description**

```
{
	"path" : "",
    "keyPath" : "user_ids"
    "statusCodes" : ["2XX"],
    "root-map-ref" : "userMapping",
    "methods" : ["ANY"],
    "mappers" : [
    	{
        	"id" : "userMapping",
            "entity" : "NO",
            "target" : "RKExampleUser",
            "attributes" : nil,
            "relationships" : [
            	{
                	"from" : "",
                    "to" : "userID"
                }
            ]
        }
    ]
}
```


## Example 4 : Composing Relationships with the Nil Key Path


**Response data**

```
    {
    	"first_name": "Example",
        "last_name": "McUser",
        "city": "New York City",
        "state": "New York",
        "zip": 10038
    }

```


**Mapping Configuration**

```
RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[RKExampleAddress class]];
[addressMapping addAttributeMappingsFromDictionary:@{ @"city": @"city", @"state": @"state", @"zip": @"zipCode" }];

RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
[userMapping addAttributeMappingsFromDictionary:@{ @"first_name": @"firstName", @"last_name": @"lastName" }];
[userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"address" withMapping:addressMapping]];

RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
[[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
```


**JSON Description**

```
{
	"path" : "",
    "keyPath" : ""
    "statusCodes" : ["2XX"],
    "root-map-ref" : "userMapping",
    "methods" : ["ANY"],
    "mappers" : [
    	{
        	"id" : "addressMaper",
            "entity" : "NO",
            "target" : "RKExampleAddress",
            "attributes" : [
            	["city", "state"],
                {"zip" : "zipCode"}
            ]
        },
    	{
        	"id" : "userMapping",
            "entity" : "NO",
            "target" : "RKExampleUser",
            "attributes" : {
            	"first_name" : "firstName",
                "last_name" : "lastName"
            },
            "relationships" : [
            	{
                	"from" : "",
                    "to" : "address",
                    "map-ref" : "addressMaper"
                }
            ]
        }
    ]
}
```

## Example 5: Handling Multiple Root Objects in Core Data *Post/Put*


**Response**

```
{
    "article": { "title": "RestKit Object Mapping Intro",
                "body": "This article details how to use RestKit object mapping...",
                "authorIds": [13, 15],
                "publication_date": "7/4/2011"
            },
    "authors": [
        {
            "name": "Blake Watters",
            "email": "blake@gmail.com",
            "id": 13
        },
        {
            "name": "Bob Spryn",
            "email": "bob@gmail.com",
            "id": 15
        }
    ]
}

```


**Mapping configuration**

refer to QuickExample

## Example 6: Handling Dynamic Nesting Attributes

**Response**

```
{
	"blake": {
        "email": "blake@restkit.org",
        "favorite_animal": "Monkey"
    }
}
```

**Mapping Configuration**

```
RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[User class] ];
[mapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"username"];
[mapping addAttributeMappingsFromDictionary:@{
    @"(username).email": @"email",
    @"(username).favorite_animal": "favoriteAnimal"
}];
```

**JSON description**

```
{
	"path" : "",
    "keyPath" : ""
    "statusCodes" : ["2XX"],
    "root-map-ref" : "userMapping",
    "methods" : ["ANY"],
    "mappers" : [
    	{
        	"id" : "userMapper",
            "entity" : "NO",
            "target" : "User",
            "keyAttribute" : "username",
            "attributes" : [
            	"email" : "email",
                "favorite_animal":"favoriteAnimal"
            ]
        }
    ]
}

```

**_Mutiple objects_** 

```
{
  "blake": {
    "email": "blake@restkit.org",
    "favorite_animal": "Monkey"
  },
  "sarah": {
    "email": "sarah@restkit.org",
    "favorite_animal": "Cat"
  }
}
```

```
RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[User class] ];
mapping.forceCollectionMapping = YES;
[mapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"username"];
[mapping addAttributeMappingsFromDictionary:@{
    @"(username).email": @"email",
    @"(username).favorite_animal": "favoriteAnimal"
}];
```

```
{
	"path" : "",
    "keyPath" : ""
    "statusCodes" : ["2XX"],
    "root-map-ref" : "userMapping",
    "methods" : ["ANY"],
    "mappers" : [
    	{
        	"id" : "userMapper",
            "entity" : "NO",
            "target" : "User",
            "keyAttribute" : "username",
            "forceCollection" : "YES",
            "attributes" : [
            	"email" : "email",
                "favorite_animal":"favoriteAnimal"
            ]
        }
    ]
}

```


## Example 7: Dynamic Object Mapping

**Response**

```
{
    "people": [
        {
            "name": "Blake Watters",
            "type": "Boy",
            "friends": [
                {
                    "name": "John Doe",
                    "type": "Boy"
                },
                {
                    "name": "Jane Doe",
                    "type": "Girl"
                }
            ]
        },
        {
            "name": "Sarah",
            "type": "Girl"
        }
    ]
}
```

**Mapping configuration**

```

// Basic setup
RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class] ];
[boyMapping addAttributeMappingsFromArray:@[ @"name" ]];

RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class] ];
[girlMapping addAttributeMappingsFromArray:@[ @"name" ]];

RKDynamicMapping* dynamicMapping = [RKDynamicMapping new];

[boyMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"friends" toKeyPath:@"friends" withMapping:dynamicMapping]];

[girlMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"friends" toKeyPath:@"friends" withMapping:dynamicMapping]];

// Connect a response descriptor for our dynamic mapping
RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dynamicMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"people" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
[[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];

// Option 1: Configure the dynamic mapping via matchers
[dynamicMapping setObjectMapping:boyMapping whenValueOfKeyPath:@"type" isEqualTo:@"Boy"];
[dynamicMapping setObjectMapping:girlMapping whenValueOfKeyPath:@"type" isEqualTo:@"Girl"];

// Option 2: Configure the dynamic mapping via a block
[dynamicMapping setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation) {
    if ([[representation valueForKey:@"type"] isEqualToString:@"Boy"]) {
        return boyMapping;
    } else if ([[representation valueForKey:@"type"] isEqualToString:@"Girl"]) {
        return girlMapping;
    }

    return nil;
};

```


**Json Description**

```
{
	"path" : "",
    "keyPath" : ""
    "statusCodes" : ["2XX"],
    "root-map-ref" : "dynamicMapping",
    "methods" : ["ANY"],
    "mappers" : [
    	{
        	"id" : "boyMappin",
            "target" : "Boy",
            "entity" : "NO",
            "attributes" : [ "name" ],
            "relationships" : [
            	"from" : "friends",
                "to" : "friends",
                "map-ref" : "dynamicMapper"
            ]
        },
        {
        	"id" : "girlMappin",
            "target" : "Girl",
            "entity" : "NO",
            "attributes" : [ "name" ],
 			"relationships" : [
            	"from" : "friends",
                "to" : "friends",
                "map-ref" : "dynamicMapper"
            ]

        },
        {
        	"id" : "dynamicMapper",
            "dynamic" : "YES",
            "matchers" : [
            	{
                	"keyPath" : "type",
                    "expectValue" : "Boy",
                    "map-ref" : "boyMappin"
                },
                {
                	"keyPath" : "type",
                    "expectValue" : "Girl",
                    "map-ref" : "girlMappin"
                },
                {
                	"predicate" : "<your predicate statement here>",
                    "map-ref" : "<your reference to mapper-id>"
                }
            ]
        }
    ]
}

```
