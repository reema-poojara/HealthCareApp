//
//  APIClient.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

struct APIClient {
    
    private let session : URLSession
    private let decoder : JSONDecoder
    private let encoder : JSONEncoder
    
    init(session: URLSession = .shared,decoder:JSONDecoder = JSONDecoder(),encoder:JSONEncoder = JSONEncoder()) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
    func getRawData(from url:URL,headers:[String:String] = [:]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/fhir+json, application/json",forHTTPHeaderField: "Accept")
        addHeaders(headers,to: &request)
        
        do {
            let (data,response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpsError(statusCode: httpResponse.statusCode)
            }
            return data
        }catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    func get<T: Decodable>(from url: URL, headers: [String:String] = [:]) async throws -> T{
     
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/fhir+json, application/json",forHTTPHeaderField: "Accept")
        
        addHeaders(headers,to: &request)
        return try await send(request)
    }
    
    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        
        do{
            let (data,response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpsError(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed(error)
            }
        }catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    private func addHeaders(_ headers: [String:String], to request: inout URLRequest) {
        for (key,value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
