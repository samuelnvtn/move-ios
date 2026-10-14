//
//  APIManager.swift
//  Move
//
//  Created by David Řihák on 09.06.2026.
//

import Foundation

protocol APIManaging {
    func request<T: Decodable>(_ endpoint: Router) async throws -> T
}

final class APIManager: APIManaging {
    private let decoder = JSONDecoder()

    func request<T: Decodable>(_ endpoint: Router) async throws -> T {
        let request = try endpoint.asRequest()
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("XXX Google API Error (\(httpResponse.statusCode)): \(errorString)")
            }
            
            throw APIError.unacceptableResponseStatusCode
        }

        let object = try decoder.decode(T.self, from: data)
        return object
    }
}
