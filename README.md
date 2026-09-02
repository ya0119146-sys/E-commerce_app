<div align="center">

# 🛍️ Labella

### Full-Stack E-Commerce Mobile Application

A modern e-commerce mobile application built with **Flutter** and powered by a **Node.js REST API** with **MongoDB**.

Labella provides a complete shopping experience for customers, including authentication, product discovery, cart, wishlist, checkout, orders, reviews, and profile management. It also includes a dedicated admin panel for managing products, categories, users, and orders.

<br>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart\&logoColor=white)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC%2FCubit-7B2FBE)
![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?logo=node.js\&logoColor=white)
![Express](https://img.shields.io/badge/Framework-Express-000000?logo=express\&logoColor=white)
![MongoDB](https://img.shields.io/badge/Database-MongoDB-47A248?logo=mongodb\&logoColor=white)

</div>

---

## ✨ Highlights

* 🔐 **Secure Authentication** — JWT authentication with OTP email verification.
* 🛍️ **Complete Shopping Experience** — Browse, search, filter, and discover products.
* 🛒 **Cart Management** — Add products, update quantities, and manage cart items.
* ❤️ **Wishlist** — Save and manage favorite products.
* 📦 **Complete Order Flow** — Checkout, address selection, order placement, and order history.
* 🌟 **Reviews & Ratings** — Submit, update, delete, and view product reviews.
* 👤 **Profile Management** — Manage personal information, passwords, and addresses.
* 🛠️ **Admin Panel** — Manage products, categories, subcategories, users, and orders.
* 🎨 **Light & Dark Mode** — Theme switching with persisted user preference.
* 🌍 **Localization Support** — Internationalization using Flutter localization tools.
* ⚡ **Performance-Oriented UI** — Shimmer loading states and cached network images.
* 🧩 **Feature-First Architecture** — Modular and scalable project structure.

---

# 🚀 Features

## 🔐 Authentication & Security

* User registration.
* OTP-based email verification.
* JWT-based authentication.
* Secure JWT storage using `FlutterSecureStorage`.
* Automatic JWT injection through Dio interceptors.
* Forgot password workflow:

  * Request password reset.
  * Verify OTP.
  * Reset password.
* Role-based access control.
* Separate customer and admin flows.
* Account deletion.

---

## 🏠 Product Discovery

* Home screen with product listings.
* Product details with:

  * Product images.
  * Description.
  * Price.
  * Category information.
  * Reviews and ratings.
* Search products using backend-powered queries.
* Browse products by category.
* Browse products by subcategory.
* Product filtering.
* Product sorting.
* Pagination support.
* Shimmer skeleton loading states.

---

## 🛒 Cart

* Add products to cart.
* Remove products from cart.
* Increase/decrease product quantity.
* Display cart items and totals.
* Proceed directly to checkout.

---

## ❤️ Wishlist

* Add products to wishlist.
* Remove products from wishlist.
* View saved products.
* Persistent wishlist state through the backend.

---

## 📦 Checkout & Orders

* Select or manage delivery addresses.
* Place orders from the cart.
* Order confirmation.
* Order success screen.
* View order history.
* View individual order details.
* Track order delivery status.
* Track payment status.

---

## 🌟 Reviews & Ratings

* Submit product reviews.
* Add star ratings.
* View product reviews.
* Update personal reviews.
* Delete personal reviews.

---

## 👤 Profile

* View profile information.
* Update profile information.
* Change password.
* Manage delivery addresses.
* Delete account.
* Secure logout.

---

# 🛠️ Admin Panel

Labella includes a dedicated administration experience within the same application.

### Product Management

* Create products.
* Update products.
* Delete products.
* Manage product information and images.

### Category Management

* Create and manage categories.
* Create and manage subcategories.
* Update category information.
* Delete categories and subcategories.

### User Management

* View registered users.
* Manage user accounts.

### Order Management

* View orders.
* Update payment status.
* Update delivery status.
* Mark orders as delivered or paid.

---

# 🎨 UI & User Experience

* Responsive Flutter UI.
* Light and Dark themes.
* Persisted theme preference.
* Glassmorphism-inspired UI components.
* Smooth screen transitions and animations.
* Shimmer loading placeholders.
* Cached network images.
* Consistent typography using Google Fonts.
* Localization-ready interface.

---

# 🏗️ Architecture

The application follows a **Feature-First Architecture** to keep features modular, maintainable, and scalable.

```text
lib/
│
├── app/
│   ├── app.dart
│   └── bottom_nav_shell.dart
│
├── core/
│   ├── constants/
│   ├── di/
│   ├── network/
│   ├── theme/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── store/
│   ├── cart/
│   ├── wishlist/
│   ├── checkout/
│   ├── reviews/
│   ├── profile/
│   └── admin/
│
└── main.dart
```

### Architecture Overview

| Layer      | Responsibility                                                            |
| ---------- | ------------------------------------------------------------------------- |
| `app`      | Application initialization, global providers, and navigation shell        |
| `core`     | Shared infrastructure, networking, theme, constants, and reusable widgets |
| `features` | Independent business features                                             |
| `auth`     | Authentication and account flows                                          |
| `store`    | Product discovery and browsing                                            |
| `cart`     | Shopping cart management                                                  |
| `wishlist` | Wishlist management                                                       |
| `checkout` | Checkout and order management                                             |
| `reviews`  | Product reviews and ratings                                               |
| `profile`  | Profile and address management                                            |
| `admin`    | Administrative operations                                                 |

---

# 🧠 State Management

The application uses **BLoC/Cubit** for predictable and scalable state management.

Each major feature or operation has its own Cubit responsible for:

* Managing UI state.
* Handling API requests.
* Emitting loading, success, and error states.
* Keeping business logic outside the UI layer.

This separation makes the application easier to maintain, test, and extend.

---

# 🔌 Networking

All backend communication is handled through **Dio**.

The networking layer provides:

* REST API communication.
* Centralized API configuration.
* JWT authentication.
* Request interceptors.
* Error handling.
* Dynamic query parameters.
* Search and filtering.
* Pagination.

The Flutter application communicates with the Node.js backend through RESTful API endpoints.

---

# 🔑 Authentication Flow

```text
User
 │
 ▼
Register
 │
 ▼
OTP Verification
 │
 ▼
Account Activated
 │
 ▼
Login
 │
 ▼
JWT Token
 │
 ▼
Secure Storage
 │
 ▼
Authenticated API Requests
```

JWT tokens are stored securely on the device using `FlutterSecureStorage` and automatically attached to authenticated requests through Dio interceptors.

---

# 👥 Role-Based Application

Labella supports two application roles:

```text
                    ┌──────────────┐
                    │    Login     │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  User Role   │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
         Customer                      Admin
              │                         │
              ▼                         ▼
       Shopping Flow             Admin Panel
              │                         │
       ┌──────┴──────┐          ┌───────┴────────┐
       │             │          │                │
    Products       Orders    Products          Users
       │                        │                │
  Cart/Wishlist           Categories          Orders
```

The `BottomNavShell` determines the appropriate navigation experience based on the authenticated user's role.

---

# 🔍 Backend-Powered Search & Filtering

Product discovery is handled primarily on the backend rather than loading the entire product catalog into the application.

The Flutter client sends parameters such as:

* Search query.
* Category.
* Subcategory.
* Sorting.
* Filtering.
* Pagination.

This approach allows the application to efficiently handle larger product catalogs while keeping data processing closer to the backend.

---

# 🧰 Tech Stack

| Category                      | Technologies                |
| ----------------------------- | --------------------------- |
| **Mobile**                    | Flutter, Dart               |
| **State Management**          | BLoC / Cubit                |
| **Architecture**              | Feature-First Architecture  |
| **Dependency Injection**      | get_it                      |
| **Networking**                | Dio, REST API               |
| **Backend**                   | Node.js, Express            |
| **Database**                  | MongoDB                     |
| **Authentication**            | JWT                         |
| **Secure Storage**            | FlutterSecureStorage        |
| **Local Storage**             | SharedPreferences           |
| **Animations**                | flutter_animate             |
| **Image Loading**             | cached_network_image        |
| **Loading UI**                | shimmer                     |
| **Typography**                | Google Fonts                |
| **Localization**              | flutter_localizations, intl |
| **Environment Configuration** | flutter_dotenv              |
| **Backend Hosting**           | Railway                     |

---

# 📁 Project Structure

```text
e_commerce/
│
├── android/
├── ios/
├── assets/
│
├── lib/
│   ├── app/
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── di/
│   │   ├── network/
│   │   ├── theme/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── store/
│   │   ├── cart/
│   │   ├── wishlist/
│   │   ├── checkout/
│   │   ├── reviews/
│   │   ├── profile/
│   │   └── admin/
│   │
│   └── main.dart
│
├── .env
├── .gitignore
├── pubspec.yaml
└── README.md
```

---

# ⚙️ Getting Started

## Prerequisites

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Android SDK / Emulator or a physical Android device
* Git

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/e_commerce.git
```

### 2. Navigate to the project

```bash
cd e_commerce
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure environment variables

Create a `.env` file in the project root:

```env
BASE_URL=https://your-backend-url.com/api/v1
```

### 5. Run the application

```bash
flutter run
```

---

# 🔐 Environment Variables

The application uses `flutter_dotenv` to load environment-specific configuration.

Example:

```env
BASE_URL=https://your-backend-url.com/api/v1
```

> **Security:** Never commit passwords, JWT secrets, API keys, database credentials, or other sensitive information to the repository.

Make sure `.env` is included in `.gitignore` when it contains sensitive configuration.

---

# 📈 What This Project Demonstrates

This project demonstrates practical experience in:

* Building a complete Flutter e-commerce application.
* Developing a full-stack mobile application.
* Feature-first project organization.
* BLoC/Cubit state management.
* Dependency injection with `get_it`.
* REST API integration using Dio.
* JWT authentication.
* Secure token storage.
* Role-based access control.
* Backend-powered search and filtering.
* Pagination.
* CRUD operations.
* Admin panel development.
* Cart and wishlist management.
* Order management.
* Product reviews and ratings.
* Light and Dark theme implementation.
* Persistent local preferences.
* Image caching.
* Skeleton loading states.
* Responsive mobile UI.
* Localization.

---

# 🚧 Project Status

**Status: Completed**

Labella was developed as a personal full-stack portfolio project to demonstrate real-world Flutter application development, backend integration, authentication, state management, and e-commerce workflows.

---

# 📄 License

This project is developed as a personal portfolio project.

All rights reserved.

The source code and assets may not be copied, redistributed, or used commercially without permission.

---

<div align="center">

### Built with ❤️ using Flutter & Node.js

</div>
