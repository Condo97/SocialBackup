//
//  TranscriptionManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/15/24.
//

import Foundation
import AVFoundation
import Speech
import Combine
import SwiftUI
import CoreData

class AudioTranscriber: NSObject, ObservableObject, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init(locale: Locale = Locale(identifier: "en-US")) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }
    
    func transcribeAudio(url: URL) {
        // Create a speech recognizer associated with the user's default language.
        guard let myRecognizer = speechRecognizer else {
            // The system doesn't support the user's default language.
            return
        }
        
        guard myRecognizer.isAvailable else {
            // The recognizer isn't available.
            return
        }
        
        recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
        recognitionRequest?.requiresOnDeviceRecognition = true
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                self.speechRecognizer?.recognitionTask(with: self.recognitionRequest!, delegate: self)
            }
        }
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        
    }
    
}

//class AudioTranscriber {
//    
//    private let speechRecognizer: SFSpeechRecognizer?
//    private var recognitionRequest: SFSpeechURLRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//
//    init(locale: Locale = Locale(identifier: "en-US")) {
//        speechRecognizer = SFSpeechRecognizer(locale: locale)
//    }
//
//    func requestAuthorization(completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
//        SFSpeechRecognizer.requestAuthorization { status in
////            DispatchQueue.main.async {
//                completion(status)
////            }
//        }
//    }
//    
//    func transcribeAudio(url: URL, completion: @escaping (_ transcription: String?, _ error: Error?) -> Void) {
//        // Create a speech recognizer associated with the user's default language.
//        guard let myRecognizer = speechRecognizer else {
//                // The system doesn't support the user's default language.
//                return
//            }
//            
//            guard myRecognizer.isAvailable else {
//                // The recognizer isn't available.
//                return
//            }
//        
//        print("HERE")
//        var transcription: String = ""
//        recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
////        request.shouldReportPartialResults = false
//        recognitionTask = myRecognizer.recognitionTask(with: recognitionRequest!) { (result, error) in
//                guard let result = result else {
//                    // Recognition failed, so check the error for details and handle it.
//                    print("WAS NULL")
//                    print(transcription)
//                    return
//                }
//            
//            print(error)
//                
//                // Print the speech transcription with the highest confidence that the
//                // system recognized.
//                transcription = result.bestTranscription.formattedString
//                print(result.bestTranscription.formattedString)
//                print(result.isFinal)
//                if result.isFinal {
//                    print(result.bestTranscription.formattedString)
//                }
//            }
////        // Ensure the recognizer is available
////        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
////            let error = NSError(domain: "SpeechRecognizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])
////            completion(nil, error)
////            return
////        }
////
////        // Create a recognition request with the audio file URL
////        recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
////
////        guard let recognitionRequest = recognitionRequest else {
////            let error = NSError(domain: "SpeechRecognizer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
////            completion(nil, error)
////            return
////        }
////        
////        // Accumulate the transcription results
////        var fullTranscription = ""
////        
////        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
////            if let result = result {
////                // Append the latest transcription to the full transcription
////                fullTranscription = result.bestTranscription.formattedString
////            }
////            
////            // Check if the task has completed
////            if error != nil || result == nil {
////                // Call the completion handler with the full transcription
////                completion(fullTranscription, error)
////                self.recognitionTask = nil
////            }
////        }
//        
////        // Start the recognition task
////        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
////            if let error = error {
////                completion(nil, error)
////                self.recognitionTask = nil
////            } else if let result = result, result.isFinal {
////                completion(result.bestTranscription.formattedString, nil)
////                self.recognitionTask = nil
////            }
////        }
//    }
//
//    func cancelTranscription() {
//        recognitionTask?.cancel()
//        recognitionTask = nil
//    }
//    
//}
