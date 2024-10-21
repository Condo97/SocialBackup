//
//  TikTokServerConnector.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/10/24.
//

import Foundation

class TikTokServerConnector: HTTPSClient {
    
    func getImportantConstants() async throws -> GetImportantConstantsResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpoints.getImportantConstants)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let getImportantConstantsResponse = try JSONDecoder().decode(GetImportantConstantsResponse.self, from: data)
            
            return getImportantConstantsResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            // Regenerate AuthToken if necessary
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    func getIsSubscriptionActive(request: AuthRequest) async throws -> SubscriptionIsActiveResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpoints.getIsSubscriptionActive)")!,
            body: request,
            headers: nil)
        
        let subscriptionIsActiveResponse = try JSONDecoder().decode(SubscriptionIsActiveResponse.self, from: data)
        
        return subscriptionIsActiveResponse
    }
    
    func getPostInfo(request: GetPostInfoRequest) async throws -> GetPostInfoResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpoints.getPostInfo)")!,
            body: request,
            headers: nil)
        
        let checkIfChatRequestsImageRevisionResponse = try JSONDecoder().decode(GetPostInfoResponse.self, from: data)
        
        return checkIfChatRequestsImageRevisionResponse
    }
    
    func structuredOutputRequest<T: Codable>(endpoint: String, request: StructuredOutputRequest) async throws -> StructuredOutputResponse<T> {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpoints.structuredOutputBase)\(endpoint)")!,
            body: request,
            headers: nil)
        
        do {
            let soResponse = try JSONDecoder().decode(StructuredOutputResponse<T>.self, from: data)
            
            return soResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            // Regenerate AuthToken if necessary
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    func registerTransaction(request: RegisterTransactionRequest) async throws -> SubscriptionIsActiveResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpoints.registerTransaction)")!,
            body: request,
            headers: nil)
        
        let subscriptionIsActiveResponse = try JSONDecoder().decode(SubscriptionIsActiveResponse.self, from: data)
        
        return subscriptionIsActiveResponse
    }
    
    func registerUser() async throws -> RegisterUserResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpoints.registerUser)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let registerUserResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)
            
            return registerUserResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            // Regenerate AuthToken if necessary
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
}
