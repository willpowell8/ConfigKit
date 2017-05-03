//
//  Configurationkit.swift
//  Pods
//
//  Created by Will Powell on 01/02/2017.
//
//

import Foundation
import ReachabilitySwift

public enum ConfigKitError: String, Error {
    case serverError = "Server Comms Error"
    case responseError = "Response Error"
    case parseError = "Parse Error"
    case noOfflineData = "No Offline Data"
}

public enum ConfigKitSource: String {
    case online = "online"
    case offline = "offline"
}

public class ConfigKit {
    
    public static var instance = ConfigKit()
    public static var branch:String = ""
    public static var account:String = ""
    
    private static var isReachable:Bool = true
    private static var baseURL = "https://y4wsadz8hf.execute-api.eu-west-1.amazonaws.com/ConfigStage/{{account}}/version/{{branch}}/document/{{documentId}}/raw";
    
    public static func start(branch:String, account:String){
        self.branch = branch
        self.account = account
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: nil)
    }
    
    @objc private static func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        isReachable = reachability.isReachable
    }
    
    public static func getConfig(str:String, _ completion: @escaping (ConfigKitError?, [AnyHashable:Any]?, ConfigKitSource?) -> Swift.Void){
        instance.getConfig(str: str, completion)
    }
    
        
    public func getConfig(str:String, _ completion: @escaping (ConfigKitError?, [AnyHashable:Any]?, ConfigKitSource?) -> Swift.Void){
        var urlString = ConfigKit.baseURL.replacingOccurrences(of: "{{account}}", with: ConfigKit.account)
        urlString = urlString.replacingOccurrences(of: "{{branch}}", with: ConfigKit.branch)
        urlString = urlString.replacingOccurrences(of: "{{documentId}}", with: str)
        
        if ConfigKit.isReachable == true {
            // App registered as online
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let url = URL(string: urlString as String)
            session.dataTask(with: url!) {
                (data, response, error) in
                if (response as? HTTPURLResponse) != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable:Any] {
                        
                            if (json["error"] as? [AnyHashable:Any]?) != nil {
                                print("ERROR")
                                completion(.responseError, nil, nil)
                            }else{
                                if let dataSet = data {
                                    let responseString = String(data: dataSet, encoding: .utf8)
                                    UserDefaults.standard.set(responseString, forKey: urlString)
                                    UserDefaults.standard.synchronize()
                                }
                                completion(nil, json, .online)
                            }
                        }else{
                            completion(.parseError, nil, nil)
                        }
                        
                    } catch {
                        completion(ConfigKitError.parseError,nil, nil)
                    }
                    
                }else{
                    completion(ConfigKitError.serverError, nil, nil)
                }
                }.resume()
        }else{
            if let string = UserDefaults.standard.string(forKey: urlString) {
                do {
                    let data = string.data(using: .utf8)
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable:Any] {
                        completion(nil, json, .offline)
                        return;
                    }
                }catch {
                    completion(ConfigKitError.noOfflineData, nil, nil)
                    return
                }
            }
            
            completion(ConfigKitError.noOfflineData, nil, nil)
        }
    }
}
