//
//  WebView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
 
    @Binding var url: URL?
    
    
    private let webView: WKWebView = WKWebView()
 
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.stopLoading()
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(webView: webView, browserURL: $url)
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        @Binding var browserURL: URL?
        
        init(webView: WKWebView, browserURL: Binding<URL?>) {
            self._browserURL = browserURL
            super.init()
            
            webView.navigationDelegate = self
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Did Finish")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("Did Commit")
            self.browserURL = webView.url
        }
        
    }
    
}
