//
//  ClearFullScreenCover+View.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/16/23.
//
// https://stackoverflow.com/questions/64301041/swiftui-translucent-background-for-fullscreencover

import Foundation
import SwiftUI

struct ClearFullScreenCoverView: UIViewRepresentable {
    
//    private let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var style: UIBlurEffect.Style?
    var backgroundVisibleOpacity: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style ?? (colorScheme == .dark ? .dark : .light)))//UIView()
//        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurBackground.frame = view.bounds
        view.alpha = 0.0
        
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
            
            UIView.animate(withDuration: 0.4, delay: 0.1, animations: {
                view.alpha = backgroundVisibleOpacity // TODO: Make the background opacity transition smooth when showing and hiding
            })
        }
        
//        view.addSubview(blurBackground)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension View {
    
    func clearFullScreenCover<Content: View>(isPresented: Binding<Bool>, style: UIBlurEffect.Style? = nil, backgroundVisibleOpacity: CGFloat = 1.0, backgroundTapDismisses: Bool = true, onDismiss: (()->Void)? = nil, @ViewBuilder content: @escaping ()->Content) -> some View {
        self
            .fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: {
                ZStack {
                    Color.clear
                    
                    content()
                        .transition(.opacity)
                }
                .background(ClearFullScreenCoverView(style: style, backgroundVisibleOpacity: backgroundVisibleOpacity) // TODO: Make the background opacity transition smooth when showing and hiding
                    .ignoresSafeArea()
                    .onTapGesture {
                        if backgroundTapDismisses {
                            DispatchQueue.main.async {
                                isPresented.wrappedValue = false
                            }
                        }
                    })
            })
    }
    
}

