//
//  Configurationkit.swift
//  Pods
//
//  Created by Will Powell on 01/02/2017.
//
//

import Foundation

public class ConfigKit {
    
    public static var account:String = ""
    
    public static var baseURL = "https://www.localizationkit.com/config/";
    
    public static func getConfig(str:String, _ completion: @escaping (Error?, NSDictionary?) -> Swift.Void){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = "\(baseURL)\(account)/\(str)"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    let response = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print(response)
                    completion(nil, json!)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(error,nil)
                }
                
            }else{
                completion(error, nil)
            }
            }.resume()
    }
}
