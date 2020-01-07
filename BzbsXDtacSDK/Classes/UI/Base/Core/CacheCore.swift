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
    public override init()
    {
        print("init BBCache");
    }
    
    let _documentFolderForSavingFiles = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    /**
     โหลดข้อมูลจากเครื่อง
     */
    open func loadCacheData(_ folderName: String
        , fileName: String
        , isArchiver: Bool = false
        , successCallback: (AnyObject) -> Void
        , failCallback: () -> Void)
    {
        //        var dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(getVersion() + "/" + folderName);
        //        dataPath = dataPath.stringByAppendingString("/");
        //        let pathToTheFile = dataPath.stringByAppendingString(fileName);
        let strPath = getVersion() + "/" + folderName + "/";
        let dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(strPath) + "/";
        let pathToTheFile = dataPath + fileName;
        
        if(isArchiver == true)
        {
            if let data = NSKeyedUnarchiver.unarchiveObject(withFile: pathToTheFile)
            {
                successCallback(data as AnyObject);
            }else{
                failCallback();
            }
        }else{
            var error:NSError?
            var stringJSON: String?
            do {
                stringJSON = try String(contentsOfFile: pathToTheFile, encoding:String.Encoding.utf8)
            } catch let error1 as NSError {
                error = error1
                stringJSON = nil
            }
            if let theError = error {
                print("\(theError.localizedDescription)", terminator: "");
                failCallback();
                return;
            }
            
            // convert String to NSData
            let data: Data = stringJSON!.data(using: String.Encoding.utf8)!
            // convert NSData to 'AnyObject'
            do {
                let anyObj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                
                successCallback(anyObj as AnyObject);
                return;
            } catch let error1 as NSError {
                error = error1
            }
            
            if let _ = error {
                failCallback();
                return;
            }
        }
    }
    /**
     บันทึกข้อมูลลงเครื่อง
     */
    open func saveCacheData(_ ao : AnyObject
        , folderName: String
        , fileName: String
        , isArchiver: Bool = false)
    {
        // Get Path
        //        var dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(getVersion() + "/" + folderName);
        //        dataPath = dataPath.stringByAppendingString("/");
        //        let pathToTheFile = dataPath.stringByAppendingString(fileName);
        let strPath = getVersion() + "/" + folderName + "/";
        let dataPath = _documentFolderForSavingFiles.stringByAppendingPathComponent(strPath) + "/";
        let pathToTheFile = dataPath + fileName;
        
        if(isArchiver == true)
        {
            let theFileManager = FileManager.default
            
            var error: NSError?
            if (!theFileManager.fileExists(atPath: dataPath)) {
                do {
                    //set true for create sub folder
                    try theFileManager.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
                } catch let error1 as NSError {
                    error = error1
                    print(error!);
                };
            }
            
            NSKeyedArchiver.archiveRootObject(ao, toFile: pathToTheFile);
        }else{
            // Convert to string json
            let stringJSON = Convert.JSONStringify(ao, prettyPrinted: true)
            let theFileManager = FileManager.default
            
            var error: NSError?
            if (!theFileManager.fileExists(atPath: dataPath)) {
                do {
                    //set true for create sub folder
                    try theFileManager.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
                } catch let error1 as NSError {
                    error = error1
                    print(error!);
                };
            }
            
            var theWriteError: NSError?
            do {
                try stringJSON.write(toFile: pathToTheFile, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                theWriteError = error
            }
            
            if theWriteError == nil
            {
                //            println("Success \(stringJSON)")
            }else{
                print("Error \(String(describing: theWriteError))")
            }
        }
    }
    
    // MARK: Util
    /**
     ดึงเวอร์ชั่นปัจจุบัน
     */
    fileprivate func getVersion() -> String
    {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "version_" + version.replacingOccurrences(of: ".", with: "_");
        }
        return "no_version_info"
    }
}
