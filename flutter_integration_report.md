# Integrating Search and Filter Features with Flutter

This report outlines how to connect the existing backend features (Search, Filter, Sort, and Pagination) with a Flutter mobile application.

---

## 1. Backend API Overview

The backend uses a generic `Features` class to handle various query parameters. Here is how they map to API calls:

| Feature | Query Parameter | Example |
| :--- | :--- | :--- |
| **Search** | `search` | `/products?search=phone` |
| **Sort** | `sort` | `/products?sort=-price` (descending) or `price` (ascending) |
| **Filter** | *Key Name* | `/products?price[gte]=100&category=ID` |
| **Pagination** | `page` & `limit` | `/products?page=2&limit=10` |
| **Fields** | `fields` | `/products?fields=description` (excludes description) |

---

## 2. Flutter Implementation Plan

To connect these features, you should use a robust networking package like `dio` (recommended) or `http`.

### A. Define the Product Model
First, create a model that matches the backend response.

```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String? cover;

  Product({required this.id, required this.name, required this.price, this.cover});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: (json['priceAfterDiscount'] ?? json['price']).toDouble(),
      cover: json['cover'],
    );
  }
}
```

### B. Create an API Service
Construct query parameters dynamically based on user input.

```dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'YOUR_API_BASE_URL'));

  Future<List<Product>> fetchProducts({
    String? search,
    String? sort,
    String? categoryId,
    double? maxPrice,
    int page = 1,
  }) async {
    Map<String, dynamic> queryParams = {
      'page': page,
      'limit': 10,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;
    if (categoryId != null) queryParams['category'] = categoryId;
    if (maxPrice != null) queryParams['price[lte]'] = maxPrice;

    try {
      final response = await _dio.get('/products', queryParameters: queryParams);
      final List data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }
}
```

---

## 3. UI Connection Strategy

### 1. Search Bar
Use a `TextField` with an `onChanged` or `onSubmitted` callback. To prevent too many requests while typing, implement a **Debouncer**.

```dart
// Inside your State class
Timer? _debounce;

_onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
        // Trigger API Call with 'query'
    });
}
```

### 2. Filtering Sidebar/Bottom Sheet
Use a `RangeSlider` for price and `Chips` or a `Dropdown` for categories. When the user clicks "Apply", update the query parameters and refresh the list.

### 3. Infinite Scrolling (Pagination)
Use a `ScrollController` to detect when the user reaches the bottom of the list.

```dart
_scrollController.addListener(() {
  if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    // Load next page: apiService.fetchProducts(page: currentPage + 1)
  }
});
```

---

## 4. Best Practices for Premium UX

1.  **Skeleton Loaders**: Show a shimmering placeholder while the data is fetching.
2.  **Empty States**: Display a beautiful illustration if no products match the search/filter.
3.  **Real-time Feedback**: Update the "Total Items" count immediately when a filter is selected.
4.  **Persistent Filters**: Allow users to clear specific filters using small "X" chips.

---

## 5. Summary Table for Frontend Developers

| Feature | Backend Operator | Flutter Component |
| :--- | :--- | :--- |
| **Price Range** | `price[gte]` & `price[lte]` | `RangeSlider` |
| **Newest First** | `sort=-createdAt` | `DropdownButton` (Sort) |
| **Category** | `category=ID` | `ListView.horizontal` (Chips) |
| **Search** | `search=value` | `SearchBar` / `TextField` |
