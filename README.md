<div align="center">

# Labella

### A Full-Stack Flutter E-Commerce Application

*Personal Project — Full-Stack Mobile Application*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/BLoC%2FCubit-7B2FBE)](https://bloclibrary.dev)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/Database-MongoDB-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com)

**Labella** is a full-featured luxury e-commerce mobile application built with Flutter. Customers can browse products by category, manage their cart and wishlist, place orders, and write reviews. Admins have a dedicated panel to manage products, categories, and users — all through a single polished application.

</div>

---

## ✨ Key Highlights

* 🔐 JWT authentication with OTP verification and secure token storage
* 🛍️ Full product browsing with search, filtering, and category navigation
* 🛒 Cart and wishlist management with real-time updates
* 📦 Order placement, tracking, and order history
* 🌟 Product reviews and star ratings
* 👤 Profile management with address management and password change
* 🛠️ Admin panel for managing products, categories, subcategories, and users
* 🎨 Light and Dark themes with persisted preference
* 💉 Dependency injection using get_it

---

## ✨ Features

### 🔐 Authentication & Security

* User registration with OTP email verification
* JWT-based login with secure token storage using FlutterSecureStorage
* Forgot password flow: request → verify OTP → reset password
* Role-based access control for **Customer** and **Admin**
* Separate admin login endpoint

### 🏠 Product Discovery

* Home screen with product listings and category grid
* Product detail screen with images, description, and pricing
* Search functionality with query-based API filtering
* Browse by category and subcategory
* Shimmer loading placeholders during data fetching

### 🛒 Cart

* Add and remove products from the cart
* Update item quantities
* View cart totals and proceed to checkout

### ❤️ Wishlist

* Save products to a personal wishlist
* Remove items from the wishlist

### 📦 Checkout & Orders

* Place orders from the cart
* Manage delivery addresses
* View order history
* View individual order details
* Order success confirmation screen

### 🌟 Reviews

* Submit star ratings and written reviews for products
* View all reviews for a product
* Update or delete your own review

### 👤 Profile

* View and update profile information
* Change password
* Manage delivery addresses
* Delete account

### 🛠️ Admin Panel

* Create, update, and delete products
* Manage categories and subcategories
* View and manage user accounts
* Mark orders as delivered or paid

### 🎨 Theme & UI

* Light and Dark themes with toggle
* Theme preference persisted across sessions
* Glassmorphism-style UI panels
* Google Fonts integration for consistent typography
* lutter_animate for smooth screen transitions
* cached_network_image for efficient image loading

---

## 🎯 What This Project Demonstrates

This project demonstrates experience with:

* Building a complete e-commerce Flutter application from scratch
* Feature-based project organization with clean folder structure
* BLoC/Cubit state management across multiple independent features
* Dependency injection using get_it and service_locator
* REST API integration with Dio and interceptor-based JWT injection
* JWT authentication and secure on-device token storage
* Role-based application flows (Customer vs Admin)
* Search, filter, sort, and pagination integration with a backend API
* Image loading optimization with cached_network_image
* Shimmer skeleton loaders for improved perceived performance
* Light and Dark theme management
* Admin CRUD operations through a dedicated panel

---

## 🛠️ Tech Stack

| Category | Technologies |
| --- | --- |
| **Mobile** | Flutter, Dart |
| **State Management** | BLoC / Cubit |
| **Dependency Injection** | get_it |
| **Networking** | Dio, REST API |
| **Backend** | Node.js, Express |
| **Database** | MongoDB |
| **Authentication** | JWT |
| **Local & Secure Storage** | SharedPreferences, FlutterSecureStorage |
| **UI & Animations** | flutter_animate, Google Fonts, shimmer |
| **Image Loading** | cached_network_image |
| **Localization** | flutter_localizations, intl |
| **Hosting** | Railway |

---

## 🏛️ Architecture

The project follows a **Feature-First architecture**, where the application is organized into independent feature modules. Each feature contains its own UI, state management, data models, and repository.

`	ext
lib/
├── app/
│   ├── app.dart               # Root widget — BLoC providers and theme setup
│   └── bottom_nav_shell.dart  # Role-aware bottom navigation shell
│
├── core/
│   ├── constants/             # Colors, dimensions, gradients, shadows
│   ├── di/                    # Service locator and dependency injection setup
│   ├── network/               # Dio client, API constants, and error handling
│   ├── theme/                 # Light and Dark theme definitions and ThemeCubit
│   └── widgets/               # Shared reusable UI components
│
├── features/
│   ├── auth/                  # Login, Registration, OTP, Forgot Password
│   ├── store/                 # Home, Product Detail, Search, Category browsing
│   ├── cart/                  # Cart management
│   ├── wishlist/              # Wishlist management
│   ├── checkout/              # Order placement, history, and detail
│   ├── reviews/               # Product reviews and ratings
│   ├── profile/               # Profile, address, and account management
│   └── admin/                 # Admin panel for products, categories, and users
│
└── main.dart                  # Application entry point
`

### Key Technical Decisions

* **get_it** is used as a service locator for dependency injection across features
* **BLoC/Cubit** manages application state, with one Cubit per distinct feature operation
* **Dio** handles all REST API communication with interceptors for token injection and error handling
* **FlutterSecureStorage** stores JWT tokens securely on device
* **flutter_animate** provides declarative animation support across screens
* **ThemeCubit** manages Light/Dark theme switching with SharedPreferences persistence
* **flutter_dotenv** loads environment configuration at startup

---

## 🌟 Unique Features

### 🛠️ Dual-Role Application

The same application serves both customers and admins. After login, the app detects the user role and renders a different bottom navigation experience — customers see the shopping interface while admins see the management panel. This is handled by the BottomNavShell widget based on the authenticated user's role.

### 📦 Complete Order Lifecycle

The checkout feature supports the full order lifecycle — from cart confirmation and address selection through to order placement, payment status, delivery status, and order history — reflecting a real-world e-commerce flow.

### 🔍 Backend-Powered Search and Filtering

Product search and filtering are handled server-side. The Flutter app constructs dynamic query parameters (search, sort, filter, pagination) and passes them to the backend, enabling efficient large-scale product discovery without loading everything client-side.

---

## 🚦 Getting Started

### Prerequisites

Before running the project, make sure you have:

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* Dart SDK
* Android Studio or VS Code with the Flutter extension

### Installation

`ash
# Clone the repository
git clone https://github.com/<your-username>/e_commerce.git

# Navigate to the project
cd e_commerce

# Install dependencies
flutter pub get

# Run the application
flutter run
`

---

## 🔑 Environment Configuration

Create a .env file in the project root:

`env
BASE_URL=https://your-backend-url.com/api/v1
`

> **Security Note:** Never commit credentials, tokens, API keys, or other sensitive values to a public repository. Make sure your .env file is included in .gitignore.

The BASE_URL is used for all REST API communication.

---

## 🚧 Project Status

This project is developed as a personal Flutter portfolio project demonstrating full e-commerce mobile application development.

---

## 📄 License

This project is developed as a personal portfolio project. All rights reserved.

---

<div align="center">

Built as a Flutter Portfolio Project using Flutter and a Node.js backend.

</div>
