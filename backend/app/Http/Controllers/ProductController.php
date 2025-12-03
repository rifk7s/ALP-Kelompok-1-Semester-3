<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
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
        $query = Product::with('category', 'productImages');

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
        // $product = Product::create($request->all());
        $product = Product::create([
            'name' => $request->name,
            'variety' => $request->variety,
            'harvest_date' => $request->harvest_date,
            'storage_days' => $request->storage_days,
            'price_per_kg' => $request->price_per_kg,
            'stock_kg' => $request->stock_kg,
            'sold_kg' => $request->sold_kg,
            'description' => $request->description,
            'status' => 'active',
            'category_id' => $request->category_id,
        ]);

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
