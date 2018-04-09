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
import MapKit
import OAuthSwift
class FlickrManager {
    
    static let sharedInstance = FlickrManager()
    private init() { }
    
    //MARK: - Variables
    var publicImages = [Image]()
    var ownImages = [Image]()
    
    //MARK: - Constants
    let realm = RealmManager.sharedInstance

    let oauthswift = OAuth1Swift(
        consumerKey:    "2c19e234e56cdb527c82cce28f0b41dc",
        consumerSecret: "6d5ab2dd04827bea",
        requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
        authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
        accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
    )
    let numberOfPublicImages = "100" //A page goes from 1 - 100 elements
    let baseApiUrl = "https://api.flickr.com/services/rest/"
    
    
    //MARK: - Enums
    enum ImageArrayType {
        case own
        case _public
    }
    
    //Custom en/decoder to handle geolocation, as it can be both Int and String when getting the result.
    enum AngularDistance: Codable {
        case string(String), integer(Int)
        
        func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let str):
                var container = encoder.singleValueContainer()
                try container.encode(str)
            case .integer(let int):
                var container = encoder.singleValueContainer()
                try container.encode(int)
            }
        }
        
        init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                let str = try container.decode(String.self)
                self = AngularDistance.string(str)
            }
            catch {
                let container = try decoder.singleValueContainer()
                let int = try container.decode(Int.self)
                self = AngularDistance.integer(int)
            }
        }
    }
    
    //MARK: - Structs
    struct CallStatus {
        var success: Bool
        var error: String?
    }
    
    //For decoding json for images
    struct UserCallStatus {
        var success: Bool
        var user: User?
        var error: String?
    }
    
    struct JsonObj: Decodable {
        let photos: Photos
    }
    
    struct Photos: Decodable {
        let page: Int
        let pages: Int
        let perpage: Int
        let photo: [JPhoto]
    }

    struct JPhoto: Decodable {
        let id: String
        let farm: Int
        let secret: String
        let server: String
        let owner: String
        let title: String
        var latitude: AngularDistance //Can be both String and Double
        var longitude: AngularDistance //Can be both String and Double
    }
    
    //For decoding json for user calls
    struct JsonObj2: Decodable {
        let person: Person
    }
    
    struct Person: Decodable {
        let iconfarm: Int
        let iconserver: String
        let id: String
        let realname: RealName
        let username: UserName
    }
    
    struct RealName: Decodable {
        let _content: String
    }
    
    struct UserName: Decodable {
        let _content: String
    }
    
    //MARK: - API Calls
    //Gets the most recent images, and saves them as an Image object including geolocation and image url
    func getRecentPublicImages(callback: @escaping (CallStatus) -> Void){

        let parameters :Dictionary = [
            "method"         : "flickr.photos.getRecent",
            "api_key"        : self.getApiKey(),
            "per_page"       : numberOfPublicImages,
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z,geo"
        ]
        let _ = oauthswift.client.get(
            baseApiUrl, parameters: parameters,
            success: { response in

                self.decodeJsonAsDataAndPutToImageArray(data: response.data, arrayToUpdate: ._public, callback: { (response) in
                    if response.success {
                        let response = CallStatus(success: true, error: nil)
                        callback(response)
                    } else {
                        let response = CallStatus(success: false, error: response.error)
                        callback(response)
                    }
                })
        },
            failure: { error in
                print(error)
//                TODO: Håndter fejlmeddelser!
//                let response = ApiCallStatus(success: false, error: nil)
//
//                1: Invalid user id
//                An invalid NSID was passed
//                2: Popular photos disabled by user
//                100: Invalid API Key
//                The API key passed was not valid or has expired.
//                105: Service currently unavailable
//                The requested service is temporarily unavailable.
//                106: Write operation failed
//                The requested operation failed due to a temporary issue.
//                111: Format "xxx" not found
//                The requested response format was not found.
//                112: Method "xxx" not found
//                The requested method was not found.
//                114: Invalid SOAP envelope
//                The SOAP envelope send in the request could not be parsed.
//                115: Invalid XML-RPC Method Call
//                The XML-RPC request document could not be parsed.
//                116: Bad URL found
//                One or more arguments contained a URL that has been used for abuse on Flickr.
//                let response = GetPublicImagesResponse(images: nil, error: error)
//                data(response)
        }
        )
        
    }
    
    //Gets the users own images, and saves them as an Image object including geolocation and image url
    func getOwnImages(callback: @escaping (CallStatus) -> Void){
        let user = realm.getCurrentUser()!
        let token = user.token!

        let parameters :Dictionary = [
            "method"         : "flickr.people.getPhotos",
            "api_key"        : self.getApiKey(),
            "user_id"        : "me",
            "oauth_token"    : token,
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z,geo"
        ]
        let _ = oauthswift.client.get(
            baseApiUrl, parameters: parameters,
            success: { response in

                self.decodeJsonAsDataAndPutToImageArray(data: response.data, arrayToUpdate: .own, callback: { (response) in
                    if response.success {
                        let response = CallStatus(success: true, error: nil)
                        callback(response)
                    } else {
                        let response = CallStatus(success: false, error: response.error)
                        callback(response)
                    }
                })

        },
            failure: { error in
                print(error)
                //TODO: Handle errors
        }
        )
    }
    
    //Gets the info about a user, such as profile imageurl, username, full name etc.
    func getInfoForUser(userId: String, callback: @escaping (UserCallStatus) -> Void) {
        
        let parameters :Dictionary = [
            "method"         : "flickr.people.getInfo",
            "api_key"        : self.getApiKey(),
            "user_id"        : userId,
            "format"         : "json",
            "nojsoncallback" : "1",
        ]
        let _ = oauthswift.client.get(
            baseApiUrl, parameters: parameters,
            success: { response in
                print(try! response.jsonObject())
                //Map json
                guard let data = response.data as? Data else {
                    print("Error: No data to decode")
                    let response = UserCallStatus(success: false, user: nil, error: "Error: No data to decode")
                    callback(response)
                    return
                }
                
                guard let person = try? JSONDecoder().decode(JsonObj2.self, from: data) else {
                    print("Error: Couldn't decode data into Person")
                    let response = UserCallStatus(success: false, user: nil, error: "Error: Couldn't decode data into Person")
                    callback(response)
                    return
                }
                
                let user = User()
                user.user_nsid = person.person.id
                user.fullname = person.person.realname._content
                user.username = person.person.username._content
                user.iconFarm = person.person.iconfarm
                user.iconServer = person.person.iconserver
                user.profileImageUrl = self.createProfileImageUrlFromAttributes(data: ["farm":person.person.iconfarm, "server":person.person.iconserver, "id":person.person.id])
                
                if person.person.id == self.realm.getCurrentUser()?.user_nsid! {
                    //If userId = currentUser.userId, sync information with realm
                    self.realm.setUserData(user: user) //Updates the current user
                    let response = UserCallStatus(success: true, user: nil, error: nil)
                    callback(response)
                } else {
                    //return user
                    let response = UserCallStatus(success: true, user: user, error: nil)
                    callback(response)
                }
    
        },
            failure: { error in
                print(error)
                //TODO: Handle errors
        }
        )
    }

    //MARK: - Getters
    func getPublicImages() -> [Image] {
        return self.publicImages
    }
    
    func getOwnImages() -> [Image] {
        return self.ownImages
    }
    
    func getOauth() -> OAuth1Swift {
        return self.oauthswift
    }
    
    //MARK: - Setters
    
    
    //MARK: - HelperMethods
    
    //Maps Json object to Image object, and puts it in the array that matches
    func decodeJsonAsDataAndPutToImageArray(data: Data, arrayToUpdate: ImageArrayType, callback: @escaping (CallStatus) -> Void ){
        guard let data = data as? Data else {
            print("Error: No data to decode")
            let response = CallStatus(success: false, error: "Error: No data to decode")
            callback(response)
            return
        }
        
        guard let photos = try? JSONDecoder().decode(JsonObj.self, from: data) else {
            print("Error: Couldn't decode data into Photos")
            let response = CallStatus(success: false, error: "Error: Couldn't decode data into Photos")
            callback(response)
            return
        }
        
        //Map photos to Image-object
        var imageArray = [Image]()
        for photo in photos.photos.photo {
            let image = Image()

            //This is needed, as the server not always gives an url_z in return.
            image.imageUrl = self.createImageUrlFromAttributes(data: ["farm":photo.farm, "server":photo.server, "id":photo.id, "secret":photo.secret])
            
            if let id = photo.id as? String { image.id = id}
            if let title = photo.title as? String { image.title = title}
            if let owner = photo.owner as? String { image.owner = owner}
            if let lat = photo.latitude as? AngularDistance {
                //Convert lat to Double, if there's a geolocation
                let latString = "\(lat))";
                let result = latString.split(separator: "\"")
                if result.count > 1 {
                    image.lat = Double(result[1])!
                } else {
                    image.lat = 0.0
                }
            }
            if let long = photo.longitude as? AngularDistance {
                //Convert long to Double, if there's a geolocation
                let longString = "\(long))";
                let result = longString.split(separator: "\"")
                if result.count > 1 {
                    image.long = Double(result[1])!
                } else {
                    image.long = 0.0
                }
            }
            imageArray.append(image)
        }
        
        //Update the right array
        switch arrayToUpdate {
        case ._public:
            self.publicImages = imageArray
        case .own:
            self.ownImages = imageArray
        default:
            print("ERROR: Array not found!")
        }
        
        let response = CallStatus(success: true, error: nil)
        callback(response)
        
    }
    
    func createImageUrlFromAttributes(data: [String:Any]) -> String {
        
        var url = ""
        var farmIdForUrl = ""
        var serverIdForUrl = ""
        var idForUrl = ""
        var secretForUrl = ""

        if let farmId = data["farm"] as? Int { farmIdForUrl = "\(farmId)"}
        if let serverId = data["server"] as? String { serverIdForUrl = serverId}
        if let id = data["id"] as? String { idForUrl = id}
        if let secret = data["secret"] as? String { secretForUrl = secret}

        url = "https://farm\(farmIdForUrl).staticflickr.com/\(serverIdForUrl)/\(idForUrl)_\(secretForUrl).jpg"

        return url
    }
    
    func createProfileImageUrlFromAttributes(data: [String:Any]) -> String {
        
        var url = ""
        var farmIdForUrl = ""
        var iconServerForUrl = ""
        var idForUrl = ""
        
        if let farmId = data["farm"] as? Int { farmIdForUrl = "\(farmId)"}
        if let serverId = data["server"] as? String { iconServerForUrl = serverId}
        if let id = data["id"] as? String { idForUrl = id}
        
        url = "https://farm\(farmIdForUrl).staticflickr.com/\(iconServerForUrl)/buddyicons/\(idForUrl)_l.jpg" //_s = 60x60, _m = 100x100, _l = 150x150
        
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
