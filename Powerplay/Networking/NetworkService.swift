//
//  NetworkService.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import Foundation
import Network

protocol NetworkServiceProtocol {
    func fetchProducts(page: Int, limit: Int, category: String, completion: @escaping(Result<APIResponse, APIError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let apiService = ApiService()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    func fetchProducts(page: Int, limit: Int, category: String, completion: @escaping(Result<APIResponse, APIError>) -> Void) {
        if monitor.currentPath.status != .satisfied {
            completion(.failure(.noInternet))
            return
        }
        
        performAPICall(page: page, limit: limit, category: category, completion: completion)
    }
    
    private func performAPICall(page: Int, limit: Int, category: String, completion: @escaping(Result<APIResponse, APIError>) -> Void) {
        guard var urlComponents = URLComponents(string: "https://fakeapi.net/products") else {
            completion(.failure(.badURL))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "category", value: category)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(.badURL))
            return
        }
        
        apiService.fetch(APIResponse.self, url: url) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                if case .url(let urlError) = error,
                   let nsError = urlError as NSError? {
                    switch nsError.code {
                    case NSURLErrorNotConnectedToInternet,
                         NSURLErrorNetworkConnectionLost,
                         NSURLErrorCannotConnectToHost,
                         NSURLErrorCannotFindHost,
                         NSURLErrorTimedOut:
                        completion(.failure(.noInternet))
                    default:
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
