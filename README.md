<div align="center">

<img src="assets/icons/app_icon2.jpg" alt="Labella Logo" width="110" />

# 🛍️ Labella

### Production Luxury Beauty & Fashion E-Commerce Mobile Application

A full-stack luxury e-commerce mobile application built with **Flutter**, architected with **BLoC/Cubit** and **Feature-First Clean Architecture**, powered by a **Node.js / Express / MongoDB** REST API, and **published on Google Play**.

<br>

[![Google Play](https://img.shields.io/badge/Google%20Play-Published-414141?logo=google-play\&logoColor=white)](https://play.google.com/store/apps/details?id=com.youssefahmed.labella)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart\&logoColor=white)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC%2FCubit-7B2FBE)
![Backend](https://img.shields.io/badge/Backend-Node.js%20%2B%20Express-339933?logo=node.js\&logoColor=white)
![Database](https://img.shields.io/badge/Database-MongoDB-47A248?logo=mongodb\&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-47%20Passing-2EA44F)

</div>

---

## ✨ Key Highlights

* 📱 **Published on Google Play** — Production-signed Android App Bundle (`.aab`) with Kotlin DSL Gradle release configuration (`com.youssefahmed.labella`).
* 🧭 **Frictionless Guest Browsing & `AuthGuard`** — Guests can freely explore the catalog, search, and view product details, with an elegant contextual `AuthRequiredSheet` prompt when tapping protected actions (Cart, Wishlist, Checkout, Reviews).
* 🔍 **Smart Arabic & English Search Relevance** — Client-side scoring engine (`SearchRelevanceHelper`) that normalizes Arabic characters (`أ/إ/آ`, `ة/ه`, `ى/ي`, diacritic stripping), matches cosmetic synonyms (`سيروم`/`سيرم`, `ريتينول`/`ريتنول`), and ranks title matches ahead of description matches.
* 🛍️ **In-Place PDP Quantity Stepper & Optimistic Wishlist** — Interactive bottom-bar quantity stepper with a direct **"Proceed to Checkout"** CTA on the Product Detail screen, paired with instant optimistic wishlist updates.
* 🌍 **Full Bilingual Localization (Arabic RTL & English LTR)** — Synchronized startup language loading with dynamic layout switching and full Arabic/English translation coverage (`AppTranslations` & `LocaleCubit`).
* 🎨 **Luxury Glassmorphism UI & Persistent Theming** — Smooth animations (`flutter_animate`), shimmer placeholders, cached network images, and persistent Light & Dark mode switching.
* 🚚 **Egyptian Governorates Shipping & Deposit Flow** — Built-in support for all 27 Egyptian governorates with automatic shipping calculation (free delivery in Al Sharqia, 100 EGP elsewhere), deposit tracking, and direct WhatsApp merchant communication.
* 🛠️ **Integrated Admin Dashboard** — Role-based access control featuring full CRUD management for products, categories, subcategories, users, and paginated order administration.
* 🧪 **Automated Test Coverage** — **47 passing unit, integration, contract, and responsive viewport tests** verifying API resilience, RTL/LTR rendering, guest interception, and search ranking.

---

## 🚀 Feature Breakdown

### 🔐 Authentication & Guest Experience
* JWT-based authentication with secure device storage (`FlutterSecureStorage`) and automatic token injection via Dio interceptors.
* User registration, login, admin login, and OTP-based forgot/reset password flows.
* Centralized `AuthGuard` interception allowing seamless Guest Mode browsing before prompting sign-in.
* Profile management, password updates, delivery address CRUD, and account deletion.

### 🏠 Storefront, Discovery & Search
* Luxury Home experience with auto-scrolling hero banners, category horizontal grid, paginated product grid, and quick-access profile/search buttons.
* Backend-powered search & filtering combined with client-side `SearchRelevanceHelper` ranking across all categories.
* Detailed Product Page with zoomable image gallery (`photo_view`), size badges, category/subcategory breadcrumb resolution, discounted pricing display, and customer reviews.

### 🛒 Cart, Optimistic Wishlist & Checkout
* In-place PDP quantity stepper (`-` / `+`) with instant sync and direct navigation to the Cart screen.
* Optimistic wishlist toggling that immediately updates both heart indicators and the local Wishlist view.
* Checkout flow with Egyptian governorate selection, automatic shipping policy calculation (`EgyptGovernorates`), deposit calculations, order placement success flow, and order detail tracking.
* Direct WhatsApp integration (`WhatsAppHelper`) for customer support and order inquiries.

### 🛠️ Admin Panel (Role-Based)
* Dedicated admin shell inside `BottomNavShell` when authenticated as an admin.
* Full CRUD operations for Products (with multi-image upload), Categories, Subcategories, and Users.
* Paginated infinite-scroll product and order management, including payment and delivery status updates.

---

## 🏗️ Architecture & Project Structure

The app uses a **Feature-First Clean Architecture** combined with **BLoC/Cubit** and **GetIt** dependency injection to keep business logic cleanly decoupled from UI and networking.

```text
e_commerce/
│
├── android/                        # Android Kotlin DSL config, release signing & mipmap icons
├── ios/                            # iOS runner & AppIcon assets
├── assets/icons/                   # App launcher icon & brand assets
│
├── lib/
│   ├── app/
│   │   ├── app.dart                # Root MultiBlocProvider, Theme & Locale wiring
│   │   ├── bottom_nav_shell.dart   # Role-based navigation shell (Customer / Guest / Admin)
│   │   └── splash_veiw.dart        # Startup splash screen
│   │
│   ├── core/
│   │   ├── constants/              # Colors, dimensions, gradients, shadows, Egypt governorates
│   │   ├── di/                     # GetIt service locator (service_locator.dart)
│   │   ├── localization/           # LocaleCubit & AppTranslations (AR/EN)
│   │   ├── network/                # DioClient, JWT interceptors, ApiConstants, ApiException
│   │   ├── theme/                  # AppTheme (Light/Dark) & ThemeCubit
│   │   ├── utils/                  # AuthGuard, SearchRelevanceHelper, AppValidators, WhatsAppHelper
│   │   └── widgets/                # AuthRequiredSheet, CustomSnackBar, GlassPanel, HeroButton, etc.
│   │
│   ├── features/
│   │   ├── admin/                  # Admin dashboard, forms & management cubits
│   │   ├── auth/                   # Login, signup, OTP verification, password reset
│   │   ├── cart/                   # Cart repository, cubit & screen
│   │   ├── checkout/               # Checkout, orders, shipping & order details
│   │   ├── profile/                # Profile, address management & theme/language settings
│   │   ├── reviews/                # Product ratings & reviews CRUD
│   │   ├── store/                  # Home, search, categories & product details
│   │   └── wishlist/               # Wishlist state & optimistic toggle handling
│   │
│   └── main.dart                   # Global error handlers, .env init, portrait lock & DI setup
│
├── test/
│   ├── api_integration_test.dart   # API error parsing, model contracts, HTTP 404 tolerance & shipping rules
│   ├── guest_browsing_test.dart    # Auth state classification, AuthGuard & WishlistCubit sanitization
│   ├── responsive_viewports_test.dart # Multi-screen (320px - 600px) & Arabic RTL overflow checks
│   ├── search_relevance_test.dart  # Arabic normalization, synonym matching & relevance sorting
│   └── widget_test.dart
│
├── analysis_options.yaml           # Analyzer rules & lints
└── pubspec.yaml
```

---

## 🧰 Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **Framework & Language** | Flutter 3.x, Dart 3.x |
| **State Management** | `flutter_bloc` (BLoC / Cubit), `equatable` |
| **Dependency Injection** | `get_it` |
| **Networking & Auth** | `dio`, RESTful APIs, JWT Authentication |
| **Local & Secure Storage** | `flutter_secure_storage`, `shared_preferences` |
| **UI & Animations** | `google_fonts`, `flutter_animate`, `lucide_icons`, `shimmer`, `cached_network_image`, `photo_view`, `flutter_staggered_grid_view` |
| **Localization & Config** | `flutter_localizations`, `intl`, `flutter_dotenv` |
| **Platform Integrations** | `url_launcher` (WhatsApp), `image_picker` |
| **Backend & Hosting** | Node.js, Express, MongoDB (hosted on **Fly.io**) |
| **Android Release** | Gradle Kotlin DSL, Keystore Release Signing, Android App Bundle (`.aab`), `flutter_launcher_icons` |

---

## ⚙️ Getting Started

### Prerequisites
* **Flutter SDK** (`>= 3.x`, Dart SDK `^3.8.1`)
* **Android Studio / VS Code** with Android SDK & NDK `27.0.12077973`
* **Git**

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ya0119146-sys/E-commerce_app.git
   cd E-commerce_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   Create a `.env` file in the project root *(note: `BASE_URL` must **not** include `/api/v1`)*:
   ```env
   BASE_URL=https://backend-gleaming-frost-9826.fly.dev
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Verification

Run the automated test suite and static analyzer to verify everything passes cleanly:

```bash
# Run all 47 unit, integration & responsive widget tests
flutter test

# Run static code analysis
flutter analyze
```

### Android Release Build
To build a signed release Android App Bundle (`.aab`) or APK (requires local `android/key.properties` and upload keystore):
```bash
flutter build appbundle --release
# or
flutter build apk --release
```

> **Security Note:** Sensitive files (`.env`, `android/key.properties`, `*.jks`) are strictly excluded from version control via `.gitignore`.

---

## 📊 Project Status

**Status:** Production — **Published on Google Play** (`v1.0.0+1`)

---

## 👨‍💻 Author

**Youssef Ahmed Fathy Hamouda** — *Flutter Developer*
* 📧 Email: [ya0119146@gmail.com](mailto:ya0119146@gmail.com)
* 🐙 GitHub: [@ya0119146-sys](https://github.com/ya0119146-sys)

---

## 📄 License

This project is developed as a commercial and portfolio production application. All rights reserved. Source code and brand assets may not be redistributed or used commercially without permission.

<div align="center">

### Built with ❤️ using Flutter, BLoC & Node.js

</div>
