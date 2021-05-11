//
//  CacheCore.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 12/1/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//


import UIKit

class CacheCore: BBCache {
    // MARK: Singleton Pattern
    static var shared = CacheCore()
    
}

//
//  BBCache.swift
//  BeerLao_iOS
//
//  Created by macbookpro on 10/2/2558 BE.
//  Copyright (c) 2558 Wongsakorn.s. All rights reserved.
//

import UIKit
/**
 ใช้สำหรับฟังก์ชั่นเกี่ยวกับบันทึกและโหลดข้อมูลลงเครื่อง
 */
open class BBCache: NSObject
{
    
    public enum keys : String {
        case loginparam = "loginparam"
        case statusCampaign = "status"
        
        var folder :String {
            switch self {
                case .loginparam:
                    return "login"
                case .statusCampaign:
                    return "campaign"
            }
        }
    }
    
    public override init()
    {
        print("init BBCache")
    }
    
    let _documentFolderForSavingFiles = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    /**
     โหลดข้อมูลจากเครื่อง
     */
    
    open func loadCacheData(key:BBCache.keys, customKey:String? = nil) -> AnyObject?
    {
        let folderName: String = key.folder
        var fileName: String = key.rawValue
        if let key = customKey {
            fileName = "\(fileName)_\(key)"
        }
        
        let strPath = getVersion() + "/" + folderName + "/"
        let dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(strPath) + "/"
        let pathToTheFile = dataPath + fileName
        
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: pathToTheFile) as? Dictionary<String, AnyObject>
        {
            if let value  = data["value"],
               let lifetime = data["lifetime"] as? TimeInterval
            {
                let date = Date().timeIntervalSince1970
                if date < lifetime {
                    return(value as AnyObject)
                }
            }
        }
        return nil
    }
//    
//    open func loadCacheData(key:BBCache.keys, customKey:String? = nil
//        , successCallback: (AnyObject) -> Void
//        , failCallback: () -> Void)
//    {
//        
//        let folderName: String = key.folder
//        var fileName: String = key.rawValue
//        if let key = customKey {
//            fileName = "\(fileName)_\(key)"
//        }
//        
//        let strPath = getVersion() + "/" + folderName + "/"
//        let dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(strPath) + "/"
//        let pathToTheFile = dataPath + fileName
//        
//        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: pathToTheFile) as? Dictionary<String, AnyObject>
//        {
//            if let value  = data["value"],
//                let lifetime = data["lifetime"] as? TimeInterval
//            {
//                let date = Date().timeIntervalSince1970
//                if date < lifetime {
//                    successCallback(value as AnyObject)
//                } else {
//                    failCallback()
//                }
//            } else {
//                failCallback()
//            }
//        } else {
//            failCallback()
//        }
//    }
    /**
     บันทึกข้อมูลลงเครื่อง
     */
    open func saveCacheData(_ ao : AnyObject, key:BBCache.keys, customKey:String? = nil , lifetime:TimeInterval)
    {
        
        let folderName: String = key.folder
        var fileName: String = key.rawValue
        if let key = customKey {
            fileName = "\(fileName)_\(key)"
        }
        
        let strPath = getVersion() + "/" + folderName + "/"
        let dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(strPath) + "/"
        let pathToTheFile = dataPath + fileName
        let theFileManager = FileManager.default
        
        var error: NSError?
        if (!theFileManager.fileExists(atPath: dataPath)) {
            do {
                //set true for create sub folder
                try theFileManager.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
                print(error!)
            }
        }
        
        var data = Dictionary<String, AnyObject>()
        data["value"] = ao
        data["lifetime"] = lifetime as AnyObject
        
        NSKeyedArchiver.archiveRootObject(data, toFile: pathToTheFile)

    }
    
    // MARK: Util
    /**
     ดึงเวอร์ชั่นปัจจุบัน
     */
    fileprivate func getVersion() -> String
    {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "version_" + version.replacingOccurrences(of: ".", with: "_")
        }
        return "no_version_info"
    }
}
