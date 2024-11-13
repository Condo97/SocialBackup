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
        
        static let appGroupName = "group.socialbackup"
        static let coreDataModelName = "SocialBackup"
        static let defaultShareURL = URL(string: "https://apple.com")! // TODO: Add default share URL
        static let fallbackAnnualProductID = "grab_ultrayearly" // TODO: Add fallback annual product ID
        static let fallbackMonthlyProductID = "grab_ultramonthly" // TODO: Add fallback monthly product ID
        static let fallbackSharedSecret = "306809cadd314fb38d46ac1b69ffcd6d" // TODO: Add shared secret
        static let fallbackWeeklyProductID = "grab_ultraweekly" // TODO: Add fallback weekly product ID
        
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
            
            struct Endpoints {
                
                struct StructuredOutput {
                    
                    static let videoSummary = "/videoSummary"
                    
                }
                
                static let getImportantConstants = "/getImportantConstants"
                static let getPostInfo = "/getVideoInfo"
                static let getIsSubscriptionActive = "/getIsSubscriptionActive"
                static let registerTransaction = "/registerTransaction"
                static let registerUser = "/registerUser"
                static let structuredOutputBase = "/so"
                
            }
            
            
            static let baseURL = "https://chitchatserver.com:9100/v1"
            
        }
        
        static let termsAndConditions = "https://writesmithapp.weebly.com/terms-and-conditions-eula1.html" // TODO: Add terms and conditions URL
        static let privacyPolicy = "https://writesmithapp.weebly.com/privacy-policy1.html" // TODO: Add privacy policy URL
        
    }
    
    struct UserDefaults {
        
        static let annualDisplayPrice = "annualDisplayPrice"
        static let annualProductID = "annualProductID"
        static let hapticsDisabled = "hapticsDisabled"
        static let monthlyDisplayPrice = "monthlyDisplayPrice"
        static let monthlyProductID = "monthlyProductID"
        static let sharedSecret = "sharedSecret"
        static let shareURL = "shareURL"
        static let storedIsPremium = "storedIsPremium"
        static let weeklyDisplayPrice = "weeklyDisplayPrice"
        static let weeklyProductID = "weeklyProductID"
        
    }
    
}

struct Colors {
    static let accent = Color("Accent")
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

struct Images {
    
    struct SocialIcons {
        static let tiktok = "TikTok"
        static let instagram = "Instagram"
        static let x = "X"
        static let youTube = "YouTube"
    }
    
    static let logoText = "LogoText"
    
}
