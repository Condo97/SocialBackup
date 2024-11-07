//
//  PostDownloadMiniContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostDownloadMiniContainer: View {
    
//    @Binding var recentlyDownloadedPost: Post?
    @Binding var isLoading: Bool
//    var onDownload: (Post?) -> Void
    var onSubmit: (_ urlString: String) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var postICloudUploadUpdater: MediaICloudUploadUpdater
    
//    @State private var isLoading: Bool = false
    
    @State private var text: String = ""//"https://www.tiktok.com/@streetcraft/video/7422012800328797470"//""
    
    @State private var inputIsValid: Bool = false
    
    var body: some View {
        PostDownloadMiniView(
            text: $text,
            isLoading: $isLoading,
            inputIsValid: inputIsValid,
            onSubmit: { onSubmit(text) })
            .onChange(of: text) { newValue in
                // Reset inputIsValid to false
                inputIsValid = false
                
                // Validate input
                validateInput()
            }
    }
    
    func validateInput() {
        // Trim whitespace and newlines
        var textToValidate = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If the text does not start with http:// or https:// (case-insensitive), prepend http://
        if !(textToValidate.lowercased().hasPrefix("http://") || textToValidate.lowercased().hasPrefix("https://")) {
            textToValidate = "http://" + textToValidate
        }
        
        // Attempt to create a URL from textToValidate
        if let url = URL(string: textToValidate),
           url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https",
           url.host != nil {
            // URL is valid
            inputIsValid = true
        } else {
            // URL is invalid
            inputIsValid = false
        }
    }
    
//    func downloadAndSavePost() {
//        Task {
//            defer { DispatchQueue.main.async { withAnimation { isLoading = false } } }
//            await MainActor.run { withAnimation { isLoading = true } }
//            
//            let authToken: String
//            do { authToken = try await AuthHelper.ensure() } catch { print("Error ensuring AuthToken in PostDownloadMiniContainer... \(error)"); return } // TODO: Handle Errors
//            
//            // Download and save
//            do {
//                let downloadedPost = try await tikTokDownloader.downloadAndSave(
//                    fromURLString: text,
//                    authToken: authToken,
//                    mediaICloudUploadUpdater: postICloudUploadUpdater,
//                    in: viewContext)
//                onDownload(downloadedPost)
////                withAnimation(.easeOut) {
////                    recentlyDownloadedPost = downloadedPost
////                }
//            } catch {
//                // TODO: Handle Errors
//                print("Error downloading and saving post in PostDownloadMiniContainer... \(error)")
//                return
//            }
//        }
//    }
    
}

//#Preview {
//    
//    PostDownloadMiniContainer()
//
//}
