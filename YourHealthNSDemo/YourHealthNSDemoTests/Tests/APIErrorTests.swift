//
//  APIErrorTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-31.
//

import XCTest
@testable import YourHealthNSDemo

final class APIErrorTests: XCTestCase {

    func testInvalidURLErrorDescription() {
        let error = APIError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }
    
    func testInvalidResponseErrorDescription() {
        let error = APIError.invalidResponse
        XCTAssertEqual(error.errorDescription, "Invalid response")
    }
    func testHTTPErrorErrorDescription() {
        let error = APIError.httpsError(statusCode: 404)
        XCTAssertEqual(error.errorDescription, "HTTP error with status code: 404")
    }
    func testDecodingFailedErrorDescription() {
        
        let underlyingError = NSError(domain: "DecodingTest", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        
        let error = APIError.decodingFailed(underlyingError)
        XCTAssertEqual(error.errorDescription, "Decoding failed: Invalid JSON")
    }
    
    func testEncodingFailedErrorDescription() {
        let underlyingError = NSError(domain: "EncodingTest", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
        
        let error = APIError.decodingFailed(underlyingError)
        XCTAssertEqual(error.errorDescription, "Decoding failed: Encoding error")
    }
    
    func testNetworkErrorDescription() {
        
        let underlyingError = NSError(domain: "NetworkTest", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet connection"])
        
        let error = APIError.networkError(underlyingError)
        
        XCTAssertEqual(error.errorDescription, "Network error: No internet connection")
    }
    func testMissingResourceErrorDescription() {
        let error = APIError.missingResource("DiagnosticReport")
        
        XCTAssertEqual(error.errorDescription, "The requested FHIR resource was not found: DiagnosticReport")
    }
    func testOtherErrorDescription() {
        let underlyingError = NSError(domain: "OtherTest", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected error"])
        
        let error = APIError.other(underlyingError)
        
        XCTAssertEqual(error.errorDescription, "Other error: Unexpected error")
    }
    func testLocalizedErrorDescriptionMatchesErrorDescription() {
        
        let error = APIError.invalidResponse
        
        XCTAssertEqual(error.localizedDescription, "Invalid response")
    }

}
