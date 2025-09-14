//
//  ApiService.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import Foundation

struct ApiService {
    
    func fetch<T: Decodable>(_ type: T.Type, url: URL?, completion: @escaping(Result<T, APIError>) -> Void) {
            
        guard let url = url else {
            let error = APIError.badURL
            completion(Result.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error as? URLError {
                completion(Result.failure(APIError.url(error)))
            } else if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(Result.failure(APIError.badResponse(statusCode: response.statusCode)))
            } else if let data = data {
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(type, from: data)
                    completion(Result.success(result))
                } catch let decodingError as DecodingError {
                    completion(Result.failure(APIError.parsing(decodingError)))
                } catch {
                    completion(Result.failure(APIError.unknown))
                }
            } else {
                completion(Result.failure(APIError.unknown))
            }
        }
        task.resume()
    }
}
