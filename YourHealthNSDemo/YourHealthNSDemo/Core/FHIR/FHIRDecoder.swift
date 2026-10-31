//
//  FHIRDecoder.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation


enum FHIRDecoder{
    
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
/*
struct FHIRBundle:Codable{
    let resourceType:String
    let entry:[FHIRBundleEntry]?
}

struct FHIRBundleEntry:Codable{
    let fullUrl:String?
    let resource:FHIRResource?
}

struct FHIRResource:Codable {
    let resourceType:String
    let id:String?
    let status:String?
    let effectiveDateTime:String?
    let performer:[FHIRRefrence]?
    let code:FHIRCodeableConcept?
    let text:FHIRText?
    let result:[FHIRRefrence]?
    let valueQuantity:FHIRValueQuantity?
    let refrenceRange:[FHIRRefrenceRange]?
}

struct FHIRText:Codable{
    let status:String?
    let div:String?
}

struct FHIRCodeableConcept:Codable{
    let coding:[FHIRCoding]?
    let text:String?
}

struct FHIRCoding:Codable{
    let system:String?
    let code:String?
    let display:String?
}
struct FHIRRefrence:Codable{
    let reference:String?
    let display:String?
}

struct FHIRValueQuantity:Codable{
    let value:Double?
    let unit:String?
    let system:String?
    let code:String?
}

struct FHIRRefrenceRange:Codable{
    let low:FHIRValueQuantity?
    let high:FHIRValueQuantity?
    let text:[String]?
}
*/
