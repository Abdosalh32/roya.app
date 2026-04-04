# Backend API Handoff for Shop Owner Mobile App

## Scope

This document defines the API contract required by the Flutter shop-owner app for:

- Auth (shop-owner)
- Products tab
- Categories
- Product variants
- Product images

Base URL from Postman: `{{baseUrl}}`
Current app integration paths use: `/api/shop-owner/*` and `/api/auth/shop-owner/*`

## 1) Auth APIs (Required)

### 1.1 Login

- Method: `POST`
- Path: `/api/auth/shop-owner/login`
- Content-Type: `application/json`
- Body:

```json
{
  "phone": "091xxxxxxx",
  "password": "secret",
  "fcm_token": "optional-token"
}
```

- Success response (expected):

```json
{
  "status": true,
  "message": "Logged in successfully",
  "data": {
    "token": "jwt-or-sanctum-token",
    "user": {
      "id": 1,
      "name": "Shop Owner",
      "phone": "091xxxxxxx",
      "shop": {
        "id": 10,
        "name": "Store Name",
        "logo": "https://..."
      }
    }
  }
}
```

- Notes:
  - App can also parse `access_token` instead of `token`.
  - Returns should include user + shop information.

### 1.2 Logout

- Method: `POST`
- Path: `/api/auth/shop-owner/logout`
- Headers: `Authorization: Bearer <token>`
- Body: none
- Success: `200` with `{ "message": "Logged out" }`

### 1.3 Refresh Token

- Method: `POST`
- Path: `/api/auth/shop-owner/refresh`
- Headers: `Authorization: Bearer <token>`
- Body: none
- Success: same shape as login token payload

## 2) Products APIs (Required)

### 2.1 List Products

- Method: `GET`
- Path: `/api/shop-owner/products`
- Headers: `Authorization: Bearer <token>`
- Success response:

```json
{
  "data": [
    {
      "id": 1,
      "shop_id": 10,
      "category_id": 5,
      "name_ar": "قميص",
      "name_en": "Shirt",
      "description_ar": "...",
      "description_en": "...",
      "price": "39.00",
      "compare_price": "49.00",
      "is_active": true,
      "sort_order": 1,
      "images": [
        {
          "id": 100,
          "product_id": 1,
          "image_url": "https://...",
          "sort_order": 0,
          "is_primary": true
        }
      ],
      "variant_types": [
        {
          "id": 77,
          "product_id": 1,
          "name_ar": "المقاس",
          "name_en": "Size",
          "sort_order": 0,
          "options": [
            {
              "id": 1001,
              "type_id": 77,
              "value_ar": "صغير",
              "value_en": "S",
              "extra_price": "0.00",
              "is_active": true,
              "sort_order": 0
            }
          ]
        }
      ]
    }
  ]
}
```

### 2.2 Get Product by ID

- Method: `GET`
- Path: `/api/shop-owner/products/{id}`
- Success: same product object shape

### 2.3 Create Product

- Method: `POST`
- Path: `/api/shop-owner/products`
- Content-Type: `application/json`
- Body:

```json
{
  "category_id": 5,
  "name_ar": "اسم",
  "name_en": "Name",
  "description_ar": "optional",
  "description_en": "optional",
  "price": 39,
  "compare_price": 49,
  "is_active": true,
  "sort_order": 0,
  "images": [
    { "image_url": "https://...", "sort_order": 0, "is_primary": true }
  ]
}
```

- Success: returns created product in `data`

### 2.4 Update Product

- Method: `PUT`
- Path: `/api/shop-owner/products/{id}`
- Content-Type: `application/json`
- Body: same fields as create (partial or full)
- Success: returns updated product in `data`

### 2.5 Delete Product

- Method: `DELETE`
- Path: `/api/shop-owner/products/{id}`
- Success: `200` with message

### 2.6 Toggle Product Active

- Method: `PUT`
- Path: `/api/shop-owner/products/{id}/toggle`
- Body: none
- Success: returns new status or updated product

## 3) Categories APIs (Required)

### 3.1 List Categories

- Method: `GET`
- Path: `/api/shop-owner/categories`

### 3.2 Create Category

- Method: `POST`
- Path: `/api/shop-owner/categories`
- Body:

```json
{
  "name_ar": "قمصان",
  "name_en": "Shirts",
  "sort_order": 0,
  "is_active": true
}
```

### 3.3 Update Category

- Method: `PUT`
- Path: `/api/shop-owner/categories/{id}`
- Body:

```json
{
  "name_ar": "قمصان",
  "name_en": "Shirts",
  "sort_order": 0,
  "is_active": true
}
```

### 3.4 Delete Category

- Method: `DELETE`
- Path: `/api/shop-owner/categories/{id}`

## 4) Variant APIs (From Postman, required for full feature)

### 4.1 Create Variant Type

- Method: `POST`
- Path: `/api/shop-owner/products/{id}/variant-types`
- Body:

```json
{
  "name_ar": "المقاس",
  "name_en": "Size",
  "sort_order": 0
}
```

### 4.2 Create Variant Option

- Method: `POST`
- Path: `/api/shop-owner/variant-types/{typeId}/options`
- Body:

```json
{
  "value_ar": "صغير",
  "value_en": "S",
  "extra_price": 0,
  "is_active": true,
  "sort_order": 0
}
```

## 5) Missing APIs Needed by Mobile UX

These are not clearly available in the Postman collection but needed for the current mobile requirements.

### 5.1 Image Upload API (Missing)

Mobile picks local files, but product create/update currently expects image URLs.

Proposed endpoint:

- Method: `POST`
- Path: `/api/shop-owner/uploads/images`
- Content-Type: `multipart/form-data`
- Body:
  - `files[]`: image files
- Success:

```json
{
  "data": [
    { "url": "https://cdn.../img1.jpg" },
    { "url": "https://cdn.../img2.jpg" }
  ]
}
```

### 5.2 Delete Product Image (Missing)

- Method: `DELETE`
- Path: `/api/shop-owner/products/{productId}/images/{imageId}`
- Success: `200`

### 5.3 Set Primary Product Image (Missing)

- Method: `PUT`
- Path: `/api/shop-owner/products/{productId}/images/{imageId}/primary`
- Body: none

### 5.4 Reorder Product Images (Missing)

- Method: `PUT`
- Path: `/api/shop-owner/products/{productId}/images/reorder`
- Body:

```json
{
  "items": [
    { "image_id": 100, "sort_order": 0 },
    { "image_id": 101, "sort_order": 1 }
  ]
}
```

### 5.5 Variant Type Update/Delete (Missing)

- Update:
  - Method: `PUT`
  - Path: `/api/shop-owner/variant-types/{typeId}`
- Delete:
  - Method: `DELETE`
  - Path: `/api/shop-owner/variant-types/{typeId}`

### 5.6 Variant Option Update/Delete (Missing)

- Update:
  - Method: `PUT`
  - Path: `/api/shop-owner/variant-options/{optionId}`
- Delete:
  - Method: `DELETE`
  - Path: `/api/shop-owner/variant-options/{optionId}`

## 6) Standard Error Contract (Recommended)

Use this across all endpoints for consistency:

```json
{
  "message": "Validation error",
  "errors": {
    "name_ar": ["The name ar field is required."]
  }
}
```

Recommended status codes:

- `401` unauthenticated
- `403` forbidden
- `404` not found
- `422` validation
- `500` server error

## 7) Notes for Backend Team

- Protect all `/api/shop-owner/*` endpoints with shop-owner auth guard.
- Return `data` wrapper consistently.
- Keep numeric fields as number or numeric string consistently (mobile parses both).
- Include nested `images` and `variant_types.options` in products list/detail to avoid extra roundtrips.
