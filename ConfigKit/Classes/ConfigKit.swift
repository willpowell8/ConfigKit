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
    public static var isFixed:Bool = false
    public static var branch:String = ""
    public static var account:String = ""
    public static var mode:String = "STANDARD"
    
    public static var isReachable:Bool = true
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
    
    public static func startFromPlist()->Bool{
        //get the path of the plist file
        guard let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") else { return false }
        //load the plist as data in memory
        guard let plistData = FileManager.default.contents(atPath: plistPath) else { return false }
        //use the format of a property list (xml)
        var format = PropertyListSerialization.PropertyListFormat.xml
        //convert the plist data to a Swift Dictionary
        guard let  plistDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String : AnyObject] else { return false }
        //access the values in the dictionary
        if let value = plistDict["CONFIG_FIXED"] as? Bool, value == true {
            self.isFixed = true
            if let acc = plistDict["CONFIG_ACCOUNT"] as? String{
                account = acc
            }
            if let bra = plistDict["CONFIG_BRANCH"] as? String{
                branch = bra
            }
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: nil)
            return true
        }else{
            return false
        }
        
    }
    
        
    public func getConfig(str:String, _ completion: @escaping (ConfigKitError?, [AnyHashable:Any]?, ConfigKitSource?) -> Swift.Void){
        var urlString = ConfigKit.baseURL.replacingOccurrences(of: "{{account}}", with: ConfigKit.account)
        urlString = urlString.replacingOccurrences(of: "{{branch}}", with: ConfigKit.branch)
        urlString = urlString.replacingOccurrences(of: "{{documentId}}", with: str)
        urlString += "?mode=" + ConfigKit.mode
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
                        
                            if json["error"] != nil || json["errorMessage"] != nil {
                                self.checkOffline(urlString: urlString, onlineError:ConfigKitError.responseError, completion)
                            }else{
                                if let dataSet = data {
                                    let responseString = String(data: dataSet, encoding: .utf8)
                                    UserDefaults.standard.set(responseString, forKey: urlString)
                                    UserDefaults.standard.synchronize()
                                }
                                completion(nil, json, .online)
                            }
                        }else{
                            self.checkOffline(urlString: urlString, onlineError:ConfigKitError.parseError, completion)
                        }
                        
                    } catch {
                        self.checkOffline(urlString: urlString, onlineError:ConfigKitError.parseError, completion)
                    }
                    
                }else{
                    self.checkOffline(urlString: urlString, onlineError:ConfigKitError.serverError, completion)
                }
                }.resume()
        }else{
            checkOffline(urlString: urlString, onlineError:nil, completion)
        }
    }
    
    func checkOffline(urlString:String, onlineError:ConfigKitError?, _ completion: @escaping (ConfigKitError?, [AnyHashable:Any]?, ConfigKitSource?) -> Swift.Void) -> Void{
        if let string = UserDefaults.standard.string(forKey: urlString) {
            do {
                let data = string.data(using: .utf8)
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable:Any] {
                    completion(onlineError, json, .offline)
                    return;
                }else{
                    completion(ConfigKitError.noOfflineData, nil, nil)
                    return
                }
            }catch {
                completion(ConfigKitError.noOfflineData, nil, nil)
                return
            }
        }
        
        completion(ConfigKitError.noOfflineData, nil, nil)
    }
}
