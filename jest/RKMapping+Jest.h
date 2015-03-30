//
//  NKm.h
//  nk-common
//
//  Created by jack on 6/18/14.
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
#import <RestKit/RestKit.h>

@class RKMapping;
@class RKManagedObjectStore;

@interface RKMapping (Jest)
+ (RKMapping*) responseMapFromDictionary:(NSDictionary*) mapDict
                             objectStore:(RKManagedObjectStore*) objectStore;

+ (RKMapping*) requestMapFromDictionary:(NSDictionary*) mapDict
                            objectStore:(RKManagedObjectStore*) objectStore;;

@end
