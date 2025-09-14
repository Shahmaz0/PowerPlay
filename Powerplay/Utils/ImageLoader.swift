//
//  ImageLoader.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private var runningRequests: [UUID: URLSessionDataTask] = [:]
    
    func loadImage(_ urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return nil
        }
        
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(.success(cachedImage))
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.runningRequests.removeValue(forKey: uuid) }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "ImageLoader", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])))
                return
            }
            
            self?.cache.setObject(image, forKey: urlString as NSString)
            completion(.success(image))
        }
        
        task.resume()
        runningRequests[uuid] = task
        
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
