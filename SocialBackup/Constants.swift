//
//  Constants.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/10/24.
//

import Foundation
import SwiftUI

struct Constants {
    
    struct Additional {
        
        static let coreDataModelName = "SocialBackup"
        
    }
    
    struct FontName {
        
        private static let oblique = "Oblique"
        
        static let light = "avenir-light"
        static let lightOblique = light + oblique
        static let body = "avenir-book"
        static let bodyOblique = body + oblique
        static let medium = "avenir-medium"
        static let mediumOblique = medium + oblique
        static let heavy = "avenir-heavy"
        static let heavyOblique = heavy + oblique
        static let black = "avenir-black"
        static let blackOblique = black + oblique
        static let appname = "copperplate"
        
    }
    
    struct Networking {
        
        struct TikTokServer {
            
            struct Endpionts {
                
                static let getVideoInfo = "/getVideoInfo"
                
            }
            
            static let baseURL = "https://chitchatserver.com:9100/v1"
            
        }
        
    }
    
}

struct Colors {
//    static let accentColor = Color("UserChatBubbleColor")
    static let alertTintColor = Color(uiColor: UIColor(named: "ElementBackgroundColor")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)))
    static let background = Color("ChatBackgroundColor")
    static let buttonBackground = Color("UserChatBubbleColor")
    static let foreground = Color("ForegroundColor")
    static let userChatBubbleColor = Color("UserChatBubbleColor")
    static let userChatTextColor = Color("UserChatTextColor")
    static let aiChatBubbleColor = Color("AIChatBubbleColor")
    static let aiChatTextColor = Color("AIChatTextColor")
    static let elementBackgroundColor = Color( "ElementBackgroundColor")
    static let elementTextColor = Color( "ElementTextColor")
    static let navigationItemColor = Color("NavigationItemColor")
    static let text = Color("Text")
    static let textOnBackgroundColor = Color( "TextOnBackgroundColor")
    static let topBarBackgroundColor = Color( "TopBarBackgroundColor")
    static let bottomBarBackgroundColor = Color( "BottomBarBackgroundColor")
//    static let alertTintColor = userChatBubbleColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
}
