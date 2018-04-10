//
//  InfoMessage.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 10/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import Whisper

enum InfoMessageType {
    case Alert
    case Info
    case NoInternet
    case Default
}

class InfoMessage {
    
    static func presentInfoMessageWithTitle(title: String, ofType type: InfoMessageType) {
        let murmur = Murmur(title: title, backgroundColor: infoMessageColor(type: type), titleColor: UIColor.white, font: UIFont.systemFont(ofSize: 16.0))
        show(whistle: murmur, action: .show(4.0))
    }
    
    private static func infoMessageColor(type: InfoMessageType) -> UIColor {
        switch type {
        case .Alert:
            return UIColor(hexString: "#F66B73")
        case .Info:
            return UIColor(red: 30 / 255, green: 225 / 255, blue: 145 / 255, alpha: 0.85)
        case .NoInternet:
            return UIColor(red: 45 / 255, green: 145 / 255, blue: 200 / 255, alpha: 0.85)
        default:
            return UIColor(red: 30 / 255, green: 225 / 255, blue: 145 / 255, alpha: 0.85)
        }
    }
    
}
