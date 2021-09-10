//
//  NetworkManager.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() { }
    
    func makeRequest(url: String,
                     params: Parameters = [:],
                     headers: HTTPHeaders = [:],
                     completion: @escaping (Data) -> Void) {
        
        AF.request(url, parameters: params, headers: headers).responseData { response in
            
            guard let data = response.data,
                  response.error == nil else {
                print("Error when make request: \(response.error?.localizedDescription ?? "no data")")
                return
            }
            
            if let responseHeaders = response.response?.allHeaderFields {
                if let count = responseHeaders["pagination-count"] as? Int {
                    print("count: \(count)")
                }
                completion(data)
            }
        }
    }
    
    func makeRequest(url: String,
                     params: Parameters = [:],
                     headers: HTTPHeaders = [:],
                     completion: @escaping ([AnyHashable:Any]) -> Void) {
        
        AF.request(url, parameters: params, headers: headers).response { response in
            
            guard let responseHeaders = response.response?.allHeaderFields else { return }
            completion(responseHeaders)
        }
    }
}
