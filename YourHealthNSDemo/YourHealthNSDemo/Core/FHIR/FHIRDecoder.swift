//
//  FHIRDecoder.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation
import ModelsR4
internal import FMCore


enum FHIRDecoder{
    
    //Decode FHIR bundle using Apple FHIRModels
    static func decodeFHIR(from data:Data) throws -> ModelsR4.Bundle{
        let decoder = JSONDecoder.fhirModelsReadyDecoder()
        do {
            return try decoder.decode(ModelsR4.Bundle.self,from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    // Decode REsources
    static func decodeResource(from data:Data) throws -> FHIRResource {
        do {
            let resource = try JSONDecoder().decode(FHIRResource.self, from: data)
            guard  !resource.resourceType.isEmpty else {
                throw APIError.invalidResponse
            }
            return resource
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    //Decode Bundle
    static func decodeBundle(from data:Data) throws -> FHIRBundle {
        do {
            return try JSONDecoder().decode(FHIRBundle.self, from: data)
        }
        /*catch let error as DecodingError{
            print("FHIR Decoding Error: \(error)")
            switch error {
            case .typeMismatch(let type, let context):
                print("Type mismatch: \(type)")
                print("Coding path: \(context.codingPath)")
                print("Description: \(context.debugDescription)")

            case .keyNotFound(let key, let context):
                print("Missing key: \(key)")
                print("Coding path: \(context.codingPath)")

            case .valueNotFound(let type, let context):
                print("Missing value: \(type)")
                print("Coding path: \(context.codingPath)")

            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")

            @unknown default:
                print("Unknown decoding error")
            }

            throw APIError.decodingFailed(error)
        }*/
        catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    // Decode a specific respources
    static func decode<T:Decodable>(_ type: T.Type, from data:Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    static func recourceType(from data:Data) throws -> String {
        do {
            let container = try JSONSerialization.jsonObject(with: data)
            
            guard let json = container as? [String: Any],let resourceType = json["resourceType"] as? String else {
                throw APIError.invalidResponse
            }
            return resourceType
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
