//
//  MediaAudioTranscriber.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/18/24.
//

import CoreData
import Foundation
import Speech

class MediaAudioTranscriber: AudioTranscriber {

    // Singleton instance
    static let shared = MediaAudioTranscriber()
    
    private var managedContext: NSManagedObjectContext!
    private var currentTranscription: String = ""
    private var media: Media!
    
    // Queue for transcription requests
    private var requestQueue: [TranscriptionRequest] = []
    private var isProcessing = false

    // Private initializer for singleton
    private init() {
        super.init()
    }
    
    // Struct to hold transcription requests
    struct TranscriptionRequest {
        let media: Media
        let managedContext: NSManagedObjectContext
    }
    
    // Method to add transcription request to the queue
    func addTranscriptionRequest(media: Media, managedContext: NSManagedObjectContext) {
        let request = TranscriptionRequest(media: media, managedContext: managedContext)
        requestQueue.append(request)
        processNextRequestIfNeeded()
    }
    
    // Method to process the next request in the queue
    private func processNextRequestIfNeeded() {
        guard !isProcessing else { return }
        guard !requestQueue.isEmpty else {
            // No more requests to process
            return
        }
        
        // Get the next request
        let nextRequest = requestQueue.removeFirst()
        self.media = nextRequest.media
        self.managedContext = nextRequest.managedContext
        
        isProcessing = true
        
        // Start transcribing
        do {
            try transcribeMediaAndUpdateTranscription()
        } catch {
            // Handle error, then process next request
            print("Error transcribing media: \(error)")
            isProcessing = false
            processNextRequestIfNeeded()
        }
    }
    
    private func transcribeMediaAndUpdateTranscription() throws {
        guard let localFilename = media.localFilename else {
            print("Could not unwrap localFilename in PostPersistenceManager!")
            isProcessing = false
            processNextRequestIfNeeded()
            return
        }
        
        guard let localSubdirectory = media.post?.subdirectory else {
            print("Could not unwrap localSubdirectory in PostPersistenceManager!")
            isProcessing = false
            processNextRequestIfNeeded()
            return
        }
        
        // Reset currentTranscription
        DispatchQueue.main.async {
            self.currentTranscription = ""
        }
        
        // Get localFilepath
        let localFilepath = "\(localSubdirectory)/\(localFilename)"
        
        // Determine media type
        let mediaType = MediaTypeFromExtension.getMediaType(fromFilename: localFilepath)
        
        // Get full documents directory
        let documentsDirectoryFilepath = DocumentSaver.getFullContainerURL(from: localFilepath)
        
        // Handle transcription based on media type
        switch mediaType {
        case .image:
            // Image transcription not implemented
            print("Image transcription not yet implemented")
            // Proceed to the next request
            isProcessing = false
            processNextRequestIfNeeded()
            
        case .video:
            Task {
                do {
                    if let audioURL = try await VideoAudioExtractor.extractAudio(fromVideoAt: documentsDirectoryFilepath) {
                        try transcribeAudio(url: audioURL)
                    } else {
                        // No audio extracted, proceed to next request
                        isProcessing = false
                        processNextRequestIfNeeded()
                    }
                } catch {
                    // Handle error
                    print("Error extracting audio: \(error)")
                    isProcessing = false
                    processNextRequestIfNeeded()
                }
            }
        case .unknown:
            print("Unknown media type")
            // Proceed to next request
            isProcessing = false
            processNextRequestIfNeeded()
        }
    }
    
    override func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        if successfully {
            Task {
                do {
                    try await MediaCDManager.updateMedia(media, transcription: currentTranscription, in: managedContext)
                } catch {
                    // Handle Errors
                    print("Error updating media in MediaAudioTranscriber... \(error)")
                }
                // After updating media, proceed to next request
                isProcessing = false
                processNextRequestIfNeeded()
            }
        } else {
            // Transcription not successful, proceed to next request
            isProcessing = false
            processNextRequestIfNeeded()
        }
    }
    
    override func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        // Append best transcription to currentTranscription
        if !currentTranscription.isEmpty {
            currentTranscription += " "
        }
        currentTranscription += recognitionResult.bestTranscription.formattedString
    }
}

//class MediaAudioTranscriber: AudioTranscriber {
//    
//    var media: Media
//    var managedContext: NSManagedObjectContext
//    
//    private var currentTranscription: String = ""
//    
//    init(media: Media, managedContext: NSManagedObjectContext) {
//        self.media = media
//        self.managedContext = managedContext
//        super.init()
//    }
//    
//    func transcribeMediaAndUpdateTranscription() throws {
//        guard let localFilename = media.localFilename else {
//            print("Could not unwrap localFilename in PostPersistenceManager!")
//            return
//        }
//        
//        guard let localSubdirectory = media.post?.subdirectory else {
//            print("Could not unwrap localSubdirectory in PostPersistenceManager!")
//            return
//        }
//        
//        // Reset currentTranscription
//        DispatchQueue.main.async {
//            self.currentTranscription = ""
//        }
//        
//        // Get localFilepath
//        let localFilepath = "\(localSubdirectory)/\(localFilename)"
//        
//        // Determine if image or video
//        let mediaType = MediaTypeFromExtension.getMediaType(fromFilename: localFilepath)
//        
//        // Get full documents directory
//        let documentsDirectoryFilepath = DocumentSaver.getFullContainerURL(from: localFilepath)
//        
//        // Get transcription
//        switch mediaType {
//        case .image:
//            // TODO: Implement
////            transcription = "Image Transcription Not Yet Implemented"
//            print("Image")
//        case .video:
//            Task {
//                if let audioURL = try await VideoAudioExtractor.extractAudio(fromVideoAt: documentsDirectoryFilepath) {
//                    transcribeAudio(url: audioURL)
//                }
//            }
//        case .unknown:
////            transcription = nil
//            print("Unknown")
//        }
//    }
//    
//    override func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
//        if successfully {
//            Task {
//                do {
//                    try await MediaCDManager.updateMedia(media, transcription: currentTranscription, in: managedContext)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error updating media in MediaAudioTranscriber... \(error)")
//                }
//            }
//        }
//    }
//    
//    override func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
//        // If the currentTranscriptio is empty add a space TODO: Better way to add a space
//        if !currentTranscription.isEmpty {
//            currentTranscription += " "
//        }
//        
//        // Append best transcription to currentTranscription
//        currentTranscription += recognitionResult.bestTranscription.formattedString
//    }
//    
//    
//    
//}
