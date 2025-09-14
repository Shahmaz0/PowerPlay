//
//  ApiError.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import Foundation

enum APIError: Error {
    case badURL
    case badResponse(statusCode: Int)
    case url(URLError?)
    case parsing(DecodingError?)
    case unknown
    case noInternet
    
    var localizedDescription: String {
        switch self {
        case .badURL, .parsing, .unknown:
            return "Sorry, something went wrong"
        case .badResponse(_):
            return "Sorry, the connection to our server failed."
        case .url(let error):
            return error?.localizedDescription ?? "Something went wrong"
        case .noInternet:
            return "No internet connection. Please check your connection and try again."
        }
    }
    
    var description: String {
        switch self {
        case .unknown: return "unknown error"
        case .badURL: return "invalid url"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing(let error):
            return "parsing error \(error?.localizedDescription ?? "")"
        case .badResponse(statusCode: let statusCode):
            return "bad response with status code \(statusCode)"
        case .noInternet:
            return "no internet connection"
        }
    }
}
