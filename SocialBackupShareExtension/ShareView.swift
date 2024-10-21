//
//  ShareView.swift
//  SocialBackupShareExtension
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import CoreData
import GradientLoadingBar
import SwiftUI

struct ShareView: View {
    
    var onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var mediaICloudUploadUpdater = MediaICloudUploadUpdater()
    @StateObject private var queuedTikTokDownloader = QueuedTikTokDownloader()
    
    @State private var isAnimatingShowCheckmark: Bool = false
    
    @State private var originalQueueCount: Int = 0
    
    @State private var hasProcessed: Bool = false
    
    var body: some View {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                ZStack {
                    Colors.background
                    VStack {
                        Text(queuedTikTokDownloader.isProcessing ? ("Grabbing Post\(originalQueueCount == 1 ? "" : "s")...") : "Post\(originalQueueCount == 1 ? "" : "s") Grabbed")
                            .font(.custom(Constants.FontName.heavy, size: 27.0))
                            .foregroundStyle(Colors.text)
                        
                        if isAnimatingShowCheckmark {
                            Image(systemName: "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.heavy)
                                .foregroundStyle(.yellow)
                                .frame(width: 28.0)
                        } else {
                            ProgressView()
                                .tint(.yellow)
                                .padding(.bottom)
                            
                            Button(action: onDismiss) {
                                Text("Background")
                                    .frame(maxWidth: .infinity)
                                    .overlay(alignment: .trailing) {
                                        Image(systemName: "chevron.down")
                                    }
                                    .appButtonStyle()
                            }
                            
                            Text("Grab will be finished when you open the app.")
                                .font(.custom(Constants.FontName.heavyOblique, size: 10.0))
                                .foregroundStyle(Colors.text)
                                .opacity(0.6)
                        }
                    }
                    .padding()
                }
                .presentationDetents([.height(200.0)])
                .background(Colors.background)
//                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .onAppear {
                    originalQueueCount = QueuedTikTokDownloader.queue.count
                }
                .task { // Begin processing queue
                    // Ensure authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken in ShareViewController... \(error)")
                        return
                    }
                    
                    queuedTikTokDownloader.startProcessingQueue(
                        authToken: authToken,
                        mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                        managedContext: viewContext)
                }
                .onReceive(queuedTikTokDownloader.$isProcessing) { newValue in
                    if newValue {
                        hasProcessed = true
                    } else if hasProcessed {
                        // If post download has processed and is now not processing show checkmark and dismiss
                        withAnimation {
                            isAnimatingShowCheckmark = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onDismiss()
                        }
                    }
                }
            }
        
//        ScrollView {
//            VStack {
//                Spacer()
//                
//                Text(queuedTikTokDownloader.isProcessing ? ("Grabbing Post\(QueuedTikTokDownloader.queue.count == 1 ? "" : "s")...") : "Grabbed Posts")
//                    .font(.custom(Constants.FontName.heavy, size: 27.0))
//                    .foregroundStyle(Colors.text)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                
//                if queuedTikTokDownloader.isProcessing {
//                    if isAnimatingIsLoadingDownloadPostResult {
//                        GradientLoadingBarView(gradientColors: [.purple, .yellow], progressDuration: 1.0)
//                            .frame(height: 5.0)
//                            .transition(.move(edge: .top))
//                    }
//                }
//                
//                QueuedPostDownloaderView(queuedTikTokDownloader: queuedTikTokDownloader)
//                    .background(Colors.background)
//            }
//        }
//        .background(Colors.background)
//        .onReceive(queuedTikTokDownloader.$isProcessing) { newValue in
//            withAnimation {
//                isAnimatingIsLoadingDownloadPostResult = newValue
//            }
//        }
    }
    
}

#Preview {
    
    ShareView(onDismiss: {
        
    })
    .background(.blue)
    
}
