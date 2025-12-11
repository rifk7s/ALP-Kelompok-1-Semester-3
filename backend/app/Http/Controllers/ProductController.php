<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\Product;
use App\Models\ProductContribution;
use App\Models\ProductImage;
use App\Http\Requests\Product\CreateProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // return response()->json(Product::all());
        // return response()->json(Product::with('category', 'productImages')->get());
        $query = Product::with('category', 'productImages', 'productContributions.petani');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        return response()->json($query->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CreateProductRequest $request)
    {
        // Create the product
        $product = Product::create([
            'name' => $request->name,
            'variety' => $request->variety,
            'harvest_date' => $request->harvest_date,
            'storage_days' => $request->storage_days,
            'price_per_kg' => $request->price_per_kg,
            'stock_kg' => $request->stock_kg,
            'sold_kg' => 0,
            'description' => $request->description,
            'status' => 'active',
            'category_id' => $request->category_id,
        ]);

        // Create product contribution if petani_id is provided
        if ($request->has('petani_id') && $request->petani_id) {
            ProductContribution::create([
                'product_id' => $product->id,
                'petani_id' => $request->petani_id,
                'contributed_kg' => $request->stock_kg,
                'remaining_kg' => $request->stock_kg,
                'entry_date' => now(),
                'harvest_date' => $request->harvest_date,
            ]);
        }

        // Handle image uploads
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('products', 'public');
                ProductImage::create([
                    'product_id' => $product->id,
                    'image_path' => 'storage/' . $path,
                    'order' => $index,
                ]);
            }
        }

        // Load relationships for response
        $product->load('category', 'productImages', 'productContributions.petani');

        return response()->json([
            'message' => 'Product created successfully!',
            'product' => $product
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Product $product)
    {
        $product->load('category', 'productImages');
        return response()->json($product);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateProductRequest $request, Product $product)
    {
        $product -> update([
            'name' => $request->name ?? $product->name,
            'variety' => $request->variety ?? $product->variety,
            'harvest_date' => $request->harvest_date ?? $product->harvest_date,
            'storage_days' => $request->storage_days ?? $product->storage_days,
            'price_per_kg' => $request->price_per_kg ?? $product->price_per_kg,
            'stock_kg' => $request->stock_kg ?? $product->stock_kg,
            'sold_kg' => $request->sold_kg ?? $product->sold_kg,
            'description' => $request->description ?? $product->description,
            'status' => $request->status ?? $product->status,
            'category_id' => $request->category_id ?? $product->category_id,
        ]);

        // Update product contribution if petani_id is provided
        if ($request->has('petani_id') && $request->petani_id) {
            // Find existing contribution or create new one
            $contribution = ProductContribution::where('product_id', $product->id)->first();
            
            if ($contribution) {
                // Update existing contribution
                $contribution->update([
                    'petani_id' => $request->petani_id,
                    'contributed_kg' => $request->stock_kg ?? $contribution->contributed_kg,
                    'remaining_kg' => $request->stock_kg ?? $contribution->remaining_kg,
                    'harvest_date' => $request->harvest_date ?? $contribution->harvest_date,
                ]);
            } else {
                // Create new contribution if none exists
                ProductContribution::create([
                    'product_id' => $product->id,
                    'petani_id' => $request->petani_id,
                    'contributed_kg' => $request->stock_kg ?? $product->stock_kg,
                    'remaining_kg' => $request->stock_kg ?? $product->stock_kg,
                    'entry_date' => now(),
                    'harvest_date' => $request->harvest_date ?? $product->harvest_date,
                ]);
            }
        }

        // Handle image deletions
        if ($request->has('delete_image_ids')) {
            $imageIds = $request->input('delete_image_ids');
            foreach ($imageIds as $imageId) {
                $image = ProductImage::where('product_id', $product->id)
                    ->where('id', $imageId)
                    ->first();
                
                if ($image) {
                    // Delete file from storage
                    $filePath = str_replace('storage/', '', $image->image_path);
                    Storage::disk('public')->delete($filePath);
                    
                    // Delete database record
                    $image->delete();
                }
            }
        }

        // Handle new image uploads
        if ($request->hasFile('images')) {
            // Get current max order
            $maxOrder = ProductImage::where('product_id', $product->id)->max('order') ?? -1;
            
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('products', 'public');
                ProductImage::create([
                    'product_id' => $product->id,
                    'image_path' => 'storage/' . $path,
                    'order' => $maxOrder + $index + 1,
                ]);
            }
        }

        // Load relationships for response
        $product->load('category', 'productImages', 'productContributions.petani');

        return response()->json([
            'message' => 'Product updated successfully!',
            'product' => $product
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json([
            'message' => 'Product deleted successfully!'
        ], 204);

    }
}
