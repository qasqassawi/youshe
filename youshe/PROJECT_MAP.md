# PROJECT_MAP — Youshe

## [TECH_STACK]
- **Flutter** 3.44.2 / **Dart** 3.12.2
- **Firebase**: Auth 6.5.3, Firestore 6.6.0, Storage 13.4.3, FCM 16.4.0 (FlutterFire BoM 4.15.0)
- **Google Sign-In**: google_sign_in 6.3.0
- **Cloud Functions**: Node.js 20 / firebase-admin 14.0.0 / firebase-functions 6.x
- **State**: Provider 6.1.5+1
- **Routing**: GoRouter 17.3.0
- **Localization**: flutter_localizations + manual AppLocalizations (ARB-free)
- **Notifications**: flutter_local_notifications 22.0.1
- **Image handling**: cached_network_image 3.4.1, image_picker 1.2.2

## [SYSTEM_FLOW]

### Customer Journey
```
Launch → Login/Register → Browse Shops (sorted by fulfillmentRate DESC)
                        → Filter by category
                        → View Shop + Products (grid)
                        → View Product Detail (images, price, sizes, qty)
                        → Add to Cart → Checkout (delivery address, phone, notes)
                        → Order Placed (status=pending)
                             ├─ Confirmed (status=confirmed) → Track
                             └─ Cancelled (status=cancelled) → Similar Items from other shops
```

### Shop Owner Journey
```
Launch → Login (existing admin account) → Dashboard (stats: orders, products, fulfillment rate)
                                        → My Shop (create/edit shop profile: name Ar/En, category, city, images)
                                        → My Products (list, add, edit, delete with images)
                                        → Incoming Orders (list, detail, confirm/cancel within 2h)
                                        → Fulfillment Rate auto-calculates after each order
```

### Auto-Cancel Flow
```
Order created (status=pending, createdAt=timestamp)
  → Cloud Functions scheduler (every 5 min)
  → Queries orders: status=pending AND createdAt < now - 2h
  → Sets status=cancelled, autoCancelled=true
  → Recalculates shop fulfillmentRate
  → Sends FCM to customer: "Auto-cancelled — similar items available"
```

### Fulfillment Rate Flow
```
Order status changes (confirmed | cancelled | delivered | completed)
  → Firestore onWrite trigger (Cloud Function)
  → Counts shop orders: successful (confirmed/delivered/completed) / total
  → Updates shop.fulfillmentRate, totalOrders, successfulOrders
  → Client sees live rate via Firestore snapshot listener
```

## [ARCHITECTURE]

```
lib/
├── main.dart                          # Entry: Firebase init, MultiProvider, runApp
├── app.dart                           # MaterialApp.router with GoRouter, l10n, theme
├── core/
│   ├── constants.dart                 # AppConstants, FirestoreCollections, enums
│   ├── theme.dart                     # AppTheme (colors, typography, theme data)
│   ├── router.dart                    # GoRouter config (auth/role guards, 17 routes)
│   └── services/
│       ├── auth_service.dart          # FirebaseAuth + Firestore role persistence
│       ├── firestore_service.dart     # Thin generic CRUD wrapper (add/set/update/get/delete)
│       ├── storage_service.dart       # Firebase Storage upload (product/shop images)
│       ├── notification_service.dart  # FCM init, token, foreground/background handlers
│       └── logging_service.dart       # Simple logger (error/warn/info/debug)
├── models/
│   ├── user_model.dart                # User with role field
│   ├── shop_model.dart                # Shop with bilingual names + fulfillmentRate
│   ├── product_model.dart             # Product with bilingual names + images/sizes
│   └── order_model.dart               # Order + OrderItem with bilingual display
├── features/
│   ├── auth/                          # Login, Register screens + AuthProvider
│   ├── customer/                      # Home, ShopList, ShopDetail, ProductDetail, Cart,
│   │                                    Checkout, OrderTracking, SimilarItems screens + providers
│   ├── shop_owner/                    # Dashboard, ProductForm, OrderManagement, OrderDetail,
│   │                                    ShopProfile screens + providers
│   └── shared/widgets/                # ProductCard, ShopCard, OrderStatusBadge, LoadingWidget
└── l10n/app_localizations.dart        # 90+ keys in English + Arabic, locale-aware lookup

functions/
├── package.json / tsconfig.json
└── src/index.ts                       # 3 Cloud Functions:
       ├── onOrderUpdate     → fulfillment rate recalculation trigger
       ├── onOrderCreate     → FCM push to shop owner
       └── autoCancelOrders  → scheduled (every 5min) auto-cancel of stale orders
```

### Firebase Data Model

| Collection | Key Fields |
|---|---|
| `users/{uid}` | email, name, role, phone, fcmToken, createdAt |
| `shops/{shopId}` | ownerId, nameEn, nameAr, descEn, descAr, logoUrl, coverUrl, category, city, phone, fulfillmentRate, totalOrders, successfulOrders, isActive |
| `products/{productId}` | shopId, nameEn, nameAr, descEn, descAr, price, currency, sizes[], category, images[], isAvailable |
| `orders/{orderId}` | customerId, shopId, items[{productId, nameEn, nameAr, qty, price, size}], totalAmount, status, deliveryAddress, customerPhone, customerName, customerNotes, respondedAt, autoCancelled, cancellationReason |

### Required Firestore Composite Indexes
1. `orders`: `shopId` ASC, `createdAt` DESC
2. `orders`: `customerId` ASC, `createdAt` DESC
3. `orders`: `status` ASC, `createdAt` ASC (auto-cancel query)
4. `products`: `shopId` ASC, `isAvailable` ASC
5. `products`: `category` ASC, `isAvailable` ASC (similar items query)
6. `shops`: `fulfillmentRate` DESC (search ranking)

## [VERIFIABLE_GOALS]

| # | Status | Goal |
|---|---|---|
| G1 | ✅ | User registers as customer by default; no role selection step; shop owners with existing admin accounts are redirected to dashboard on login |
| G2 | ✅ | Shop owner creates shop profile (Ar/En), adds products with images |
| G3 | ✅ | Customer browses shops sorted by fulfillmentRate, filters by category |
| G4 | ✅ | Customer places COD order → saved in Firestore with status=pending |
| G5 | ✅ | Shop owner receives FCM notification on order (Cloud Function) |
| G6 | ✅ | Shop owner confirms or cancels order → fulfillmentRate recalculated |
| G7 | ✅ | Orders pending >2h auto-cancel via scheduled Cloud Function |
| G8 | ✅ | Auto-cancelled order triggers FCM + similar items screen with category filter |
| G9 | ✅ | All UI strings in Arabic + English; locale detected from device |

## [ORPHANS_AND_PENDING]

- [PENDING] Firebase project setup — needs `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [PENDING] Cloud Functions deployment — needs `firebase init`, `firebase deploy`
- [PENDING] iOS FCM/APNS certificate setup for push notifications
- [PENDING] `flutter analyze` shows 61 info-level hints (style/withOpacity-deprecation) — non-blocking
- [PENDING] Language switcher UI in settings (manual `_setLocale` exists but not wired to UI)
- [PENDING] Product image upload compression strategy (currently uses raw image_picker output)
- [PENDING] Offline/error UX polish (Firestore offline persistence is default but no explicit retry UI beyond "Try again")
- [PENDING] Phone auth (SMS) for Jordan (+962)
- [PENDING] FCM token stored in Firestore user document (currently retrieved but not persisted)
- [PENDING] Arabic number formatting (Eastern Arabic numerals vs Western)
- [PENDING] Test coverage (widget test placeholder only)
- [DONE] Role selection removed from registration; users register as customers by default. Shop owners with admin accounts (role=shop_owner in Firestore) are redirected to dashboard on login. Login screen shows an informational hint for shop owners.
- [DONE] Google Sign-In and Anonymous Sign-In added. `_ensureUserDoc()` helper in `auth_service.dart` creates Firestore user doc on first sign-in (role=customer). Login screen has "Sign in with Google" button and "Continue as Guest" button after the OR divider.
