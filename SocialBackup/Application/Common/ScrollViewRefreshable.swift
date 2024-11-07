//
//  ScrollViewRefreshable.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/25/24.
//

import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat {
        return 0
    }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct MovingOffsetView: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
        }
        .frame(height: 0)
    }
}

struct ScrollViewRefreshableModifier: ViewModifier {
    let action: () async -> Void
    @State private var isRefreshing = false
    @State private var offsetY: CGFloat = 0
    private let threshold: CGFloat = 80

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            MovingOffsetView()
            VStack(spacing: 0) {
                if isRefreshing {
                    ProgressView()
                        .frame(height: threshold)
                } else if offsetY > threshold / 2 {
                    Text("Pull down to refresh")
                        .frame(height: threshold)
                }
                content
            }
            .offset(y: isRefreshing ? 0 : -threshold)
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            if !isRefreshing {
                let pullDistance = value
                offsetY = pullDistance
                if pullDistance > threshold {
                    isRefreshing = true
                    Task {
                        await action()
                        withAnimation {
                            isRefreshing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func scrollViewRefreshable(action: @escaping () async -> Void) -> some View {
        self.modifier(ScrollViewRefreshableModifier(action: action))
    }
}
