//
//  BzbsPlace.swift
//  BzbsSDK
//
//  Created by macbookpro on 18/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import UIKit
import Foundation

public class BzbsPlace {
    public var locationId: Int!
    public var name: String!
    public var latitude: Double!
    public var longitude: Double!
    public var location :CLLocationCoordinate2D? {
        if let lat = latitude,
        let lon = longitude
        {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    public var id: String!
    public var buzz: Int!
    public var category: String!
    public var checkin_count: Int!
    public var checkins: Int!
    public var contact_number = [String]()
    public var description_place: String!
    public var display_subtext: String!
    public var distance: Double!
    public var isBuzzeBeesPlace: Bool!
    public var page_id: Int!
    public var rank: Int!
    public var rating: Int!
    public var taking_about_count: Int!
    public var were_here_count: Int!
    public var workingDay: String!
    public var listServices = [BzbsService]()
    
    // extra var
    public var like :Int!
    public var name_en :String!
    public var description_place_en :String!
    public var workingDay_en :String!
    public var address :String!
    public var address_en :String!
    public var image_url :String!
    public var region :String!
    public var region_en :String!
    public var LineChannelID :String!
    public var reference_code :String!
    public var subdistrict_code :String!
    public var district_code :String!
    public var province_code :String!
    public var expert :String!
    
    init() {
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        // Property in api get campaign
        locationId = BuzzebeesConvert.IntFromObject(dict["LocationID"])
        name = BuzzebeesConvert.StringFromObject(dict["Name"])
        latitude = BuzzebeesConvert.DoubleFromObject(dict["Latitude"])
        longitude = BuzzebeesConvert.DoubleFromObject(dict["Longitude"])
        
        // Property in api get place
        id = BuzzebeesConvert.StringFromObject(dict["id"])
        buzz = BuzzebeesConvert.IntFromObject(dict["buzz"])
        category = BuzzebeesConvert.StringFromObject(dict["category"])
        checkin_count = BuzzebeesConvert.IntFromObject(dict["checkin_count"])
        checkins = BuzzebeesConvert.IntFromObject(dict["checkins"])
        
        description_place = BuzzebeesConvert.StringFromObject(dict["description_place"])
        let detail = BuzzebeesConvert.StringFromObject(dict["description"])
        if detail != "" {
            description_place = detail
        }
        
        display_subtext = BuzzebeesConvert.StringFromObject(dict["display_subtext"])
        distance = BuzzebeesConvert.DoubleFromObject(dict["distance"])
        isBuzzeBeesPlace = BuzzebeesConvert.BoolFromObject(dict["isBuzzeBeesPlace"])
        
        // location
        if let dictLocation = dict["location"] as? Dictionary<String, AnyObject> {
            latitude = BuzzebeesConvert.DoubleFromObject(dictLocation["latitude"])
            longitude = BuzzebeesConvert.DoubleFromObject(dictLocation["longitude"])
        }
        
        let strName = BuzzebeesConvert.StringFromObject(dict["name"])
        if strName != "" {
            name = strName
        }
        
        page_id = BuzzebeesConvert.IntFromObject(dict["page_id"])
        rank = BuzzebeesConvert.IntFromObject(dict["rank"])
        rating = BuzzebeesConvert.IntFromObject(dict["rating"])
        taking_about_count = BuzzebeesConvert.IntFromObject(dict["taking_about_count"])
        were_here_count = BuzzebeesConvert.IntFromObject(dict["were_here_count"])
        workingDay = BuzzebeesConvert.StringFromObject(dict["working_day"])
        
        if let contact = dict["contact_number"] as? String {
            contact_number = contact.components(separatedBy: "\n")
        }
        
        if let services = dict["services"] as? [Dictionary<String, AnyObject>] {
            listServices.removeAll(keepingCapacity: false)
            
            for item in services {
                listServices.append(BzbsService(dict: item))
            }
        }
        
        like = BuzzebeesConvert.IntFromObject(dict["like"])
        name_en = BuzzebeesConvert.StringFromObject(dict["name_en"])
        description_place_en = BuzzebeesConvert.StringFromObject(dict["description_en"])
        workingDay_en = BuzzebeesConvert.StringFromObject(dict["working_day_en"])
        address = BuzzebeesConvert.StringFromObject(dict["address"])
        address_en = BuzzebeesConvert.StringFromObject(dict["address_en"])
        image_url = BuzzebeesConvert.StringFromObject(dict["image_url"])
        region = BuzzebeesConvert.StringFromObject(dict["region"])
        region_en = BuzzebeesConvert.StringFromObject(dict["region_en"])
        LineChannelID = BuzzebeesConvert.StringFromObject(dict["LineChannelID"])
        reference_code = BuzzebeesConvert.StringFromObject(dict["reference_code"])
        subdistrict_code = BuzzebeesConvert.StringFromObject(dict["subdistrict_code"])
        district_code = BuzzebeesConvert.StringFromObject(dict["district_code"])
        province_code = BuzzebeesConvert.StringFromObject(dict["province_code"])
        expert = BuzzebeesConvert.StringFromObject(dict["expert"])
        
    }
}

public class BzbsService {
    public var id: String!
    public var name: String!
    
    init() {
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        id = BuzzebeesConvert.StringFromObject(dict["id"])
        name = BuzzebeesConvert.StringFromObject(dict["Name"])
        if name == "" {
            name = BuzzebeesConvert.StringFromObject(dict["name"])
        }
    }
}
