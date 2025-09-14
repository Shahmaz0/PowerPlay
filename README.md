# Powerplay Assignment

A UIKit-based iOS application that displays paginated product listings with networking and detail navigation.

## Features

- **Paginated TableView** - Loads products from API with infinite scroll
- **Custom Cells** - Displays title, description, category, price, and images
- **Detail Screen** - Full product details on cell tap
- **Error Handling** - No internet & API error states with retry
- **Loading States** - Spinners and "No Data" views
- **Image Caching** - Lazy loading with memory optimization

## Architecture

- **MVVM Pattern** - Clean separation of concerns
- **Protocol-Oriented** - Networking and delegation protocols
- **Modular Code** - Reusable components and services

## API Integration

- **Endpoint**: `https://fakeapi.net/products?page=0&limit=10&category=electronics`
- **Networking**: NSURLSession with Codable parsing
- **Pagination**: Starts from page 0, uses `nextPage` from response

## Setup

1. Clone the repository
2. Open `.xcodeproj` in Xcode
3. Build and run (iOS 13.0+)

## Key Components

- `ProductViewController` - Main table view with pagination
- `ProductDetailViewController` - Detail screen
- `ProductTableViewCell` - Custom cell with image loading
- `NetworkService` - API handling with error management
- `Product` - Codable model

## Error Handling

- Network connectivity checks
- API error responses
- Graceful fallbacks with retry options
