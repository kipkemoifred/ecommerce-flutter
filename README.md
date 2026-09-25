# 🛒 ShopNest – Multi-Vendor E-Commerce Marketplace

A full-featured, modern multi-role e-commerce platform built with **Flutter**, **GetX**, **Dio**, **fl_chart**, and **Firebase** (with automated local reactive fallback).

---

## 🌟 Overview & Key Roles

ShopNest is designed from the ground up to support three distinct user personas within a single unified app experience:

### 1. 🛍️ Customer Persona
* **Authentication**: Login and registration with credential validation.
* **Product Discovery**: Rich home feed with promotional banners, featured items, and category filters.
* **Advanced Search & Filtering**: Instant search by keyword, category filtering, minimum rating filters, and interactive price range sliders.
* **Product Details**: Image gallery preview, detailed descriptions, stock availability badges, and interactive customer reviews.
* **Cart & Discounts**: Dynamic subtotal, tax calculation, free shipping progress bar, and promo code support (e.g., `SOUND20`, `WELCOME10`).
* **Multi-Step Checkout**: Shipping address management, payment method selection (Credit Card, Apple/Google Pay, Cash on Delivery), and order review.
* **Order Tracking Timeline**: Step-by-step visual timeline tracking order progress (`Pending` → `Confirmed` → `Shipped` → `Delivered`).
* **Wishlist**: Save favorite items with one-tap transfer to cart.
* **Reviews & Ratings**: Submit star ratings with text reviews, dynamically recalculating product averages.
* **Notifications**: Real-time notifications for order status changes and promotional offers.

---

### 2. 🏪 Seller Persona
* **Seller Dashboard**: Real-time revenue metrics, active product counts, pending orders count, and weekly sales performance bar charts.
* **Product Management**: Add, edit, and delete products with image selection presets or custom URLs, pricing, category assignment, and tags.
* **Inventory Control**: Live stock counters with instant +/- stock adjustments and out-of-stock indicators.
* **Order Processing**: View orders containing items from your store, inspect customer details, and transition order stages (`Confirmed` → `Shipped` → `Delivered`).
* **Sales Analytics**: Revenue metrics and sales performance insights.

---

### 3. 🛡️ Admin Persona
* **Platform Governance**: High-level platform KPIs including Gross Merchandise Value (GMV), total active stores, users, and orders.
* **User Management**: View all registered customers, inspect account creation details, and suspend/activate accounts.
* **Seller Verification**: Review vendor applications, audit store descriptions, and approve/verify seller status.
* **Catalog Moderation**: View all platform products, toggle "Featured" status, and delete non-compliant listings.
* **Global Order Overrides**: Review platform-wide orders and override order states with administrative privilege.
* **Financial Analytics**: Interactive monthly GMV line charts and category breakdown charts powered by `fl_chart`.

---

## 🔄 Instant Role Switcher (Demo Mode)

To facilitate immediate testing across all three user experiences without tedious re-logins:
* An interactive **Role Switcher badge** is present in the app's top navigation bar and in the sidebar navigation drawer.
* Tap it to instantly toggle between **Customer**, **Seller**, and **Admin** personas.

---

## 🛠️ Technology Stack

| Technology | Purpose |
| :--- | :--- |
| **Flutter 3.47+ & Dart 3.13+** | Cross-platform UI toolkit |
| **GetX (`get`)** | Reactive state management, dependency injection, and routing |
| **Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`)** | Cloud persistence with graceful local reactive fallback |
| **Dio (`dio`)** | REST API networking and catalog synchronization |
| **fl_chart** | Modern interactive line and bar charts for Seller and Admin analytics |
| **Google Fonts** | Modern typography (`Plus Jakarta Sans`) |
| **flutter_rating_bar** | Interactive review ratings |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Unified modern color palette
│   │   ├── app_constants.dart     # Roles, order statuses, financial thresholds
│   │   └── app_theme.dart         # Material 3 light & dark theme configurations
│   ├── services/
│   │   ├── api_service.dart       # Dio HTTP REST client
│   │   ├── firebase_service.dart  # Firebase initialization & reactive fallback
│   │   └── storage_service.dart   # SharedPreferences persistence
│   └── utils/
│       ├── app_snackbar.dart      # Safe snackbar caller
│       ├── currency_formatter.dart# Standardized currency and date formatting
│       └── dummy_data.dart        # Rich seed data for instant testing
├── data/
│   └── models/
│       ├── cart_item_model.dart
│       ├── category_model.dart
│       ├── notification_model.dart
│       ├── order_model.dart
│       ├── product_model.dart
│       ├── review_model.dart
│       └── user_model.dart
├── controllers/
│   ├── admin_controller.dart
│   ├── auth_controller.dart
│   ├── cart_controller.dart
│   ├── notification_controller.dart
│   ├── order_controller.dart
│   ├── product_controller.dart
│   ├── review_controller.dart
│   ├── seller_controller.dart
│   └── wishlist_controller.dart
├── views/
│   ├── admin/                     # Dashboard, Users, Sellers, Products, Orders, Analytics
│   ├── auth/                      # Login, Registration
│   ├── common/                    # CustomButton, CustomTextField, ProductCard, AppDrawer
│   ├── customer/                  # Home, Search/Filter, Details, Cart, Checkout, Tracking, etc.
│   └── seller/                    # Dashboard, Inventory, Orders, Add/Edit Product, Sales
└── main.dart                      # App entrypoint and DI bootstrap
```

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure Flutter is installed on your system:
```bash
flutter --version
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

### 4. Launch Application
To run on your desired target:
```bash
# Web (Chrome)
flutter run -d chrome

# Desktop (Linux)
flutter run -d linux

# Connected Mobile Device / Emulator
flutter run
```

---

## 🔥 Firebase Configuration (Optional)

ShopNest automatically initializes with **graceful reactive local storage and mock collections**, allowing complete end-to-end functionality out of the box without requiring external credentials.

To connect your own live Firebase project:
1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Configure Firebase in the project:
   ```bash
   flutterfire configure
   ```
3. Set `FirebaseService.hasActiveFirebase = true` once your `firebase_options.dart` is in place.
