//
//  PointLogModel.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 25/8/2563 BE.
//

open class PointLog {
    open var userId: String?
    open var info: String?
    open var detail: String?
    open var rowkey: String?
    open var points: Int! = 0
    open var type: String?
    open var timestamp: TimeInterval?
    
    // Extract from detail
    open var productId : String! = "0"
    open var title : String? {
        if LocaleCore.shared.getUserLocale() == 1033 {
            return historyEN
        }
        return historyTH
    }
    open var details = [Dictionary<String, String>]()
    
    open var activityDate : TimeInterval?
    open var period : TimeInterval?
    open var message : String?
    open var responseMessage : String?
    open var userType : String?
    open var buCode : String?
    open var productName : String?
    open var productType : String?
    open var startDate : TimeInterval?
    open var endDate : TimeInterval?
    private var historyTH : String?
    private var historyEN : String?
    open var pointType : String?
    open var historyDetail : String? {
        if LocaleCore.shared.getUserLocale() == 1033 {
            return historyDetailEN
        }
        return historyDetailTH
    }
    private var historyDetailTH : String?
    private var historyDetailEN : String?
    open var periodFormat : String?
    open var transactionDate : TimeInterval?
    open var partitionKey : String?
    open var rowKey : String?
    open var eTag : String?
    
    // type1
    open var para1 : String? {
        if LocaleCore.shared.getUserLocale() == 1033 {
            return para1_en
        }
        return para1_th
    }
    private var para1_th : String?
    private var para1_en : String?
    open var amount : Double?
    
    public init()
    {
        
    }
    
    public init(dict: Dictionary<String, AnyObject>)
    {
        userId = Convert.StringFromObject(dict["UserId"])
        rowkey = Convert.StringFromObject(dict["RowKey"])
        timestamp = Convert.DoubleFromObject(dict["Timestamp"])
        type = Convert.StringFromObject(dict["Type"])
        points = Convert.IntFromObject(dict["Points"])
        info = Convert.StringFromObject(dict["Info"])
        detail = Convert.StringFromObject(dict["Detail"])
        if type == "adjust" {
            historyEN = "coin_adjust".localized(locale: 1033)
            historyTH = "coin_adjust".localized(locale: 1054)
        } else {
            extractDetail()
            customHandle()
        }
    }
    
    func extractDetail() {
        guard let strDetail = detail ,
            let data = strDetail.data(using: String.Encoding.utf8)
            else { return }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, AnyObject>
            {
                
                productId = dict["ProductId"] as? String
                
                if let strDate = dict["ActivityDate"] as? String
                {
                    activityDate = BuzzebeesConvert().dtacDateFormatter(strDate: strDate)
                }
                
                if let strDate = dict["Period"] as? String
                {
                    period = BuzzebeesConvert().dtacDateFormatter(strDate: strDate)
                }
                  
                message  = dict["Message"] as? String
                responseMessage  = dict["ResponseMessage"] as? String
                userType = dict["UserType"] as? String
                buCode = dict["BuCode"] as? String
                if let detailType = dict["type"] as? String
                {
                    type = detailType
                }
                productName = dict["ProductName"] as? String
                productType = dict["ProductType"] as? String
                if let strDate = dict["StartDate"] as? String
                {
                    startDate = BuzzebeesConvert().dtacDateFormatter(strDate: strDate)
                }
                if let strDate = dict["EndDate"] as? String
                {
                    endDate = BuzzebeesConvert().dtacDateFormatter(strDate: strDate)
                }
                historyTH = dict["HistoryTH"] as? String
                historyEN = dict["HistoryEN"] as? String
                pointType = dict["PointType"] as? String
                historyDetailTH = dict["HistoryDetailTH"] as? String
                historyDetailEN = dict["HistoryDetailEN"] as? String
                periodFormat = dict["PeriodFormat"] as? String
                if let strDate = dict["TransactionDate"] as? String
                {
                    transactionDate = BuzzebeesConvert().dtacDateFormatter(strDate: strDate)
                }
                
                partitionKey = dict["PartitionKey"] as? String
                rowKey = dict["RowKey"] as? String
                if let strDate = dict["Timestamp"] as? String
                {
                    timestamp = BuzzebeesConvert().dtacDateFormatter(strDate: strDate)
                    if timestamp != nil {
                        timestamp! += (7 * 60 * 60)
                    }
                }
                eTag = dict["ETag"] as? String
                
                amount = BuzzebeesConvert.DoubleFromObject(dict["Amount"])
                
                if let message = dict["Message"] as? String,
                    let dataMessage = message.data(using: String.Encoding.utf8)
                {
                    if let dictMessage = try JSONSerialization.jsonObject(with: dataMessage, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, AnyObject>
                    {
                        para1_th = dictMessage["para1_th"] as? String
                        para1_en = dictMessage["para1_en"] as? String
                    }
                }
                
            }
        } catch _ {
            
        }
    }
    
    
    func customHandle() {
        if productId == "6" {
            historyTH = getTitleType6(historyTH)
            historyEN = getTitleType6(historyEN)
        }
    }

    func getTitleType6(_ strTitle:String?) -> String? {
        if strTitle == nil
        {
            return strTitle
        }
        var tmpTitle = strTitle!
        if let start = tmpTitle.range(of: "{"),
            let end = tmpTitle.range(of: "}")
        {
            if let format = periodFormat,
                let transactionDate = transactionDate
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = format
                dateFormatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
                dateFormatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
                let range = start.lowerBound..<end.upperBound
                tmpTitle.replaceSubrange(range, with: dateFormatter.string(from: Date(timeIntervalSince1970: transactionDate)))
            }
        }
        return tmpTitle
    }
}

extension BuzzebeesConvert {
    
    func dtacDateFormatter(strDate : String) -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.identifier(fromWindowsLocaleCode: 1033)!)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
//        - key : "Timestamp"
//        - value : 2020-08-17T06:22:40.5070891Z
//        - key : "TransactionDate"
//        - value : 2020-08-17T13:22:40.4835231Z
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        if let date = formatter.date(from: strDate) {
            return date.timeIntervalSince1970
        }

//        - key : "StartDate"
//        - value : 2020-08-01T00:00:00Z
//        - key : "EndDate"
//        - value : 2020-12-01T23:59:59Z
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = formatter.date(from: strDate) {
            return date.timeIntervalSince1970
        }
        
//        - key : "Period"
//        - value : 2020-08-15T00:00:00
//        - key : "ActivityDate"
//        - value : 2020-08-15T15:12:00
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: strDate) {
            return date.timeIntervalSince1970
        }
        
        return nil
    }
}
