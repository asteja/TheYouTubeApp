//
//  APIFetcher.swift
//  TheYouTubeApp
//
//  Created by Saiteja Alle on 10/8/17.
//  Copyright © 2017 Saiteja Alle. All rights reserved.
//

import UIKit
import Alamofire

let API_KEY = "******************"

class APIFetcher: NSObject {
    
    var strNextPageToken = ""
    let sessionManager = Alamofire.SessionManager.default
    
    //MARK: - Search Top 50 Videos
    func getTopVideos(_ nextPageToken : String, _ showLoader : Bool, completion:@escaping (_ videosArray : Array<Dictionary<String, AnyObject>>, _ succses : Bool, _ nextpageToken : String)-> Void){
        
        
        //load Indicator
        if #available(iOS 10.0, *) {
            sessionManager.session.getAllTasks(completionHandler: { (response) in
                response.forEach { $0.cancel() }
            })
            
        } else {
            // Fallback on earlier versions
            sessionManager.session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            })
        }
        
        let contryCode = self.getCountryCode()
        var arrVideo: Array<Dictionary<String, AnyObject>> = []
        var strURL = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&maxResults=50&regionCode=\(contryCode)&key=\(API_KEY)"
        
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(URLRequest(url: URL.init(string: strURL)!)).responseJSON { (responseData) in
            let isSuccess = responseData.result.isSuccess
            if isSuccess {
                
                let resultsDict = responseData.result.value as! [String:Any]
                
                let items = resultsDict["items"] as! [Dictionary<String, AnyObject>]
                
                for i in 0..<items.count {
                    
                    let snippetDict = items[i]["snippet"] as! [String:AnyObject]
                    if !snippetDict["title"]! .isEqual("Private video") && !snippetDict["title"]! .isEqual("Deleted video"){
                        let statisticsDict = items[i]["statistics"] as! Dictionary<String, AnyObject>
                        
                        var videoDetailsDict = Dictionary<String, AnyObject>()
                        videoDetailsDict["videoTitle"] = snippetDict["title"]
                        videoDetailsDict["videoSubTitle"] = snippetDict["channelTitle"]
                        videoDetailsDict["channelId"] = snippetDict["channelId"]
                        videoDetailsDict["imageUrl"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["high"] as! Dictionary<String, AnyObject>)["url"]
                        videoDetailsDict["videoId"] = items[i]["id"] as! NSString //PVideoViewCount
                        videoDetailsDict["viewCount"] = statisticsDict["viewCount"]
                        arrVideo.append(videoDetailsDict)
                    }
                }
                
                
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(arrVideo, true,self.strNextPageToken)
                })
                
            } else {
                
            }
        }
        
    }
    
    
    //MARK: -Search Video with text
    func getVideoWithTextSearch (_ searchText:String, _ nextPageToken:String, completion:@escaping (_ videosArray : Array<Dictionary<String, AnyObject>>,_ succses:Bool,_ nextpageToken:String)-> Void){
        
        
        if #available(iOS 9.0, *) {
            sessionManager.session.getAllTasks(completionHandler: { (response) in
                response.forEach { $0.cancel() }
            })
        } else {
            // Fallback on earlier versions
            sessionManager.session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            })
        }
        
        let contryCode = self.getCountryCode()
        var arrVideo: Array<Dictionary<String, AnyObject>> = []
        var arrVideoFinal: Array<Dictionary<String, AnyObject>> = []
        
        var strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&order=Relevance&q=\(searchText)&regionCode=\(contryCode)&type=video&key=\(API_KEY)"
        
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(URLRequest(url: URL.init(string: strURL)!)).responseJSON { (responseData) in
            let isSuccess = responseData.result.isSuccess
            if isSuccess {
                let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                
                let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                
                let arrayViewCount = NSMutableArray()
                for i in 0..<items.count {
                    
                    let snippetDict = items[i]["snippet"] as! [String:AnyObject]
                    
                    if !snippetDict["title"]! .isEqual("Private video") && !snippetDict["title"]! .isEqual("Deleted video") && items[i]["id"]!["videoId"]! != nil{
                        var videoDetailsDict = Dictionary<String, AnyObject>()
                        arrayViewCount.add(items[i]["id"]!["videoId"]! as! NSString)
                        
                        videoDetailsDict["videoTitle"] = snippetDict["title"]
                        videoDetailsDict["videoSubTitle"] = snippetDict["channelTitle"]
                        videoDetailsDict["channelId"] = snippetDict["channelId"]
                        videoDetailsDict["imageUrl"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["high"] as! Dictionary<String, AnyObject>)["url"]
                        videoDetailsDict["videoId"] = items[i]["id"]!["videoId"]! as! NSString
                        arrVideo.append(videoDetailsDict)
                    }
                }
                
                //Get video count
                
                if arrayViewCount.count > 0{
                    let videoUrlString = "https://www.googleapis.com/youtube/v3/videos?part=statistics&id=\(arrayViewCount.componentsJoined(by: ","))&key=\(API_KEY)"
                    
                    
                    Alamofire.request(URLRequest(url: URL.init(string: videoUrlString)!)).responseJSON { (responseData) in
                        let isSuccess = responseData.result.isSuccess
                        
                        if isSuccess {
                            
                            let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                            let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                            
                            for i in 0..<items.count {
                                
                                var videoDetailsDict = arrVideo[i]
                                let statisticsDict = items[i]["statistics"] as! Dictionary<String, AnyObject>
                                videoDetailsDict["viewCount"] = statisticsDict["viewCount"]
                                arrVideoFinal.append(videoDetailsDict)
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                completion(arrVideoFinal, true,self.strNextPageToken)
                            })
                        }else{
                            DispatchQueue.main.async(execute: { () -> Void in
                                completion(arrVideoFinal, false,self.strNextPageToken)
                            })
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(arrVideoFinal, false,self.strNextPageToken)
                    })
                }
            } else {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(arrVideoFinal, false,self.strNextPageToken)
                })
            }
        }
    }
    
    
    
    //MARK: Get Country code
    func getCountryCode() -> String {
        let local:NSLocale = NSLocale.current as NSLocale
        return local.object(forKey: NSLocale.Key.countryCode) as! String
    }
}

