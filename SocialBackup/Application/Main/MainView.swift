//
//  MainView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/13/24.
//

import SwiftUI

struct MainView: View {
    
    enum Tabs {
        case home, postDownloader, collections
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Namespace private var namespace
    
    @State private var selectedTab: Tabs = .postDownloader
    
    var body: some View {
//        NavigationStack {
//            ZStack {
//                Colors.background
//                    .ignoresSafeArea()
//                switch selectedTab {
//                case .home:
//                    FeedContainer()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Colors.background)
//                case .postDownloader:
//                    PostDownloaderView()
//                case .collections:
//                    PostCollectionsView()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Colors.background)
//                }
//            }
//        }
        TabView(selection: $selectedTab) {
            Group {
                SearchView()
                    .tag(Tabs.home)
                
                PostDownloaderView()
                    .tag(Tabs.postDownloader)
                
                PostCollectionsView()
                    .tag(Tabs.collections)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .overlay(alignment: .bottom) {
            ZStack {
                Capsule()
                    .fill(selectedTab == .collections || selectedTab == .home ? Colors.foreground : Colors.background)
                    .frame(height: 50.0)
                    .frame(width: 200.0)
                HStack(spacing: 16.0) {
                    Button(action: {
                        withAnimation {
                            selectedTab = .home
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .tabButtonStyle(
                                isSelected: selectedTab == .home,
                                backSelectedCircleBackgroundColor: Colors.foreground,
                                namespace: _namespace)
                    }
                    
                    Button(action: { withAnimation { selectedTab = .postDownloader } }) {
                        Image(systemName: "square.and.arrow.down")
                            .tabButtonStyle(
                                isSelected: selectedTab == .postDownloader,
                                backSelectedCircleBackgroundColor: Colors.background,
                                namespace: _namespace)
                    }
                    
                    Button(action: { withAnimation { selectedTab = .collections } }) {
                        Image(systemName: "folder")
                            .tabButtonStyle(
                                isSelected: selectedTab == .collections,
                                backSelectedCircleBackgroundColor: Colors.foreground,
                                namespace: _namespace)
                    }
                    
                }
                .padding()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.viewContext.refreshAllObjects()
            }
        }
    }
}

extension View {
    
    public func tabButtonStyle(isSelected: Bool, backSelectedCircleBackgroundColor: Color, namespace: Namespace) -> some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(backSelectedCircleBackgroundColor)
                    .frame(height: 80.0)
                    .padding(.horizontal, -16)
                    .matchedGeometryEffect(id: "backCircle", in: namespace.wrappedValue)
                Circle()
                    .fill(Colors.elementBackgroundColor)
                    .frame(height: 60.0)
                    .padding(.horizontal, -8)
                    .matchedGeometryEffect(id: "frontCircle", in: namespace.wrappedValue)
            }
            self
        }
//        .frame(width: 40.0)
        .frame(width: 50.0)
        .font(.custom(Constants.FontName.body, size: isSelected ? 26.0 : 20.0))
        .foregroundStyle(isSelected ? Colors.elementTextColor : Colors.elementBackgroundColor)
    }
    
}

#Preview {
    
    MainView()
    
}
