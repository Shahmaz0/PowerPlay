//
//  ProductsTableViewController.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import UIKit

class ProductsViewController: UITableViewController {
    private let viewModel = ProductsViewModel()
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupActivityIndicator()
        setupViewModel()
        viewModel.loadProducts()
    }
    
    private func setupNavigationBar() {
        // Configure large title navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        // Register cell
        tableView.register(UINib(nibName: ProductTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProductTableViewCell.identifier)
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl
        
    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    
    
    
    @objc private func refreshData() {
        viewModel.retry()
    }
    
    private func showTableView() {
        tableView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productCount = viewModel.numberOfProducts
        let noMoreDataCell = viewModel.shouldShowNoMoreDataCell ? 1 : 0
        return productCount + noMoreDataCell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if this is the "No Data" cell
        if viewModel.shouldShowNoMoreDataCell && indexPath.row == viewModel.numberOfProducts {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
            cell.textLabel?.text = "No more products available"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let product = viewModel.product(at: indexPath.row)
        cell.configure(with: product)
        
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.row)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.shouldShowNoMoreDataCell && indexPath.row == viewModel.numberOfProducts {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            let product = viewModel.product(at: indexPath.row)
            detailVC.product = product
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - ProductsViewModelDelegate

extension ProductsViewController: ProductsViewModelDelegate {
    func didStartLoading() {
        if !(refreshControl?.isRefreshing ?? false) {
            activityIndicator.startAnimating()
        }
        showTableView()
    }

    func didFinishLoading() {
        refreshControl?.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    func didReceiveError(_ error: APIError) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let errorVC = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as? ErrorViewController {
            errorVC.configure(with: error)
            errorVC.onRetryTapped = { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        self.viewModel.retry()
                    }
                }
            }
            errorVC.modalPresentationStyle = .fullScreen
            present(errorVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func didUpdateProducts() {
        showTableView()
        tableView.reloadData()
    }
}
