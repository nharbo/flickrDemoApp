//
//  FlickrManager.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import Alamofire

class FlickrManager {
    
    static let sharedInstance = FlickrManager()
    private init() { }
    
    //MARK: - Structs for callbacks
    struct GetPublicImagesResponse {
        var images: [String]?
        var error: NSError?
    }
    
    //MARK: - Getters
    func getRecentPublicImages(data: @escaping (GetPublicImagesResponse) -> Void){
        let response = GetPublicImagesResponse(images: ["111", "222"], error: nil)
        data(response)

        let url = "https://api.flickr.com/services/rest/?api_key=2c19e234e56cdb527c82cce28f0b41dc&method=flickr.photos.getRecent&per_page=10"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseString { response in
                print(" - API url: \(String(describing: response.request!))")   // original url request
                var statusCode = response.response?.statusCode
                
                switch response.result {
                case .success:
                    print("status code is: \(String(describing: statusCode))")
                    if let string = response.result.value {
                        print("XML: \(string)")
                    }
                case .failure(let error):
                    //TODO: Håndter fejlmeddelser!
                    statusCode = error._code // statusCode private
                    print("status code is: \(String(describing: statusCode))")
                    print(error)
                }
        }
        
        
        
        
    }
    
    //MARK: - Setters
    
    
    //MARK: - HelperMethods
    func getImageUrlFromId(){
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    }
    
    
}
