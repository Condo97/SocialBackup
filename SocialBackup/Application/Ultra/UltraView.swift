//
//  UltraView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import CoreData
import StoreKit
import SwiftUI

struct UltraView: View {
    
    @Binding var restoreOnAppear: Bool
    @Binding var isShowing: Bool
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private enum ShowingPromoRow {
        case gptVision
        case gptIntelligence
        case assistants
        case unlimitedMessages
        case removeAds
    }
    
    private enum ValidSubscriptions {
        // The subscription id represented as an enum
        case weekly
        case monthly
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedSubscription: ValidSubscriptions = .weekly
    
    @State private var isSmallSize: Bool = false
    
    @State private var isCloseButtonEnlarged: Bool = false
    
    @State private var alertShowingDEBUGErrorPurchasing: Bool = false
    @State private var alertShowingErrorRestoringPurchases: Bool = false
    @State private var alertShowingErrorLoading: Bool = false
    
    @State private var isShowingTermsWebView: Bool = false
    @State private var isShowingPrivacyWebView: Bool = false
    
    @State private var isLoadingPurchase: Bool = false
    
    @State private var errorPurchasing: Error?
    
    @State private var showingPromoRows: [ShowingPromoRow] = initialShowingPromoRows
    
    private let smallSizeMaxHeight: CGFloat = 680.0
    
    private let closeButtonEnlargeDelay = 1.5
    
    private static let initialShowingPromoRows: [ShowingPromoRow] = [.gptVision, .assistants]
    private let initialShowingPromoRows = initialShowingPromoRows
    
    private let maxShowingPromoRows = 2
    
    private let currencyNumberFormatter: NumberFormatter = {
        let currencyNumberFormatter = NumberFormatter()
        currencyNumberFormatter.numberStyle = .decimal
        currencyNumberFormatter.maximumFractionDigits = 2
        currencyNumberFormatter.minimumFractionDigits = 2
        return currencyNumberFormatter
    }()
    
    private var freeTrialSelected: Binding<Bool> {
        Binding(
            get: {
                selectedSubscription == .weekly
            }, set: { newValue in
                if newValue {
                    selectedSubscription = .weekly
                } else {
                    selectedSubscription = .monthly
                }
            })
    }
    
    
    init(restoreOnAppear: Binding<Bool> = .constant(false), isShowing: Binding<Bool>) {
        self._restoreOnAppear = restoreOnAppear
        self._isShowing = isShowing
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        isSmallSize = geometry.size.height < smallSizeMaxHeight
                        
                        if isSmallSize {
                           // Set showingPromoRows to empty
                           showingPromoRows = []
                        } else {
                            // Set showingPromoRows to initialShowingPromoRows
                            showingPromoRows = initialShowingPromoRows
                        }
                    }
            }
            
            Color.clear
                .overlay(alignment: .bottom) {
                    VStack {
                        topImagesAndPromoText
                            .padding(.top, 26)
                            .padding(.bottom, 4)
                        
                        ScrollView {
                            featuresList
                                .frame(maxWidth: 380)
                                .padding([.leading, .trailing])
                                .padding(.bottom, 8)
                        }
                        
                        Spacer()
                        
                        purchaseButtons
                            .padding([.leading, .trailing])
                        
                        iapRequiredButtons
                            .padding([.leading, .trailing])
                        
                    }
            }
            
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        closeButton
                            .padding(.top, -24.0)
                    }
                    
                    Spacer()
                }
            }
        }
        .background(Colors.background)
        .alert("Error restoring purchases...", isPresented: $alertShowingErrorRestoringPurchases, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("You can try tapping on the subsciption you previously purchased. Apple will prevent a double charge.")
        }
        .alert("DEBUG Error Purchasing", isPresented: $alertShowingDEBUGErrorPurchasing, actions: {
            Button("Close", role: .cancel) {
                
            }
            
            Button("Copy Error") {
                PasteboardHelper.copy(errorPurchasing?.localizedDescription ?? "No Error")
            }
        }) {
            Text(errorPurchasing?.localizedDescription ?? "No Error")
        }
        .onAppear {
//            faceAnimationUpdater.faceAnimationViewRepresentable = faceAnimationViewRepresentable
//            
//            faceAnimationUpdater.setFaceIdleAnimationToSmile()
        }
        .onAppear {
            // Start restore logic if restoreOnAppear is true, and set restoreOnAppear to false once started
            if restoreOnAppear {
                restore()
                
                restoreOnAppear = false
            }
            
            // Start close button enlarge timer
            Timer.scheduledTimer(withTimeInterval: closeButtonEnlargeDelay, repeats: false, block: { timer in
                withAnimation {
                    isCloseButtonEnlarged = true
                }
            })
        }
        .fullScreenCover(isPresented: $isShowingTermsWebView) {
            NavigationStack {
                VStack {
                    WebView(url: .constant(URL(string: "\(Constants.Networking.termsAndConditions)")!))
                        .toolbar {
                            CloseToolbarItem(isPresented: $isShowingTermsWebView)
                        }
                        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.inline)
                        .background(Colors.background)
                        .ignoresSafeArea()
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingPrivacyWebView) {
            NavigationStack {
                VStack {
                    WebView(url: .constant(URL(string: "\(Constants.Networking.privacyPolicy)")!))
                        .toolbar {
                            CloseToolbarItem(isPresented: $isShowingPrivacyWebView)
                        }
                        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.inline)
                        .background(Colors.background)
                        .ignoresSafeArea()
                }
            }
        }
        .onChange(of: showingPromoRows) { newValue in
            // If showingPromoRows contains more than maxShowing remove the first element with animation
            while showingPromoRows.count > maxShowingPromoRows {
                withAnimation {
                    showingPromoRows.removeFirst()
                }
            }
        }
    }
    
    var topImagesAndPromoText: some View {
        HStack(spacing: 8.0) {
            let faceAnimationViewContainerInset = 20.0
            
            ZStack {
                
            }
            .padding(-8)
            .padding([.top, .bottom], -2)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Image(Images.logoText)
//                    .font(.custom(Constants.FontName.black, size: 28.0))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Colors.accent)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .onLongPressGesture {
                        // Show debug error on long press if there is an error stored from when purchasing
                        if errorPurchasing != nil {
                            alertShowingDEBUGErrorPurchasing = true
                        }
                    }
                
//                Text("Join now. Learn anything.")
//                    .font(.custom(Constants.FontName.light, size: 17.0))
//                    .minimumScaleFactor(0.5)
//                    .lineLimit(2)
            }
            .foregroundStyle(colorScheme == .dark ? Colors.elementBackgroundColor : Colors.text)
            .frame(height: 60.0)
            .padding(.leading, -8)
            .padding(.trailing, 8)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28.0)
                .fill(Colors.foreground)
        )
        .padding([.leading, .trailing])
//        VStack(spacing: 0.0) {
//            Image(colorScheme == .dark ? Constants.ImageName.Ultra.ultraDark : Constants.ImageName.Ultra.ultraLight)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .opacity(colorScheme == .dark ? 0.8 : 1.0)
////                .frame(maxWidth: horizontalSizeClass == .regular ? 200.0 : .infinity)
//
//            Text("Unlimited Messages, Image Chats & More!")
//                .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
//                .foregroundStyle(Colors.elementBackgroundColor)
//                .padding(.top, -28)
//        }
    }
    
    var featuresList: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            // GPT-4 + Vision + Web
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if let rowIndex = showingPromoRows.firstIndex(of: .gptVision) {
                        showingPromoRows.remove(at: rowIndex)
                    } else {
                        showingPromoRows.append(.gptVision)
                    }
                }
            }) {
                HStack(alignment: showingPromoRows.contains(.gptVision) ? .top : .center) {
                    Text(Image(systemName: "eye.fill"))
                        .font(.custom(Constants.FontName.body, size: 20.0))
                    
                    VStack(alignment: .leading) {
                        Text("AI Search")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                        +
                        Text(" *NEW!*")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        
                        if showingPromoRows.contains(.gptVision) {
                            Text("Search ")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRows.contains(.gptVision) ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 14.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRows.contains(.gptVision) ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding(.leading, -2)
            .padding(4)
//            .background(
//                RoundedRectangle(cornerRadius: 14.0)
//                    .stroke(Colors.elementBackgroundColor, lineWidth: 1.0)
//                    .opacity(0.4)
//            )
            
            // Create Art
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if let rowIndex = showingPromoRows.firstIndex(of: .assistants) {
                        showingPromoRows.remove(at: rowIndex)
                    } else {
                        showingPromoRows.append(.assistants)
                    }
                }
            }) {
                HStack(alignment: showingPromoRows.contains(.assistants) ? .top : .center) {
                    if #available(iOS 17.0, *) {
                        Text(Image(systemName: "brain.fill"))
                            .font(.custom(Constants.FontName.body, size: 20.0))
                    } else {
                        Text(Image(systemName: "brain"))
                            .font(.custom(Constants.FontName.body, size: 20.0))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Add")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        +
                        Text(" Websites, PDFs & More")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                        
                        if showingPromoRows.contains(.assistants) {
                            Text("Chat about a source to learn your way. Ask questions about a lecture. Solve difficult problems. Write better essays.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRows.contains(.assistants) ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRows.contains(.assistants) ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding(.leading, -2)
            .padding(4)
            
            // Unlimited Messages
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if let rowIndex = showingPromoRows.firstIndex(of: .unlimitedMessages) {
                        showingPromoRows.remove(at: rowIndex)
                    } else {
                        showingPromoRows.append(.unlimitedMessages)
                    }
                }
            }) {
                HStack(alignment: showingPromoRows.contains(.unlimitedMessages) ? .top : .center) {
                    ZStack {
                        Text(Image(systemName: "bubble.left.fill"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                        Text(Image(systemName: "infinity"))
                            .font(.custom(Constants.FontName.medium, size: 12.0))
                            .foregroundStyle(Colors.background)
                            .padding(.top, -4.4)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Unlimited")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                        +
                        Text(" Chats")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        
                        if showingPromoRows.contains(.unlimitedMessages) {
                            Text("Limitless chats, images, websites, PDFs, voice, videos & more. Ask follow up questions. Dive deep into any subject.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRows.contains(.unlimitedMessages) ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRows.contains(.unlimitedMessages) ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding(.leading, -4)
            .padding(4)
            
            // Unlock GPT-4 Intelligence
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if let rowIndex = showingPromoRows.firstIndex(of: .gptIntelligence) {
                        showingPromoRows.remove(at: rowIndex)
                    } else {
                        showingPromoRows.append(.gptIntelligence)
                    }
                }
            }) {
                HStack(alignment: showingPromoRows.contains(.gptIntelligence) ? .top : .center) {
                    Text(Image(systemName: "calendar"))
                        .font(.custom(Constants.FontName.body, size: 24.0))
                    
                    VStack(alignment: .leading) {
                        Text("2024")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                        +
                        Text(" AI Intelligence + Web")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        
                        if showingPromoRows.contains(.gptIntelligence) {
                            Text("Trained on books, research, websites and more. Updated for 2024.\n**NEW!** Ask to search the internet, for even fresher sources.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRows.contains(.gptIntelligence) ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRows.contains(.gptIntelligence) ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding([.top, .bottom], -2)
            .padding(.leading, -2)
            .padding(4)
            
            // Remove Ads
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if let rowIndex = showingPromoRows.firstIndex(of: .removeAds) {
                        showingPromoRows.remove(at: rowIndex)
                    } else {
                        showingPromoRows.append(.removeAds)
                    }
                }
            }) {
                HStack(alignment: showingPromoRows.contains(.removeAds) ? .top : .center) {
                    ZStack {
                        Text(Image(systemName: "circle.slash.fill"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                        Text("ADs")
                            .font(.custom(Constants.FontName.black, size: 10.0))
                            .padding(.top, -2)
                            .foregroundStyle(Colors.background)
                        Text(Image(systemName: "circle.slash"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Remove")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                        +
                        Text(" Ads")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        
                        if showingPromoRows.contains(.removeAds) {
                            Text("Nothing to clutter your experience.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRows.contains(.removeAds) ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRows.contains(.removeAds) ? 8 : 0)
                        .padding(.trailing, 8)
                    
                }
            }
            .padding(4)
        }
        .foregroundStyle(Colors.text)
        .multilineTextAlignment(.leading)
    }
    
    var purchaseButtons: some View {
        VStack(spacing: 8.0) {
//            if let weeklyProduct = productUpdater.weeklyProduct {
//                if let introductaryOffer = weeklyProduct.subscription?.introductoryOffer {
//                    ZStack {
//                        HStack {
//                            Toggle(isOn: freeTrialSelected) {
//                                        let introductaryText = introductaryOffer.price == 0.0 ? "Enable Free Trial" : "Enable Special Offer"
//                                        
//                                        Text(introductaryText)
//                                    .font(.custom(Constants.FontName.medium, size: 17.0))
//                                    
//                            }
//                            .onTapGesture {
//                                HapticHelper.doMediumHaptic()
//                            }
//                            .tint(Colors.elementBackgroundColor)
//                            .foregroundStyle(Colors.elementBackgroundColor)
//                        }
//                    }
//                    .padding(8)
//                    .padding([.leading, .trailing], 8)
//                    .background(
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 14.0)
//                                .fill(Colors.userChatTextColor)
//                        }
//                    )
//                }
//            }
            
            Text("Directly Supports the Developer - Cancel Anytime")
                .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                .padding(.bottom, -6)
                .opacity(0.6)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set selected subscription to weekly
                selectedSubscription = .weekly
            }) {
                ZStack {
                    if let weeklyProduct = productUpdater.weeklyProduct {
                        let productPriceString = currencyNumberFormatter.string(from: weeklyProduct.price as NSNumber) ?? weeklyProduct.displayPrice
                        
                        HStack {
                            if let introductaryOffer = weeklyProduct.subscription?.introductoryOffer {
                                let offerPriceString = introductaryOffer.price == 0.99 ? "99¢" : currencyNumberFormatter.string(from: introductaryOffer.price as NSNumber) ?? introductaryOffer.displayPrice
                                
                                if introductaryOffer.paymentMode == .freeTrial || introductaryOffer.price == 0.0 {
                                    // Free Trial
                                    let durationString = "\(introductaryOffer.period.value)"
                                    let unitString = switch introductaryOffer.period.unit {
                                    case .day: "Day"
                                    case .week: "Week"
                                    case .month: "Month"
                                    case .year: "Year"
                                    @unknown default: ""
                                    }
                                    
                                    Text("\(durationString) \(unitString)s Free")
                                        .font(.custom(Constants.FontName.black, size: 17.0))
                                    +
                                    Text(" - then \(productPriceString) / week")
                                        .font(.custom(Constants.FontName.body, size: 15.0))
                                } else {
                                    // Discount
                                    VStack(alignment: .leading, spacing: 0.0) {
                                        Text("Special Offer - \(offerPriceString) / week")
                                            .font(.custom(Constants.FontName.black, size: 17.0))
                                        let durationString = introductaryOffer.periodCount.word
                                        
                                        Text("for \(durationString) weeks, then \(productPriceString) / week")
                                            .font(.custom(Constants.FontName.bodyOblique, size: 16.0))
                                            .minimumScaleFactor(0.69)
                                            .lineLimit(1)
                                    }
                                }
                                
                            } else {
                                Text("\(productPriceString) / week")
                                    .font(.custom(Constants.FontName.black, size: 17.0))
                            }
                            
                            
                            
                            Spacer()
                            
                            Text(Image(systemName: selectedSubscription == .weekly ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 28.0))
                                .foregroundStyle(Colors.accent)
                                .padding([.top, .bottom], -6)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Blank")
                                .opacity(0.0)
                            Spacer()
                        }
                    }
                    
                    if isLoadingPurchase && selectedSubscription == .weekly {
                        HStack {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.text)
            .background(
                ZStack {
                    let cornerRadius = 14.0
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.foreground)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Colors.accent, lineWidth: selectedSubscription == .weekly ? 0.0 : 0.0)
                }
            )
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set selected subscription to monthly
                selectedSubscription = .monthly
            }) {
                ZStack {
                    if let monthlyProduct = productUpdater.monthlyProduct {
                        let productPriceString = currencyNumberFormatter.string(from: monthlyProduct.price as NSNumber) ?? monthlyProduct.displayPrice
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 0.0) {
                                Text("Monthly - \(productPriceString) / month")
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                                Text("That's 30% Off Weekly!")
                                    .font(.custom(Constants.FontName.black, size: 12.0))
                            }
                            
                            Spacer()
                            
                            Text(Image(systemName: selectedSubscription == .monthly ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 28.0))
                                .foregroundStyle(Colors.accent)
                                .padding([.top, .bottom], -6)
                        }
                        
                        if isLoadingPurchase && selectedSubscription == .monthly {
                            HStack {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.text)
            .background(
                ZStack {
                    let cornerRadius = 14.0
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.foreground)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Colors.accent, lineWidth: selectedSubscription == .monthly ? 0.0 : 0.0)
                }
            )
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
            
            Button(action: {
                // Do medium haptic
                HapticHelper.doMediumHaptic()
                
                // Purchase
                purchase()
                
//                // Print to server console
//                Task {
//                    guard let authToken = AuthHelper.get() else {
//                        print("Could not unwrap authToken in UltraView!")
//                        return
//                    }
//                    
//                    let printToConsoleRequst = PrintToConsoleRequest(
//                        authToken: authToken,
//                        message: "Tapped purchase button!")
//                    
//                    do {
//                        try await ChitChatHTTPSConnector.printToConsole(request: printToConsoleRequst)
//                    } catch {
//                        print("Error sending print to console request in UltraView... \(error)")
//                    }
//                }
            }) {
                ZStack {
                    Text("Next")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                    
                    HStack {
                        Spacer()
                        
                        Text(Image(systemName: "chevron.right"))
                    }
                }
            }
            .padding(18)
            .foregroundStyle(Colors.text)
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
        }
    }
    
    var iapRequiredButtons: some View {
        HStack {
            // Privacy button
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show privacy web view
                isShowingPrivacyWebView = true
            }) {
                Text("Privacy")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
            
            // Terms button
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show terms web view
                isShowingTermsWebView = true
            }) {
                Text("Terms")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
            
            Spacer()
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Restore TODO: Restore - Needs more testing
                restore()
            }) {
                Text("Restore")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
        }
        .foregroundStyle(Colors.textOnBackgroundColor)
        .opacity(0.8)
    }
    
    var closeButton: some View {
        Button(action: {
            DispatchQueue.main.async {
                isShowing = false
            }
        }) {
            Text(Image(systemName: "xmark"))
                .font(isCloseButtonEnlarged ? .custom(Constants.FontName.heavy, size: 20.0) : .custom(Constants.FontName.body, size: 17.0))
        }
        .foregroundStyle(Colors.textOnBackgroundColor)
        .opacity(isCloseButtonEnlarged ? 0.6 : 0.1)
        .padding()
    }
    
    func restore() {
        Task {
            do {
                // Do restore TODO: Needs more testing
                try await restore()
                
                // Do success haptic
                HapticHelper.doSuccessHaptic()
            } catch {
                // TODO: Handle errors
                print("Error restoring purchases in UltraView... \(error)")
                
                // Do warning haptic
                HapticHelper.doWarningHaptic()
                
                // Show error restoring purchases alert
                alertShowingErrorRestoringPurchases = true
            }
        }
    }
    
    func purchase() {
//        // Unwrap tappedPeriod
//        guard let selectedSubscription = selectedSubscription else {
//            // TODO: Handle errors
//            print("Could not unwrap tappedPeriod in purchase in UltraView!")
//            return
//        }
        // Get product to purchase
        let product = switch selectedSubscription {
        case .weekly:
            productUpdater.weeklyProduct
        case .monthly:
            productUpdater.monthlyProduct
        }
        
        // Unwrap product
        guard let product = product else {
            // TODO: Handle errors
            print("Could not unwrap product in purchase in UltraView!")
            
            return
        }
        
        // Set isLoadingPurchase to true
        isLoadingPurchase = true
        
        Task {
            defer {
                isLoadingPurchase = false
            }
            
            // Unwrap authToken
            guard let authToken = try? await AuthHelper.ensure() else {
                // If the authToken is nil, show an error alert that the app can't connect to the server and return
                alertShowingErrorLoading = true
                return
            }
            
            // Purchase
            let transaction: StoreKit.Transaction
            do {
                transaction = try await IAPManager.purchase(product)
            } catch {
                // TODO: Handle errors
                print("Error purchasing product in UltraView... \(error)")
                errorPurchasing = error
                return
            }
            
            // Refresh receipt and try to get it if it's made available.. the delegate wasn't working but the refresh receipt seemed to make the receipt immidiately available here so maybe!
            IAPManager.refreshReceipt()
            
            // TODO: Tenjin stuff
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                // Get the receipt if it's available.
//                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
//                   FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//                    
//                    
//                    do {
//                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                        print(receiptData)
//                        
//                        
////                        let receiptString = receiptData.base64EncodedString(options: [])
//                        
//                    } catch {
//                        print("Couldn't read receipt data with error: " + error.localizedDescription)
//                    }
//                } else {
//                    
//                }
//            }
            
            if #available(iOS 16.1, *) {
                Task {
                    do {
                        try await SKAdNetwork.updatePostbackConversionValue(3, coarseValue: .low)
                    } catch {
                        print("Error updating postback conversion value in UltraView... \(error)")
                    }
                }
            } else {
                Task {
                    do {
                        try await SKAdNetwork.updatePostbackConversionValue(1)
                    } catch {
                        print("Error updating psotback conversion value in UltraVIew... \(error)")
                    }
                }
            }
            
            // Register the transaction ID with the server
            try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.originalID)

            
            // If premium on complete, do success haptic and dismiss
            if premiumUpdater.isPremium {
                // Do success haptic
                HapticHelper.doSuccessHaptic()
                
                // Dismiss
                DispatchQueue.main.async {
                    isShowing = false
                }
            }
        }
    }
    
    func restore() async throws {
        defer {
            DispatchQueue.main.async {
                isLoadingPurchase = false
            }
        }
        
        await MainActor.run {
            isLoadingPurchase = true
        }
        
        try await AppStore.sync()
    }
    
    
}

extension View {
    
    func ultraViewPopover(isPresented: Binding<Bool>, restoreOnAppear: Binding<Bool> = .constant(false)) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                UltraView(
                    restoreOnAppear: restoreOnAppear,
                    isShowing: isPresented)
            }
    }
    
}

#Preview {
    
    VStack {
        
    }
    .fullScreenCover(isPresented: .constant(true)) {
        UltraView(isShowing: .constant(true))
    }
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    
}
