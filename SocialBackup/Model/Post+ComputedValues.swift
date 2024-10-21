//
//  Post+ComputedValues.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/14/24.
//

import Foundation

extension Post {
    
    var generatedFieldIsNil: Bool {
        generatedTitle == nil || generatedTopic == nil || generatedShortSummary == nil || generatedMediumSummary == nil || generatedEmotionsCSV == nil || generatedTagsCSV == nil || generatedKeyEntitiesCSV == nil || generatedKeyEntitiesCSV == nil
    }
    
    func getGetPostInfoResponseObject() throws -> GetPostInfoResponse? {
        guard let getPostInfoResponseData = self.getPostInfoResponse else {
            // TODO: Handle Errors
            print("Could not get unwrap getPostInfoResponse data in PostStatsContainer!")
            return nil
        }
        
        return try CodableDataAdapter.decode(GetPostInfoResponse.self, from: getPostInfoResponseData)
    }
    
}
