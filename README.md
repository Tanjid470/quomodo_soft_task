# E-Commerce Flutter App

A modern e-commerce mobile application built with Flutter, featuring clean architecture, BLoC state management, and API integration.

## Features

### ✅ Implemented Features

1. **Clean Architecture**
   - Feature-first folder structure
   - Separation of concerns (Data, Domain, Presentation layers)
   - Repository pattern for data management

2. **State Management**
   - BLoC (Business Logic Component) pattern
   - Reactive state handling
   - Event-driven architecture

3. **Network Layer**
   - Dio HTTP client with singleton pattern
   - Interceptors for request/response logging
   - Comprehensive error handling
   - Status code handling (200, 201, 202, 204, 400, 401, 403, 404, 500, etc.)

4. **UI Screens**
   - **Home Screen**: Search bar, category filters, product grid, bottom navigation
   - **All Products Screen**: Product listing with search functionality
   - **Product Detail Screen**: Image gallery, product details, features, reviews, add to cart

5. **API Integration**
   - Products listing with pagination
   - Product details by ID
   - Category-wise product filtering
   - Keyword search functionality
   - Categories listing

## Architecture

### Folder Structure

```
lib/
├── core/
│   ├── network/
│   │   └── api_client.dart          # Dio singleton with interceptor
│   └── theme/
│       └── app_colors.dart           # App color constants
├── features/
│   ├── home/
│   │   ├── pages/
│   │   │   ├── home_page.dart        # Home screen
│   │   │   ├── all_products_page.dart # Products listing
│   │   │   └── product_detail_page.dart # Product details
│   │   └── widgets/
│   │       └── product_card.dart      # Reusable product card
│   └── products/
│       ├── data/
│       │   ├── models/
│       │   │   ├── product_model.dart # Product data model
│       │   │   └── category_model.dart # Category data model
│       │   ├── datasources/
│       │   │   └── product_api_service.dart # API calls
│       │   └── repositories/
│       │       └── product_repository.dart # Data repository
│       └── presentation/
│           └── bloc/
│               ├── product_bloc.dart  # BLoC implementation
│               ├── product_event.dart # BLoC events
│               └── product_state.dart # BLoC states
└── main.dart                          # App entry point
```

## Key Components

### 1. ApiClient (Dio Singleton)

Located at: `lib/core/network/api_client.dart`

Features:
- Singleton pattern to prevent multiple Dio instances
- Interceptor for logging requests and responses
- Methods: GET, POST, PUT, DELETE, PATCH
- Comprehensive status code handling
- Error handling with custom ApiResponse wrapper

```dart
// Usage example
final apiClient = ApiClient();
final response = await apiClient.get('/products');
```

### 2. API Endpoints

Base URL: `https://mamunuiux.com/flutter_task/api`

- `GET /product` - Get all products (with pagination)
- `GET /product/slug` - Get product by Slug
- `GET //product-by-category/Id` - Get product details by Id
- `GET /products/category/:categoryId` - Get products by category
- `GET /categories` - Get all categories

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.6       # State management
  equatable: ^2.0.5          # Value equality
  dio: ^5.4.3+1              # HTTP client
  cached_network_image: ^3.3.1  # Image caching
  flutter_svg: ^2.0.10+1     # SVG support
  intl: ^0.19.0              # Internationalization
```

## Setup & Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

## How to Use

### Home Screen
- View featured products in a grid layout
- Browse categories (Mobile, Gaming, Images, Vehicles)
- Search products using the search bar
- Navigate using bottom navigation (Home, Message, Order, Profile)

### All Products Screen
- View all products in a grid
- Search products in real-time
- Tap any product to view details

### Product Detail Screen
- View product images in a gallery
- See price, original price, ratings, and reviews
- Read product description, introduction, and features
- Add product to cart
- View cart count badge

## Code Quality

✅ Clean and readable code  
✅ Well-structured architecture  
✅ Proper error handling  
✅ Loading states  
✅ Responsive UI  
✅ Image caching for performance  
✅ Reusable widgets  


## UI/UX Features

- **Search**: Real-time search with keyword filtering
- **Categories**: Quick category navigation
- **Product Cards**: Clean card design with images, ratings, and prices
- **Product Details**: Comprehensive product information
- **Cart**: Add to cart functionality with counter badge
- **Error Handling**: User-friendly error messages with retry option
- **Loading States**: Progress indicators during API calls
- **Image Caching**: Smooth image loading with caching

## Status Code Handling

The API client handles all HTTP status codes:

**Success Codes:**
- 200 OK
- 201 Created
- 202 Accepted
- 204 No Content

**Error Codes:**
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 408 Request Timeout
- 422 Unprocessable Entity
- 429 Too Many Requests
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable

---
