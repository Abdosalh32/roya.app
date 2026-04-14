# Backend Implementation: Auto-Deactivate Products When Quantity is 0

## Overview

This document provides the backend code to automatically set `is_active = false` when a product's quantity is 0 or null. This rule should be enforced on **both mobile and backend** for data consistency.

---

## Implementation Files

### 1. Product Model (`app/Models/Product.php`)

Add this accessor/mutator to automatically handle the is_active field:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'shop_id',
        'category_id',
        'name_ar',
        'name_en',
        'description_ar',
        'description_en',
        'price',
        'compare_price',
        'is_active',
        'sort_order',
        'quantity',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'compare_price' => 'decimal:2',
        'is_active' => 'boolean',
        'quantity' => 'integer',
    ];

    /**
     * Boot method to register model events
     */
    protected static function boot()
    {
        parent::boot();

        // Auto-deactivate when quantity is 0 or null
        static::saving(function ($product) {
            if ($product->quantity === null || $product->quantity == 0) {
                $product->is_active = false;
            }
        });
    }

    /**
     * Scope to get only active products with stock
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
                     ->where('quantity', '>', 0);
    }

    /**
     * Check if product is in stock
     */
    public function getIsInStockAttribute()
    {
        return $this->quantity !== null && $this->quantity > 0;
    }
}
```

---

### 2. Product Controller (`app/Http/Controllers/Api/ShopOwner/ProductController.php`)

```php
<?php

namespace App\Http\Controllers\Api\ShopOwner;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;
use App\Models\Product;
use App\Http\Resources\ProductResource;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    /**
     * Store a newly created product
     */
    public function store(StoreProductRequest $request): JsonResponse
    {
        $validated = $request->validated();
        
        // Auto-deactivate if quantity is 0 or null
        if (!isset($validated['quantity']) || $validated['quantity'] == 0) {
            $validated['is_active'] = false;
        }
        
        $product = Product::create($validated);
        
        return response()->json([
            'status' => true,
            'message' => 'Product created successfully',
            'data' => new ProductResource($product),
        ], 201);
    }

    /**
     * Update the specified product
     */
    public function update(UpdateProductRequest $request, int $id): JsonResponse
    {
        $product = Product::findOrFail($id);
        
        $validated = $request->validated();
        
        // Auto-deactivate if quantity is being set to 0 or null
        if (isset($validated['quantity']) && $validated['quantity'] == 0) {
            $validated['is_active'] = false;
        }
        
        $product->update($validated);
        
        return response()->json([
            'status' => true,
            'message' => 'Product updated successfully',
            'data' => new ProductResource($product),
        ]);
    }

    /**
     * Toggle product active status
     * Prevents activation if quantity is 0
     */
    public function toggle(int $id): JsonResponse
    {
        $product = Product::findOrFail($id);
        
        // Don't allow activation if quantity is 0 or null
        if ($product->quantity === null || $product->quantity == 0) {
            return response()->json([
                'status' => false,
                'message' => 'Cannot activate product with zero quantity. Please update quantity first.',
                'data' => new ProductResource($product),
            ], 422);
        }
        
        $product->update([
            'is_active' => !$product->is_active,
        ]);
        
        return response()->json([
            'status' => true,
            'message' => 'Product status updated',
            'data' => new ProductResource($product),
        ]);
    }

    /**
     * Update product quantity and auto-adjust status
     */
    public function updateQuantity(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'quantity' => 'required|integer|min:0',
        ]);
        
        $product = Product::findOrFail($id);
        
        $product->update([
            'quantity' => $request->quantity,
            // Auto-deactivate if quantity is 0
            'is_active' => $request->quantity > 0 ? $product->is_active : false,
        ]);
        
        return response()->json([
            'status' => true,
            'message' => 'Quantity updated successfully',
            'data' => new ProductResource($product),
        ]);
    }
}
```

---

### 3. Form Request Validation (`app/Http/Requests/StoreProductRequest.php`)

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Authenticated shop owner
    }

    public function rules(): array
    {
        return [
            'category_id' => 'nullable|exists:categories,id',
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'description_en' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'compare_price' => 'nullable|numeric|min:0|gte:price',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer',
            'quantity' => 'nullable|integer|min:0',
        ];
    }

    public function messages(): array
    {
        return [
            'name_ar.required' => 'Arabic name is required',
            'name_en.required' => 'English name is required',
            'price.required' => 'Price is required',
            'price.numeric' => 'Price must be a number',
            'quantity.integer' => 'Quantity must be an integer',
            'quantity.min' => 'Quantity cannot be negative',
        ];
    }
}
```

---

### 4. Update Product Request (`app/Http/Requests/UpdateProductRequest.php`)

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Authenticated shop owner
    }

    public function rules(): array
    {
        return [
            'category_id' => 'nullable|exists:categories,id',
            'name_ar' => 'sometimes|required|string|max:255',
            'name_en' => 'sometimes|required|string|max:255',
            'description_ar' => 'nullable|string',
            'description_en' => 'nullable|string',
            'price' => 'sometimes|required|numeric|min:0',
            'compare_price' => 'nullable|numeric|min:0',
            'is_active' => 'sometimes|nullable|boolean',
            'sort_order' => 'sometimes|nullable|integer',
            'quantity' => 'nullable|integer|min:0',
        ];
    }
}
```

---

### 5. API Routes (`routes/api.php`)

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ShopOwner\ProductController;
use App\Http\Controllers\Api\ShopOwner\CategoryController;

Route::middleware('auth:api')->prefix('shop-owner')->group(function () {
    
    // Product routes
    Route::apiResource('products', ProductController::class)->except(['toggle']);
    Route::put('products/{id}/toggle', [ProductController::class, 'toggle']);
    Route::put('products/{id}/quantity', [ProductController::class, 'updateQuantity']);
    
    // Category routes
    Route::apiResource('categories', CategoryController::class);
    
});
```

---

### 6. Category Controller (Already exists, just verify)

```php
<?php

namespace App\Http\Controllers\Api\ShopOwner;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Category::where('shop_id', auth()->id())
            ->orderBy('sort_order')
            ->get();
            
        return response()->json([
            'status' => true,
            'data' => $categories,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
            'sort_order' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
        ]);
        
        $validated['shop_id'] = auth()->id();
        
        $category = Category::create($validated);
        
        return response()->json([
            'status' => true,
            'message' => 'Category created successfully',
            'data' => $category,
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $category = Category::findOrFail($id);
        
        $validated = $request->validate([
            'name_ar' => 'sometimes|required|string|max:255',
            'name_en' => 'sometimes|required|string|max:255',
            'sort_order' => 'nullable|integer',
            'is_active' => 'sometimes|boolean',
        ]);
        
        $category->update($validated);
        
        return response()->json([
            'status' => true,
            'message' => 'Category updated successfully',
            'data' => $category,
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $category = Category::findOrFail($id);
        $category->delete();
        
        return response()->json([
            'status' => true,
            'message' => 'Category deleted successfully',
        ]);
    }
}
```

---

### 7. Database Migration (if needed)

If you haven't added the quantity column yet:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->integer('quantity')->nullable()->after('is_active');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('quantity');
        });
    }
};
```

---

### 8. Product Resource (`app/Http/Resources/ProductResource.php`)

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'shop_id' => $this->shop_id,
            'category_id' => $this->category_id,
            'name_ar' => $this->name_ar,
            'name_en' => $this->name_en,
            'description_ar' => $this->description_ar,
            'description_en' => $this->description_en,
            'price' => $this->price,
            'compare_price' => $this->compare_price,
            'is_active' => (bool) $this->is_active,
            'sort_order' => $this->sort_order,
            'quantity' => $this->quantity,
            'is_in_stock' => $this->is_in_stock,
            'images' => ProductImageResource::collection($this->whenLoaded('images')),
            'variant_types' => ProductVariantTypeResource::collection($this->whenLoaded('variantTypes')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
```

---

## Business Logic Summary

### Rules Enforced:

1. **On Create:**
   - If `quantity` is null or 0 → `is_active` is forced to `false`
   - If `quantity` > 0 → `is_active` can be `true`

2. **On Update:**
   - If `quantity` is being set to 0 → `is_active` is forced to `false`
   - If `quantity` is being increased from 0 → `is_active` can be set to `true`

3. **On Toggle:**
   - If trying to activate (`is_active = true`) and `quantity == 0` → **Reject with error**
   - If `quantity > 0` → Allow toggle

4. **On Quantity Update:**
   - If new quantity is 0 → Auto-set `is_active = false`
   - If new quantity is > 0 → Keep current `is_active` status

---

## API Response Examples

### Create Product with Quantity = 0

**Request:**
```json
POST /api/shop-owner/products
{
  "name_ar": "Product Name",
  "name_en": "Product Name",
  "price": 50,
  "quantity": 0,
  "is_active": true
}
```

**Response:**
```json
{
  "status": true,
  "message": "Product created successfully",
  "data": {
    "id": 1,
    "name_ar": "Product Name",
    "name_en": "Product Name",
    "price": "50.00",
    "quantity": 0,
    "is_active": false  // ← Backend forced this to false
  }
}
```

### Toggle Product (Rejected due to 0 quantity)

**Request:**
```
PUT /api/shop-owner/products/1/toggle
```

**Response:**
```json
{
  "status": false,
  "message": "Cannot activate product with zero quantity. Please update quantity first.",
  "data": {
    "id": 1,
    "quantity": 0,
    "is_active": false
  }
}
```

---

## Testing Checklist

- [ ] Create product with quantity = 0 → should be inactive
- [ ] Create product with quantity = 10 → should be active
- [ ] Update product quantity from 10 to 0 → should become inactive
- [ ] Update product quantity from 0 to 5 → can be activated
- [ ] Try to toggle product with quantity = 0 → should reject
- [ ] Try to toggle product with quantity = 5 → should work
- [ ] Delete product → should work normally
- [ ] List products → should show correct is_active status

---

## Notes

1. **Mobile and Backend both enforce this rule** for data consistency
2. **Model `saving` event** ensures the rule is never bypassed
3. **Controller validation** provides immediate feedback
4. **Toggle endpoint** explicitly prevents activation when quantity is 0
5. **Error messages** are clear for mobile app to display to users

---

## Migration to Production

Run these commands after deploying:

```bash
# Run migration if adding quantity column
php artisan migrate

# Clear cache
php artisan cache:clear

# Optimize
php artisan optimize
```

---

## Questions?

Contact the mobile development team if you need clarification on the API contract or expected behavior.
