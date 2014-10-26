//
//  ViewController.swift
//  JestExamples
//
//  Created by jack on 10/24/14.
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


import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let kCLIENTID = "TZM5LRSRF1QKX1M2PK13SLZXRXITT2GNMB1NN34ZE3PVTJKT"
    let kCLIENTSECRET = "250PUUO4N5P0ARWUJTN2KHSW5L31ZGFDITAUNFWVB5Q4WJWY"

    var venues : NSArray?;
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.configRestKit()
        self.loadVenues()
    }

    //--------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------------------------------------------
    // MARK : TableView delegate and datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let count = self.venues?.count
        {
            return count
        }else{
            return 0
        }
    }
    
    //--------------------------------------------------------------------------
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell : VenueCell = tableView.dequeueReusableCellWithIdentifier("VenueCell", forIndexPath: indexPath)
         as VenueCell
        if let venue = self.venues?[indexPath.row] as? Venue{
            cell.nameLabel.text = venue.name;
            if let distance  = venue.location?.distance?.floatValue {
                cell.distanceLabel.text = String(format: "%.0fm", distance)
            }else{
                cell.distanceLabel.text = "N/A"
            }
            
            if let chkIns = venue.stats?.checkins?.integerValue{
                cell.checkinsLabel.text = String(format: "%d checkins", chkIns)
            }else{
                cell.checkinsLabel.text  = "N/A"
            }
        }else{
            cell.nameLabel.text = "N/A"
            cell.distanceLabel.text = "N/A"
            cell.checkinsLabel.text = "N/A"
        }
        return cell
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: Util methods
    private func configRestKit() {
        let baseURL = NSURL(string: "https://api.foursquare.com")
        let client : AFHTTPClient = AFHTTPClient(baseURL: baseURL)
    
        let objectManager : RKObjectManager = RKObjectManager(HTTPClient: client)
        
//        let venueMapping : RKObjectMapping = RKObjectMapping(forClass: Venue.self)
//        venueMapping.addAttributeMappingsFromArray(["name"])
//        
//        let locationMapping = RKObjectMapping(forClass: Location.self)
//        locationMapping.addAttributeMappingsFromArray(["address", "city", "country", "crossStreet", "postalCode", "state", "distance", "lat", "lng"])
//        
//        let statsMapping = RKObjectMapping(forClass: Stats.self)
//        statsMapping.addAttributeMappingsFromDictionary(["checkinsCount": "checkins", "tipsCount": "tips", "usersCount": "users"])
//        
//        venueMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "location", toKeyPath: "location", withMapping: locationMapping))
//        venueMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "stats", toKeyPath: "stats", withMapping: statsMapping))
//        
//        let responseDescriptor : RKResponseDescriptor = RKResponseDescriptor(mapping: venueMapping, method: RKRequestMethod.GET, pathPattern: "/v2/venues/search", keyPath: "response.venues", statusCodes: NSIndexSet(index: 200))

        let filePath =  NSBundle.mainBundle().pathForResource("map", ofType: "json")
        let jsonExMaps = JKExternalizeJsonMapper(file: filePath)
        objectManager.addResponseDescriptorsFromArray(jsonExMaps.responseDescriptors())
    }
    
    //--------------------------------------------------------------------------
    private func loadVenues()
    {
        let latLon : String = "37.33,-122.03"
        let clientId : String = kCLIENTID;
        let clientSecret : String = kCLIENTSECRET;
        let queryParams : NSDictionary = ["ll" : latLon,"client_id": clientId, "client_secret" : clientSecret, "categoryId" : "4bf58dd8d48988d1e0931735", "v": "20140118"]
        
        
        weak var wself = self;
        RKObjectManager
            .sharedManager()
            .getObjectsAtPath(
                "/v2/venues/search",
                parameters: queryParams,
                success: {
                    (response: RKObjectRequestOperation!, mappingResult: RKMappingResult!) -> Void in
                    let strongSelf = wself
                    strongSelf?.venues = mappingResult.array()
                    strongSelf?.tableView.reloadData()
                },
                failure: {
                    (response: RKObjectRequestOperation!, error: NSError!) -> Void in
                    NSLog("What do you mean by 'there is no coffee?': %@", error);
                }
        )
        
    }
}

