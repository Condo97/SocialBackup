//
//  CodableDataAdapter.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import Foundation

class CodableDataAdapter {
    
    /// Encodes a `Codable` object to `Data`.
    ///
    /// - Parameter value: The `Codable` object to encode.
    /// - Returns: The encoded `Data`.
    /// - Throws: An error if any value throws an error during encoding.
    static func encode<T: Codable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(value)
    }
    
    /// Decodes `Data` to a `Codable` object.
    ///
    /// - Parameters:
    ///   - type: The type of the `Codable` object to decode.
    ///   - data: The `Data` to decode.
    /// - Returns: The decoded `Codable` object.
    /// - Throws: An error if any value throws an error during decoding.
    static func decode<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
}
