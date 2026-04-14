# Add `quantity` (stock) field to Shop-Owner Product APIs

## Overview

Per the API handoff (`BACKEND_API_HANDOFF_SHOP_OWNER.md`), product payloads currently lack a `quantity` (stock) field. Please add support for a `quantity` integer field across all relevant product endpoints.

**Note:** The Flutter frontend (models and UI) has already been updated to send and receive the `quantity` field.

## Endpoints to Update

- **Create Product:** `POST /api/shop-owner/products` — accept `quantity` in request body (integer, >=0).
- **Update Product:** `PUT /api/shop-owner/products/{id}` — accept `quantity` in request body.
- **List Products:** `GET /api/shop-owner/products` — include `quantity` in the response payload.
- **Get Product:** `GET /api/shop-owner/products/{id}` — include `quantity` in the response payload.

## Backend Implementation Checklist

- [ ] **Database Migration:** Add a `quantity` integer column (default `0`) to the `products` table.
- [ ] **Validation:** Update form requests/validators to ensure `quantity` is an integer and `>= 0`.
- [ ] **API Resources/Transformers:** Include `quantity` in all product json responses (e.g., `ProductResource`).
- [ ] **Controllers:** Update the `store` and `update` methods to accept and persist the `quantity` field.
- [ ] **Backwards Compatibility:** If omitted in a create request, default to `0`. If omitted in an update request, leave the existing value unchanged.
- [ ] **Postman/Docs:** Update the Postman collection and/or Swagger documentation to reflect the new field.
