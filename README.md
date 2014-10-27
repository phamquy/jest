jest
====

**Why did I make this?**

RestKit is a great and well design framework and reduce alot of your code when you need to work with your server's REST api. However, your server REST api need to be well design the response should be well-structure JSON/XML data.

In some of my past project, when I had to work with a server api that doesnt have that well-design, writing RestKit mapping is as time consuming as write code to directly parse the raw response. It's even worse in some case that server doesnt have a consistent vocabulary (using diffent keys for the same data property). In such the case, you most likely have to write different object mapping for each API path.

Here are some reason that make writing RestKit mapping a painful task:

1. Response is a big-flat object. All the key-value pairs is packed in a big-flat object
2. Inconsistent key: use different keys for the same data
3. Inconsistent data format


**How Jest may release your pain?**

Instead of tangling my code with object mapping, with Jest, i can put all of my mapping into json file. Object mappings will be written in expressive json objects.

Here is a quick example: 

```
{
    "responseDescriptors": [
        {
            "requests": [
                {
                    "path": "/v2/venues/search",
                    "keyPath": "response.venues",
                    "root-map-ref": "venueMap",
                    "statusCodes": ["2XX"]
                }
            ],
            "maps": [
                {	
                     "id": "venueMap",
                     "targetName": "JestExamples.Venue",
                     "attributes": ["name"],
                     "relationships" : [
                        {"from" : "location", "to" : "location", "map-ref" : "locationMap"},
                        {"from" : "stats", "to" : "stats", "map-ref" : "statsMap"}
                     ]
					
                },
             {
                 "id": "locationMap",
                 "targetName": "JestExamples.Location",
                 "attributes": ["address", "city", "country", "crossStreet", "postalCode", "state", "distance", "lat", "lng"]
             },
             {
                 "id": "statsMap",
                 "targetName": "JestExamples.Stats",
                 "attributes": {
                     "checkinsCount" : "checkins",
                     "tipsCount" : "tips",
                     "usersCount" : "users"
                 }
             }
                     
            ]
        }
    ]
}
```

**Jest and Restkit**

Jest can descript the basic mapping supportted by Restkit:
- Object/Managed object mapping
- Relationship mapping
- Dynamic mapping

For others special case please check out Examples.md



