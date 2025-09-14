import UIKit

class ProductTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: "ProductTableViewCell")

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var imageLoadingUUID: UUID?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let uuid = imageLoadingUUID {
            ImageLoader.shared.cancelLoad(uuid)
        }
        productImageView.image = nil
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        categoryLabel.text = product.category.uppercased()
        priceLabel.text = String(format: "$%.2f", product.price)
        
        if let imageUrl = product.image, let url = URL(string: imageUrl) {
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
