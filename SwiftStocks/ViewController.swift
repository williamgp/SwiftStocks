//
//  ViewController.swift
//  SwiftStocks
//
//  Created by William Peregoy on 2015/11/6.
//  Copyright © 2015年 William Peregoy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    //1
    private var stocks: [(String,Double)] = [("AAPL",+0.0),("FB",+0.0),("GOOG",-0.0)]
    
    //Stock updates
    //3
    func updateStocks() {
        let stockManager:StockManagerSingleton = StockManagerSingleton.sharedInstance
        stockManager.updateListOfSymbols(stocks)
        
        //Repeat this method after 15 secs. (For simplicity of the tutorial we are not cancelling it never)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(15 * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            {
                self.updateStocks()
            }
            )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stocksUpdated:", name: kNotificationStocksUpdated, object: nil)
        
        self.updateStocks()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    
    //4
    func stocksUpdated(notification: NSNotification) {
        let values = (notification.userInfo as! Dictionary< String, NSArray>)
        let stocksReceived:NSArray = values[kNotificationStocksUpdated]!
        stocks.removeAll(keepCapacity: false)
        for quote in stocksReceived {
            let quoteDict:NSDictionary = quote as! NSDictionary
            let change = quoteDict["Change"] as! String
            let changeInt = Double(change)!
            let lastTradePrice = quoteDict["LastTradePriceOnly"] as! String
            let lastPriceDouble = Double(lastTradePrice)!
            let changeInPercent = round((changeInt / lastPriceDouble) * 100000) / 1000
            let changeInPercentString = "\(changeInPercent)"
            
            let changeInPercentStringClean: NSString = (changeInPercentString as NSString).substringToIndex((changeInPercentString.characters.count)-1)
            stocks.append(quoteDict["symbol"] as! String,changeInPercentStringClean.doubleValue)
        }
        tableView.reloadData()
        NSLog("Symbols Values updated :)")
    }

    
    //2
    //UITableViewDataSource
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int)  -> Int {
        
        return stocks.count
    
        }
    
    //3
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cellId")
    
        cell.textLabel!.text = stocks[indexPath.row].0 //position 0 of the tuple: The Symbol "AAPL"
        cell.detailTextLabel!.text = "\(stocks[indexPath.row].1)" + "%" //position 1 of the tuple: The value "99" into String
    
        return cell
    }
    
    //4
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        _ = StockManagerSingleton.sharedInstance
        
    }
    
    
    
    //Customize the cell
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            //1
            switch stocks[indexPath.row].1 {
                case let x where x < 0.0:
                    cell.backgroundColor = UIColor.redColor()
                case let x where x > 0.0:
                    cell.backgroundColor = UIColor.greenColor()
                case _:
                    cell.backgroundColor = UIColor.blueColor()
            }
        
        //2
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.detailTextLabel!.textColor = UIColor.whiteColor()
            cell.textLabel!.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 48)
            cell.detailTextLabel!.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 48)
            cell.textLabel!.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            cell.textLabel!.shadowOffset = CGSize(width: 0, height: 1)
            cell.detailTextLabel!.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            cell.detailTextLabel!.shadowOffset = CGSize(width: 0, height: 1)
        }
    
    //Customize the height of the cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //3
        return 120
    }
}
