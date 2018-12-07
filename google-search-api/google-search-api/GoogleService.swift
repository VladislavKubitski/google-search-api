//
//  GoogleService.swift
//  google-search-api
//
//  Created by Kubitski Vlad on 07.12.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

import Foundation
import UIKit


class GoogleService: NSObject {
    
    private static let sharedInstance = GoogleService()
    private var sessionTask: DownloadTask?
    private var failure: ((Error) -> Void)?
    private var success: (([String]) -> Void)?
    private var successWithoutLinks: (() -> Void)?
    
    class func sharedManager() -> GoogleService {
        return sharedInstance
    }
    
    private func extractLinks(_ dictionaries: [Any]) -> [String] {
        var links: [String] = []
        for item in dictionaries {
            guard let dictionary = item as? [String: Any],
                let link = dictionary["link"] as? String else {
                    continue
            }
            links.append(link)
        }
        return links
    }
    
    private func parse(_ data: Data, completion: @escaping ([String]?) -> Void) {
        DispatchQueue.global().async {
            do {
                guard let jsonResult = try JSONSerialization.jsonObject(with: data) as? NSDictionary,
                    let dictionaries = jsonResult.object(forKey: "items") as? [Any] else {
                        self.successWithoutLinks?();
                        completion(nil)
                        return
                }
                
                completion( self.extractLinks(dictionaries) )
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
            completion(nil)
        }
    }
    
    func getLinks(requestName: String, success: @escaping ([String]) -> Void, failure: @escaping (Error) -> Void, successWithoutLinks: @escaping () -> Void , viewController: UIViewController) {
        
        self.success = success
        self.failure = failure
        self.successWithoutLinks = successWithoutLinks
        let apiKey = "AIzaSyBSzIS6XKbtu6xXBaPO8wV5A-fGo1t-FP0"
        let bundleId = "com.Kub"
        let searchEngineId = "002118952372014609589:4z7ircc9oni"
        let serverAddress = String(format: "https://www.googleapis.com/customsearch/v1?q=%@&cx=%@&key=%@", requestName, searchEngineId, apiKey)
        
        let url = serverAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let finalUrl = URL(string: url!)
        let request = NSMutableURLRequest(url: finalUrl!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue(bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.setValue("", forHTTPHeaderField: "Accept-Encoding")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        DispatchQueue.global().async {
            let task = session.dataTask(with: request as URLRequest)
            self.sessionTask = GenericDownloadTask(task: task)
            self.sessionTask?.delegate = viewController as? DownloadDelegate
            self.sessionTask?.resume()
        }
    }
    
    func stopRequest() {
        self.sessionTask?.cancel()
    }
    
}


extension GoogleService: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard var task = sessionTask else {
            completionHandler(.cancel)
            return
        }
        task.expectedContentLength = response.expectedContentLength
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard var task = sessionTask else {
            return
        }
        task.buffer.append(data)
        
        let percentageDownloaded = Float(task.buffer.count) / Float(task.expectedContentLength)
        task.progress = percentageDownloaded
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            failure?(error)
        }
        
        guard let data = sessionTask?.buffer else { return }
        
        self.parse(data, completion: { (links) in
            guard let links = links else { return }
            
            self.success?(links)
        })
        sessionTask = nil
        
    }
}

