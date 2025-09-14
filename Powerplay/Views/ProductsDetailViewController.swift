//
//  ProductsDetailViewController.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var specsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var product: Product?
    private var imageLoadingUUID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWithProduct()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let uuid = imageLoadingUUID {
            ImageLoader.shared.cancelLoad(uuid)
        }
    }
    
    private func configureWithProduct() {
        guard let product = product else { return }
        
        
        title = product.title
        titleLabel.text = product.title
        priceLabel.text = String(format: "$%.2f", product.price)
        descriptionLabel.text = product.description

        
        if let brand = product.brand {
            brandLabel.text = "Brand: \(brand)"
            brandLabel.isHidden = false
        } else {
            brandLabel.isHidden = true
        }
        
        if let stock = product.stock {
            stockLabel.text = "In Stock: \(stock) units"
            stockLabel.isHidden = false
        } else {
            stockLabel.isHidden = true
        }
        
        if let specs = product.specs {
            specsLabel.text = "Specifications:\n\(specs.toDisplayString())"
            specsLabel.isHidden = false
        } else {
            specsLabel.isHidden = true
        }
        
        if let rating = product.rating {
            ratingLabel.text = rating.starRating()
            ratingLabel.isHidden = false
        } else {
            ratingLabel.isHidden = true
        }
        
        if let imageUrl = product.image {
            imageLoadingUUID = ImageLoader.shared.loadImage(imageUrl) { [weak self] (result: Result<UIImage, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self?.productImageView.image = image
                    case .failure:
                        self?.productImageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
    }
}
