//
//  FlickrManager.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser

class FlickrManager {
    
    static let sharedInstance = FlickrManager()
    private init() { }
    
    //MARK: - Variables
    var publicImages = [Image]()
    
    //MARK: - Structs for callbacks
    struct GetPublicImagesResponse {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - Getters
    func getRecentPublicImages(data: @escaping (GetPublicImagesResponse) -> Void){

        //Getting the latest 10 images - maybe up it to more later.
        let url = "https://api.flickr.com/services/rest/?api_key=2c19e234e56cdb527c82cce28f0b41dc&method=flickr.photos.getRecent&per_page=10"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseString { response in
                
                var statusCode = response.response?.statusCode
                
                switch response.result {
                case .success:
                    if let string = response.result.value {
                        // parse xml document
                        let xml = try! XML.parse(string)
                        // Enumerate XML elements, convert to urls and add to array
                        var imageArray = [Image]()
                        for hit in xml["rsp", "photos", "photo"] {
                            let image = Image()
                            let url = self.createImageUrlFromAttributes(data: hit.attributes)
                            image.imageUrl = url
                            if let id = hit.attributes["id"] as? String { image.id = id}
                            if let title = hit.attributes["title"] as? String { image.title = title}
                            if let owner = hit.attributes["owner"] as? String { image.owner = owner}
                            imageArray.append(image)
                        }
                        let response = GetPublicImagesResponse(success: true, error: nil)
                        self.publicImages = imageArray
                        data(response)
                    }
                case .failure(let error):
                    //TODO: Håndter fejlmeddelser!
                    statusCode = error._code // statusCode private
                    print("status code is: \(String(describing: statusCode))")
                    print(error)
//                    1: Invalid user id
//                    An invalid NSID was passed
//                    2: Popular photos disabled by user
//                    100: Invalid API Key
//                    The API key passed was not valid or has expired.
//                    105: Service currently unavailable
//                    The requested service is temporarily unavailable.
//                    106: Write operation failed
//                    The requested operation failed due to a temporary issue.
//                    111: Format "xxx" not found
//                    The requested response format was not found.
//                    112: Method "xxx" not found
//                    The requested method was not found.
//                    114: Invalid SOAP envelope
//                    The SOAP envelope send in the request could not be parsed.
//                    115: Invalid XML-RPC Method Call
//                    The XML-RPC request document could not be parsed.
//                    116: Bad URL found
//                    One or more arguments contained a URL that has been used for abuse on Flickr.
//                    let response = GetPublicImagesResponse(images: nil, error: error)
//                    data(response)
                }
        }
        
    }
    
    func getPublicImages() -> [Image] {
        return self.publicImages
    }
    
    //MARK: - Setters
    
    
    //MARK: - HelperMethods
    func createImageUrlFromAttributes(data: [String:String]) -> String {
        var url = ""
        var farmIdForUrl = ""
        var serverIdForUrl = ""
        var idForUrl = ""
        var secretForUrl = ""
        
        if let farmId = data["farm"] as? String { farmIdForUrl = farmId}
        if let serverId = data["server"] as? String { serverIdForUrl = serverId}
        if let id = data["id"] as? String { idForUrl = id}
        if let secret = data["secret"] as? String { secretForUrl = secret}
        
        url = "https://farm\(farmIdForUrl).staticflickr.com/\(serverIdForUrl)/\(idForUrl)_\(secretForUrl).jpg"

        return url
    }
    
    
}
