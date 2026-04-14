# Backend API Documentation: Shop Owner Profile Update

## Endpoint
```
PUT /api/shop-owner/profile
```

## Description
Allows shop owners to update their store profile information including store logo, banner, working hours, and operating days.

## Authentication
Requires shop-owner authentication via Bearer token.

## Request Format

### Content-Type
- For JSON data: `application/json`
- For file uploads (logo/banner): `multipart/form-data`

### Request Body

#### JSON Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name_ar` | string | Yes | Store name in Arabic |
| `name_en` | string | Yes | Store name in English |
| `description_ar` | string | No | Store description in Arabic |
| `description_en` | string | No | Store description in English |
| `open_time` | string | No | Opening time in HH:mm format (e.g., "09:00") |
| `close_time` | string | No | Closing time in HH:mm format (e.g., "18:00") |
| `working_days` | array | No | Array of working day codes: ["mon", "tue", "wed", "thu", "fri", "sat", "sun"] |

#### File Uploads (multipart/form-data)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `logo` | file | No | Store logo image (recommended: square image, max 500x500) |
| `banner` | file | No | Store banner image (recommended: wide image, max 1000x300) |

### Example Request Body (JSON)
```json
{
  "name_ar": "متجر الأزياء الحديثة",
  "name_en": "Modern Fashion Store",
  "description_ar": "متجر متخصص في الأزياء العصرية",
  "description_en": "Specialized in modern fashion",
  "open_time": "09:00",
  "close_time": "21:00",
  "working_days": ["sun", "mon", "tue", "wed", "thu"]
}
```

### Example Request (with files)
```
POST /api/shop-owner/profile
Content-Type: multipart/form-data

Fields:
- name_ar: "متجر الأزياء الحديثة"
- name_en: "Modern Fashion Store"
- open_time: "09:00"
- close_time: "21:00"
- working_days: ["sun", "mon", "tue", "wed", "thu"]
- logo: [File upload]
- banner: [File upload]
```

## Response Format

### Success Response (200 OK)
```json
{
  "status": true,
  "message": "تم تحديث الملف الشخصي بنجاح",
  "data": {
    "id": 1,
    "name_ar": "متجر الأزياء الحديثة",
    "name_en": "Modern Fashion Store",
    "description_ar": "متجر متخصص في الأزياء العصرية",
    "description_en": "Specialized in modern fashion",
    "logo_url": "https://example.com/uploads/logo_123.jpg",
    "banner_url": "https://example.com/uploads/banner_456.jpg",
    "open_time": "09:00",
    "close_time": "21:00",
    "working_days": ["sun", "mon", "tue", "wed", "thu"],
    "is_open": true
  }
}
```

### Error Responses

#### 400 Bad Request
```json
{
  "status": false,
  "message": "Validation error message"
}
```

#### 401 Unauthorized
```json
{
  "status": false,
  "message": "Unauthenticated."
}
```

#### 500 Internal Server Error
```json
{
  "status": false,
  "message": "Error message"
}
```

## Business Logic

### Open/Closed Status
- The `is_open` field is automatically calculated by the backend based on:
  - Current day of week
  - Current time
  - Store's `working_days`
  - Store's `open_time` and `close_time`
- Shop owners cannot manually set `is_open` - it's computed automatically

### Working Days
Valid values: `mon`, `tue`, `wed`, `thu`, `fri`, `sat`, `sun`

### Time Format
- Times must be in 24-hour format: `HH:mm`
- Examples: `"09:00"`, `"18:30"`, `"21:00"`

### Image Uploads
- Supported formats: JPEG, PNG, WebP
- Maximum file size: 5MB
- Images will be stored on the server and URLs returned
- Old images should be deleted when new ones are uploaded

## Backend Implementation Example (Laravel/PHP)

```php
public function update(Request $request)
{
    $shopOwner = Auth::user();
    
    // Validate request
    $validated = $request->validate([
        'name_ar' => 'required|string|max:255',
        'name_en' => 'required|string|max:255',
        'description_ar' => 'nullable|string',
        'description_en' => 'nullable|string',
        'open_time' => 'nullable|date_format:H:i',
        'close_time' => 'nullable|date_format:H:i',
        'working_days' => 'nullable|array',
        'working_days.*' => 'in:mon,tue,wed,thu,fri,sat,sun',
        'logo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
        'banner' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
    ]);
    
    // Handle file uploads
    if ($request->hasFile('logo')) {
        // Delete old logo
        if ($shopOwner->logo_url) {
            Storage::delete($shopOwner->logo_url);
        }
        $validated['logo_url'] = $request->file('logo')->store('shops/logos', 'public');
    }
    
    if ($request->hasFile('banner')) {
        // Delete old banner
        if ($shopOwner->banner_url) {
            Storage::delete($shopOwner->banner_url);
        }
        $validated['banner_url'] = $request->file('banner')->store('shops/banners', 'public');
    }
    
    // Update profile
    $shopOwner->update($validated);
    
    // Calculate is_open status
    $shopOwner->is_open = $this->calculateOpenStatus($shopOwner);
    $shopOwner->save();
    
    return response()->json([
        'status' => true,
        'message' => 'تم تحديث الملف الشخصي بنجاح',
        'data' => $shopOwner->fresh()
    ]);
}

private function calculateOpenStatus($shopOwner)
{
    if (!$shopOwner->open_time || !$shopOwner->close_time) {
        return false;
    }
    
    $now = now();
    $currentDay = strtolower($now->format('D')); // mon, tue, etc.
    $currentTime = $now->format('H:i');
    
    if (!in_array($currentDay, $shopOwner->working_days ?? [])) {
        return false;
    }
    
    return $currentTime >= $shopOwner->open_time && 
           $currentTime <= $shopOwner->close_time;
}
```

## Notes for Backend Developers
1. The endpoint should handle both JSON and multipart/form-data requests
2. File uploads are optional - only process if files are provided
3. Always return the complete updated shop model in the response
4. The `is_open` field should be auto-calculated, not manually settable
5. Store images securely and return full URLs
6. Consider implementing image optimization for uploaded files
7. Clean up old images when new ones are uploaded to save storage
