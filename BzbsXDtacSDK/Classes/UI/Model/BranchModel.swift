//
//  BranchModel.swift
//  Pods
//
//  Created by Buzzebees iMac on 27/9/2562 BE.
//

open class Branch
{
    open var key: String?
    open var id: String?
    open var name: String?{
        get {
            LocaleCore.shared.getUserLocale() == 1054 ? name_th : name_en
        }
    }
    open var name_th: String?
    open var name_en: String?
    open var category: String?
    open var address: String?
    open var city: String?
    open var country: String?
    open var latitude: Double?
    open var longitude: Double?
    open var services: String?
    open var contact_number: String?
    open var working_day: String?
    open var check: Bool?
    open var isgoogle: Bool?
    open var isBuzzeBeesPlace: Bool?
    open var rank: Int?
    open var distance: Double?
    open var buzz: Int?
    open var like: Int?
    open var detail: String?
    
    public init()
    {
        
    }
    
    public init(dict: Dictionary<String, AnyObject>)
    {
        key = Convert.StringFromObject(dict["key"])
        id = Convert.StringFromObject(dict["id"])
        name_th = Convert.StringFromObject(dict["name"])
        name_en = Convert.StringFromObject(dict["name_en"])
        category = Convert.StringFromObject(dict["category"])
        address = Convert.StringFromObject(dict["address"])
        services = Convert.StringFromObject(dict["services"])
        contact_number = Convert.StringFromObject(dict["contact_number"])
        working_day = Convert.StringFromObject(dict["working_day"])
        check = Convert.BoolFromObject(dict["check"])
        isgoogle = Convert.BoolFromObject(dict["isgoogle"])
        isBuzzeBeesPlace = Convert.BoolFromObject(dict["isBuzzeBeesPlace"])
        rank = Convert.IntFromObject(dict["rank"])
        distance = Convert.DoubleFromObject(dict["distance"])
        buzz = Convert.IntFromObject(dict["buzz"])
        like = Convert.IntFromObject(dict["like"])
        detail = Convert.StringFromObject(dict["description"])
        
        getLocation(dict: dict["location"] as? Dictionary<String, AnyObject>)
    }
    
    func getLocation(dict dictData: Dictionary<String, AnyObject>?)
    {
        if let dict = dictData
        {
            city = Convert.StringFromObject(dict["city"])
            country = Convert.StringFromObject(dict["country"])
            latitude = Convert.DoubleFromObject(dict["latitude"])
            longitude = Convert.DoubleFromObject(dict["longitude"])
        }
    }
}
