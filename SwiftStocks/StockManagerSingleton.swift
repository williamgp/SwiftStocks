//
//  StockManagerSingleton.swift
//  SwiftStocks
//
//  Created by William Peregoy on 2015/11/6.
//  Copyright © 2015年 William Peregoy. All rights reserved.
//

import Foundation
let kNotificationStocksUpdated = "stocksUpdated"

class StockManagerSingleton {
    
    //Singleton Init
    class var sharedInstance : StockManagerSingleton {
        struct Static {
            static let instance : StockManagerSingleton = StockManagerSingleton()
        }
        return Static.instance
    }
    
    /*!
    * @discussion Function that given an array of symbols, get their stock prizes from yahoo and send them inside a NSNotification UserInfo
    * @param stocks An Array of tuples with the symbols in position 0 of each tuple
    */
    func updateListOfSymbols(stocks:Array<(String,Double)>) ->() {
        
        //1: YAHOO Finance API: Request for a list of symbols example:
        //http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.quotes where symbol IN ("AAPL","GOOG","FB")&format=json&env=http://datatables.org/alltables.env
        
        //2: Build the URL as above with our array of symbols
        var stringQuotes = "("
        
        for quoteTuple in stocks {
            
            stringQuotes = stringQuotes+"\""+quoteTuple.0+"\","
            
        }
        
        stringQuotes = stringQuotes.substringToIndex(stringQuotes.endIndex.predecessor())
        
        stringQuotes = stringQuotes + ")"
        
        //https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%22%2C%22AAPL%22%2C%22GOOG%22%2C%22MSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=
        
        //http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.quotes where symbol IN ("AAPL","GOOG","FB")&format=json&env=http://datatables.org/alltables.env

        
        //let urlString:String = ("https://query.yahooapis.com/v1/public/yql?q=select from yahoo.finance.quotes where symbol IN "+stringQuotes+"&format=json&env=http://datatables.org/alltables.env").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let realStringQuotes = stringQuotes.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let urlString:String = ("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20"+realStringQuotes!+"&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
        
        print(urlString)
        
        //let url : NSURL = NSURL(string: urlString)!
        
        let url = NSURL(string: urlString)
        
      //print(url)
        
        let request: NSURLRequest = NSURLRequest(URL:url!)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: config)
        
        //3: Completion block/Clousure for the NSURLSessionDataTask
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if((error) != nil) {
        
                print(error!.localizedDescription)
            
            } else {
                
                let _: NSError?
                
                //4: JSON process
                let jsonDict = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
               
                if data != nil  {
                    
                    //5: Extract the Quotes and Values and send them inside a NSNotification
                    let quotes:NSArray = ((jsonDict.objectForKey("query") as! NSDictionary).objectForKey("results") as! NSDictionary).objectForKey("quote") as! NSArray
                    
                    dispatch_async(dispatch_get_main_queue(), {
                    
                        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationStocksUpdated, object: nil, userInfo: [kNotificationStocksUpdated:quotes])
                    
                    })
                }
            }
        })
        
        //6: DONT FORGET to LAUNCH the NSURLSessionDataTask!!!!!!
        task.resume()
    }
}
