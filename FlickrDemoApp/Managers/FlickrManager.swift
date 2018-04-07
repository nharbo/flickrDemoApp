//
//  FlickrManager.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import OAuthSwift
class FlickrManager {
    
    static let sharedInstance = FlickrManager()
    private init() { }
    
    //MARK: - Variables
    let realm = RealmManager.sharedInstance
    var publicImages = [Image]()
    // oauth swift object (retain)
//    var oauthswift: OAuthSwift?
    let oauthswift = OAuth1Swift(
        consumerKey:    "2c19e234e56cdb527c82cce28f0b41dc",
        consumerSecret: "6d5ab2dd04827bea",
        requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
        authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
        accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
    )
    var baseApiUrl = "https://api.flickr.com/services/rest/"
    var numberOfPublicImages = 10 //A page goes from 1 - 100 elements
    
    //MARK: - Structs for callbacks
    struct ApiCallStatus {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - API Calls
    func getRecentPublicImages(callback: @escaping (ApiCallStatus) -> Void){
        
        let user = realm.getCurrentUser()!
        let token = user.token!
        let userId = user.user_nsid!
        
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.photos.getRecent",
            "api_key"        : self.getApiKey(),
            "per_page"       : "10",
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z"
        ]
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
                var imageArray = [Image]()
                if let dictionary = jsonDict as? [String: Any] {
//                    print(dictionary)
                    
                }
                
                
//                for element in jsonDict {
//                    console.log(element)
////                    let image = Image()
////                    let url = self.createImageUrlFromAttributes(data: hit.attributes)
////                    image.imageUrl = url
////                    if let id = hit.attributes["id"] as? String { image.id = id}
////                    if let title = hit.attributes["title"] as? String { image.title = title}
////                    if let owner = hit.attributes["owner"] as? String { image.owner = owner}
////                    imageArray.append(image)
//                }
        },
            failure: { error in
                print(error)
        }
        )

//        let url = baseApiUrl + "?api_key=" + self.getApiKey() + "&method=flickr.photos.getRecent&per_page=" + "\(numberOfPublicImages)"
//
//        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
//            .responseString { response in
//
//                var statusCode = response.response?.statusCode
//
//                switch response.result {
//                case .success:
//                    if let string = response.result.value {
//                        // parse xml document
//                        let xml = try! XML.parse(string)
//                        // Enumerate XML elements, convert to urls and add to array
//                        var imageArray = [Image]()
//                        for hit in xml["rsp", "photos", "photo"] {
//                            let image = Image()
//                            let url = self.createImageUrlFromAttributes(data: hit.attributes)
//                            image.imageUrl = url
//                            if let id = hit.attributes["id"] as? String { image.id = id}
//                            if let title = hit.attributes["title"] as? String { image.title = title}
//                            if let owner = hit.attributes["owner"] as? String { image.owner = owner}
//                            imageArray.append(image)
//                        }
//                        let response = ApiCallStatus(success: true, error: nil)
//                        self.publicImages = imageArray
//                        callback(response)
//                    }
//                case .failure(let error):
//                    //TODO: Håndter fejlmeddelser!
//                    statusCode = error._code // statusCode private
//                    print("status code is: \(String(describing: statusCode))")
//                    print(error)
////                    let response = ApiCallStatus(success: false, error: nil)
//
////                    1: Invalid user id
////                    An invalid NSID was passed
////                    2: Popular photos disabled by user
////                    100: Invalid API Key
////                    The API key passed was not valid or has expired.
////                    105: Service currently unavailable
////                    The requested service is temporarily unavailable.
////                    106: Write operation failed
////                    The requested operation failed due to a temporary issue.
////                    111: Format "xxx" not found
////                    The requested response format was not found.
////                    112: Method "xxx" not found
////                    The requested method was not found.
////                    114: Invalid SOAP envelope
////                    The SOAP envelope send in the request could not be parsed.
////                    115: Invalid XML-RPC Method Call
////                    The XML-RPC request document could not be parsed.
////                    116: Bad URL found
////                    One or more arguments contained a URL that has been used for abuse on Flickr.
////                    let response = GetPublicImagesResponse(images: nil, error: error)
////                    data(response)
//                }
//        }
        
    }
    
    func getOwnImages(callback: @escaping (ApiCallStatus) -> Void){
        let user = realm.getCurrentUser()!
        let token = user.token!
        let userId = user.user_nsid!
        
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.people.getPhotos",
            "api_key"        : self.getApiKey(),
            "user_id"        : "me",
            "oauth_token"    : token,
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z"
        ]
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
//                print(jsonDict as Any)
        },
            failure: { error in
                print(error)
        }
        )
    }

    //MARK: - Getters
    func getPublicImages() -> [Image] {
        return self.publicImages
    }
    
    func getOauth() -> OAuth1Swift {
        return self.oauthswift
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
    
    func getApiKey() -> String {
        let path = Bundle.main.path(forResource: "Flickr", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return (dict?.object(forKey: "key") as? String)!
    }
    
    func getApiSecret() -> String {
        let path = Bundle.main.path(forResource: "Flickr", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return (dict?.object(forKey: "secret") as? String)!
    }
    
    
}
