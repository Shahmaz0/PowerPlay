//
//  ErrorViewController.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import UIKit

class ErrorViewController: UIViewController {
    
    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var onRetryTapped: (() -> Void)?
    var error: APIError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithError()
    }
    
    private func setupUI() {
        // Configure retry button
        retryButton?.layer.cornerRadius = 8
        retryButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func configure(with error: APIError) {
        self.error = error
        configureWithError()
    }
    
    private func configureWithError() {
        guard let error = error else { 
            // Set default error if none provided
            errorTitle?.text = "Something went wrong"
            errorMessage?.text = "An unexpected error occurred. Please try again."
            errorIcon?.image = UIImage(systemName: "exclamationmark.triangle")
            return 
        }
        
        switch error {
        case .noInternet:
            errorTitle?.text = "No Internet Connection"
            errorMessage?.text = "Please check your internet connection and try again."
            errorIcon?.image = UIImage(systemName: "wifi.slash")
        case .badResponse(let statusCode):
            errorTitle?.text = "Server Error"
            errorMessage?.text = "The server returned an error (Code: \(statusCode)). Please try again later."
            errorIcon?.image = UIImage(systemName: "server.rack")
        case .parsing:
            errorTitle?.text = "Data Error"
            errorMessage?.text = "There was an error processing the data. Please try again."
            errorIcon?.image = UIImage(systemName: "exclamationmark.triangle")
        default:
            errorTitle?.text = "Something went wrong"
            errorMessage?.text = "An unexpected error occurred. Please try again."
            errorIcon?.image = UIImage(systemName: "exclamationmark.triangle")
        }
    }
    
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        onRetryTapped?()
    }
}

