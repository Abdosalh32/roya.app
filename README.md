# 🚗 Roya Future — Driver App

A Flutter application for Roya Future driver partners. Built for two driver types:
- Collector: Picks up orders from shops and delivers them to the warehouse.
- Distributor: Picks up from the warehouse and delivers to the customer.

Developed by Arowwai Industries — 2026.

---

## 📱 Tech Stack

| Layer              | Technology                          |
|--------------------|-------------------------------------|
| Framework          | Flutter (Dart)                      |
| State Management   | GetX (Controllers + Bindings)       |
| Navigation         | GetX Named Routes (GetMaterialApp)  |
| HTTP Client        | Dio (with Interceptors)             |
| Local Database     | SQLite (sqflite)                    |
| Secure Storage     | flutter_secure_storage              |
| Push Notifications | Firebase Cloud Messaging (FCM)      |
| Location           | Geolocator                          |
| Maps               | Google Maps Flutter                 |
| Code Generation    | json_serializable, build_runner     |

---

## 🏗 Architecture

The project follows a Feature-Based Clean Architecture with GetX:

lib/
├── core/
│ ├── api/ # Dio client, interceptors, base URLs
│ ├── db/ # SQLite helper (sqflite)
│ ├── routes/ # GetX named routes & route management
│ ├── services/ # AuthService, StorageService, FCMService
│ ├── theme/ # App theme, colors, text styles
│ └── utils/ # Constants, helpers, extensions
│
├── features/
│ ├── auth/
│ │ ├── models/ # UserModel, DriverModel
│ │ ├── controllers/ # AuthController (GetxController)
│ │ ├── bindings/ # AuthBinding
│ │ ├── repositories/ # AuthRepository
│ │ └── screens/ # LoginScreen
│ │
│ ├── orders/
│ │ ├── models/ # OrderModel, SubOrderModel, OrderStatusLog
│ │ ├── controllers/ # OrdersController, OrderDetailController
│ │ ├── bindings/ # OrdersBinding
│ │ ├── repositories/ # OrdersRepository
│ │ └── screens/ # NewOrdersScreen, OngoingScreen, HistoryScreen
│ │ OrderDetailScreen, StatusUpdateScreen
│ │
│ ├── custody/ # Distributor only
│ │ ├── models/ # CustodyModel, CustodyTransaction
│ │ ├── controllers/ # CustodyController
│ │ ├── bindings/ # CustodyBinding
│ │ ├── repositories/ # CustodyRepository
│ │ └── screens/ # CustodyScreen
│ │
│ ├── notifications/
│ │ ├── models/ # NotificationModel
│ │ ├── controllers/ # NotificationController
│ │ └── screens/ # NotificationsScreen
│ │
│ └── profile/
│ ├── models/ # ProfileModel
│ ├── controllers/ # ProfileController
│ ├── bindings/ # ProfileBinding
│ └── screens/ # ProfileScreen
│
└── shared/
├── widgets/ # Shared UI components (buttons, cards, loaders)
└── models/ # Shared models (ApiResponse, PaginatedResponse)

text

---

## 👤 Driver Types & Roles

The system has two distinct driver roles with different responsibilities and API scopes:

### 🔵 Collector Driver
Assigned to specific Malls/Streets (`collector_driver_malls` table).

| Step | Action | Order Status |
|------|--------|--------------|
| 1 | Receives assignment notification | collector_assigned |
| 2 | Heads to the shop | Updates to driver_to_store |
| 3 | Picks up items from shop | Updates to picked_up |
| 4 | Delivers to warehouse | Warehouse staff confirms at_warehouse |

### 🟠 Distributor Driver
Assigned to Regions (`distributor_driver_regions` table). Handles cash-on-delivery.

| Step | Action | Order Status |
|------|--------|--------------|
| 1 | Receives assignment notification | distributor_assigned |
| 2 | Heads to warehouse to pick up | Updates to on_the_way |
| 3 | Delivers to customer (collects cash) | Updates to delivered |
| 4 | Cash logged in daily custody | — |

---

## 🗺 Order Flow (Full 11 Stages)

submitted → pending → confirmed → accepted
→ collector_assigned → driver_to_store → picked_up
→ at_warehouse → distributor_assigned
→ on_the_way → delivered

text

> Driver can also see rejected and auto_cancelled for historical orders.

---

## 📡 API Endpoints Used

Base URL: https://your-domain.com/api/v1
### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/driver/login | Driver login (returns Sanctum token) |
| POST | /auth/logout | Logout & invalidate token |

### Orders (Both Driver Types)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /driver/orders | Get assigned/active orders |
| GET | /driver/orders/{id} | Get order detail |
| PUT | /driver/orders/{id}/status | Update order status |
| GET | /driver/history | Completed orders history |

### Custody (Distributor Only)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /driver/custody | View daily cash custody |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /notifications | List notifications |

---

## ✨ Features

### Auth
- [x] Phone + password login
- [x] Token saved securely via flutter_secure_storage
- [x] Auto-login on app relaunch
- [x] Logout with token invalidation
- [x] FCM token registration on login

### Orders
- [x] New Orders tab — orders assigned to the driver
- [x] Ongoing tab — orders in progress
- [x] History tab — completed/rejected orders
- [x] Order detail view (items, shop, customer address, sub-orders)
- [x] One-tap status update with confirmation dialog
- [x] Real-time FCM push notifications on new assignment

### Collector-Specific
- [x] View shop location and mall details
- [x] Update status: driver_to_store → picked_up

### Distributor-Specific
- [x] View customer delivery address and region
- [x] Update status: on_the_way → delivered
- [x] Cash custody tracking (daily collected amounts)
- [x] Custody history and balance summary

### Profile
- [x] View profile (name, vehicle type, plate number, driver type)
- [x] Availability toggle (`is_available`)
- [x] App version & settings

### Notifications
- [x] In-app notification list
- [x] Mark as read
- [x] FCM background & foreground handling

---

## 📦 GetX Architecture Pattern

Each feature follows this pattern:

```dart
// 1. Controller
class OrdersController extends GetxController {
  final OrdersRepository _repo;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  OrdersController(this._repo);

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async { ... }
  Future<void> updateStatus(int orderId, String status) async { ... }
}

// 2. Binding
class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrdersRepository(Get.find()));
    Get.lazyPut(() => OrdersController(Get.find()));
  }
}

// 3. Route
GetPage(
  name: Routes.orders,
  page: () => const OrdersScreen(),
  binding: OrdersBinding(),
)
🔐 Authentication Flow
text
App Launch
    │
    ▼
AuthService.init()
    │
    ├── Token found? ──Yes──► Validate with API ──Valid──► Home
    │                                             │
    │                                           Invalid──► Login
    └── No token ──────────────────────────────────────► Login