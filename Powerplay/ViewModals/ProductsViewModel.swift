//
//  ProductsViewModel.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import Foundation

protocol ProductsViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: APIError)
    func didUpdateProducts()
}

class ProductsViewModel {
    private let networkService: NetworkServiceProtocol
    private var products: [Product] = []
    private var currentPage = 0
    private var limit = 10
    private var category = "electronics"
    private var isLoading = false
    private var hasMoreData = true
    private var hasReachedEnd = false
    
    private var lastSuccessfulData: [Product] = []
    private var lastSuccessfulPage = 0
    private var hasStoredData = false
    
    weak var delegate: ProductsViewModelDelegate?
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    var numberOfProducts: Int {
        return products.count
    }
    
    var hasProducts: Bool {
        return !products.isEmpty
    }
    
    // MARK: - Data Persistence
    private func saveSuccessfulData() {
        lastSuccessfulData = products
        lastSuccessfulPage = currentPage
        hasStoredData = true
    }
    
    private func restoreLastSuccessfulData() {
        if hasStoredData && !lastSuccessfulData.isEmpty {
            products = lastSuccessfulData
            currentPage = lastSuccessfulPage
            hasMoreData = true
            hasReachedEnd = false
        }
    }
    
    private func clearStoredData() {
        lastSuccessfulData.removeAll()
        lastSuccessfulPage = 0
        hasStoredData = false
    }
    
    var shouldShowNoMoreDataCell: Bool {
        return hasReachedEnd && !products.isEmpty
    }
    
    func product(at index: Int) -> Product {
        return products[index]
    }
    
    func loadProducts() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        delegate?.didStartLoading()
        
        networkService.fetchProducts(page: currentPage, limit: limit, category: category) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.delegate?.didFinishLoading()
                
                switch result {
                case .success(let response):
                    if response.data.isEmpty {
                        self.hasMoreData = false
                        self.hasReachedEnd = true
                        self.delegate?.didUpdateProducts()
                        return
                    }
                    
                    let previousCount = self.products.count
                    self.products.append(contentsOf: response.data)
                    
                    if self.products.count == previousCount {
                        self.hasMoreData = false
                        self.hasReachedEnd = true
                    } else {
                        self.currentPage += 1
                        self.hasMoreData = true
                    }
                    
                    self.saveSuccessfulData()
                    self.delegate?.didUpdateProducts()
                    
                case .failure(let error):
                    self.delegate?.didReceiveError(error)
                }
            }
        }
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        if currentIndex >= products.count - 3 && hasMoreData && !isLoading {
            loadProducts()
        }
    }
    
    func retry() {
        restoreLastSuccessfulData()
        
        if hasStoredData && !products.isEmpty {
            delegate?.didUpdateProducts()
            
            if hasMoreData {
                loadProducts()
            }
        } else {
            clearStoredData()
            currentPage = 0
            products.removeAll()
            hasMoreData = true
            hasReachedEnd = false
            isLoading = false
            
            delegate?.didStartLoading()
            loadProducts()
        }
    }
    
    func resetPagination() {
        currentPage = 0
        hasMoreData = true
        isLoading = false
    }
    
}
