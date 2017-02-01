//
//  Configurationkit.swift
//  Pods
//
//  Created by Will Powell on 01/02/2017.
//
//

import Foundation

public class ConfigKit {
    
    public static var baseURL = "https://www.localizationkit.com/config/";
    
    public static func getConfig(str:String, _ completion: @escaping (NSDictionary?) -> Swift.Void){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = "\(baseURL)\(str)"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    completion(json!)
                } catch {
                    print("error serializing JSON: \(error)")
                    completion(nil)
                }
                
            }
            }.resume()
    }
}
