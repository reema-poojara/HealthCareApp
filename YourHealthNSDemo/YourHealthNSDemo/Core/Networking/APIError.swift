//
//  APIError.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

enum APIError:LocalizedError {
    case invalidURL
    case invalidResponse
    case httpsError(statusCode:Int)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case networkError(Error)
    case missingResource(String)
    case other(Error)
    
    var errorDescription: String? {
        switch self {
            case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpsError(statusCode: let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .other(let error):
            return "Other error: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "unable to encode request: \(error.localizedDescription)"
        case .missingResource(let resource):
                    return "The requested FHIR resource was not found: \(resource)"
        }
    }
}
