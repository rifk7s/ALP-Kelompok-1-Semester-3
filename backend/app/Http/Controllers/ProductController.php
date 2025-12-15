<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\Product;
use App\Models\ProductContribution;
use App\Models\ProductImage;
use App\Http\Requests\Product\CreateProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use Dedoc\Scramble\Attributes\Group;

#[Group('Products', 'Manajemen produk, kategori, gambar, dan kontribusi petani', weight: 30)]
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
        *
        * @requestMediaType multipart/form-data
     */
    public function store(CreateProductRequest $request)
    {
        // Determine harvest date - use first contributor's date or provided date or current date
        $harvestDate = $request->harvest_date;
        if (!$harvestDate && $request->has('petani_contributors') && is_array($request->petani_contributors) && count($request->petani_contributors) > 0) {
            $harvestDate = $request->petani_contributors[0]['harvest_date'] ?? now();
        }
        if (!$harvestDate) {
            $harvestDate = now();
        }
        
        // Create the product
        $product = Product::create([
            'name' => $request->name,
            'variety' => $request->variety,
            'harvest_date' => $harvestDate,
            'storage_days' => $request->storage_days,
            'price_per_kg' => $request->price_per_kg,
            'stock_kg' => $request->stock_kg,
            'sold_kg' => 0,
            'description' => $request->description,
            'status' => 'active',
            'category_id' => $request->category_id,
        ]);

        // Create product contribution(s)
        if ($request->has('petani_contributors') && is_array($request->petani_contributors)) {
            // Multiple petani contributors - FIFO order is preserved by array index
            foreach ($request->petani_contributors as $index => $contributor) {
                ProductContribution::create([
                    'product_id' => $product->id,
                    'petani_id' => $contributor['petani_id'],
                    'contributed_kg' => $contributor['contributed_kg'],
                    'remaining_kg' => $contributor['contributed_kg'],
                    'entry_date' => now()->addSeconds($index), // Add seconds to maintain FIFO order
                    'harvest_date' => $contributor['harvest_date'] ?? $request->harvest_date ?? now(),
                ]);
            }
        } elseif ($request->has('petani_id') && $request->petani_id) {
            // Backward compatibility - single petani
            ProductContribution::create([
                'product_id' => $product->id,
                'petani_id' => $request->petani_id,
                'contributed_kg' => $request->stock_kg,
                'remaining_kg' => $request->stock_kg,
                'entry_date' => now(),
                'harvest_date' => $request->harvest_date ?? now(),
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
        $product->load('category', 'productImages', 'productContributions.petani');
        return response()->json($product);
    }

    /**
     * Update the specified resource in storage.
        *
        * @requestMediaType multipart/form-data
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

        // Update product contributions if petani_contributors is provided
        if ($request->has('petani_contributors')) {
            // Delete existing contributions
            ProductContribution::where('product_id', $product->id)->delete();
            
            // Create new contributions with FIFO ordering
            $contributors = $request->input('petani_contributors');
            $baseDate = \Carbon\Carbon::parse($request->harvest_date ?? $product->harvest_date);
            
            foreach ($contributors as $index => $contributor) {
                // Add seconds to ensure FIFO order even on same harvest date
                $entryDate = $baseDate->copy()->addSeconds($index);
                
                ProductContribution::create([
                    'product_id' => $product->id,
                    'petani_id' => $contributor['petani_id'],
                    'contributed_kg' => $contributor['contributed_kg'],
                    'remaining_kg' => $contributor['contributed_kg'],
                    'entry_date' => $entryDate,
                    'harvest_date' => $request->harvest_date ?? $product->harvest_date,
                ]);
            }
        } elseif ($request->has('petani_id') && $request->petani_id) {
            // Backward compatibility - Update product contribution if petani_id is provided
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
