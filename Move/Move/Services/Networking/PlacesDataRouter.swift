//
//  PlacesDataRouter.swift
//  Move
//
//  Created by David Řihák on 09.06.2026.
//

import Foundation

enum PlacesDataRouter {
    case searchPlaces(query: String)
    case searchNearbyByTheme(lat: Double, lng: Double, theme: String, radiusM: Double, amount: Int)
    case fetchPlacePhoto(photoName: String, maxWidth: Int)
}

extension PlacesDataRouter: Router {
    var host: String {
        return "https://places.googleapis.com"
    }
    
    var path: String {
        switch self {
        case .searchPlaces:
            return "v1/places:searchText"
        case .searchNearbyByTheme:
            return "v1/places:searchNearby"
        case .fetchPlacePhoto(let photoName, _):
            return "v1/\(photoName)/media"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .searchPlaces, .searchNearbyByTheme:
            return .post
        case .fetchPlacePhoto:
            return .get
        }
    }
    
    var urlParameters: [String : Any]? {
        switch self {
        case let .fetchPlacePhoto(_, maxWidth):
            return [
                "maxWidthPx": maxWidth,
                "key": APIConfig.placesApiKey
            ]
        default:
            return nil
        }
    }
    
    var headers: [String : String] {
        var defaultHeaders = [
            "X-Goog-Api-Key": APIConfig.placesApiKey,
            "Content-Type": "application/json"
        ]
        
        switch self {
        case .searchPlaces, .searchNearbyByTheme:
            defaultHeaders["X-Goog-FieldMask"] = "places.id,places.displayName,places.formattedAddress,places.photos,places.location"
            return defaultHeaders
        case .fetchPlacePhoto:
            return [:]
        }
    }
    
    func asRequest() throws -> URLRequest {
        guard let hostURL = URL(string: host) else {
            throw APIError.invalidHost
        }
        
        var url = hostURL.appending(path: path)
        
        if let urlParameters, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            urlComponents.queryItems = urlParameters.map { URLQueryItem(name: $0, value: String(describing: $1)) }
            if let compoundedURL = urlComponents.url {
                url = compoundedURL
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        switch self {
                case .searchPlaces(let query):
                    let body: [String: Any] = ["textQuery": query]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                case let .searchNearbyByTheme(lat, lng, theme, radiusM, amount):
                    let body: [String: Any] = [
                        "includedTypes": [theme],
                        "maxResultCount": amount,
                        "locationRestriction": [
                            "circle": [
                                "center": ["latitude": lat, "longitude": lng],
                                "radius": radiusM
                            ]
                        ]
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                default:
                    break
                }
        
        return request
    }
}

protocol PlacesServicing {
    func getPlaces(_ name: String) async throws -> [PlaceAPIData]
    func getPlacesByTheme(lat: Double, lng: Double, theme: String, radiusM: Double, amount: Int) async throws -> [PlaceAPIData]
    func getPlacePhotoData(_ photoName: String) async throws -> Data
}

final class PlacesService: PlacesServicing {
    
    private let apiManager: APIManaging
    
    init(apiManager: APIManaging = APIManager()) {
        self.apiManager = apiManager
    }
    
    func getPlaces(_ name: String) async throws -> [PlaceAPIData] {
        let endpoint = PlacesDataRouter.searchPlaces(query: name)
        let response: PlacesResponse = try await apiManager.request(endpoint)
        return response.places ?? []
    }
    
    func getPlacesByTheme(lat: Double, lng: Double, theme: String, radiusM: Double = 5000, amount: Int = 5) async throws -> [PlaceAPIData] {
            let endpoint = PlacesDataRouter.searchNearbyByTheme(lat: lat, lng: lng, theme: theme, radiusM: radiusM, amount: amount)
            let response: PlacesResponse = try await apiManager.request(endpoint)
            return response.places ?? []
        }
    
    func getPlacePhotoData(_ photoName: String) async throws -> Data {
        let endpoint = PlacesDataRouter.fetchPlacePhoto(photoName: photoName, maxWidth: 400)
        let request = try endpoint.asRequest()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw APIError.unacceptableResponseStatusCode
        }
        return data
    }
}
