<?php

namespace App\Http\Controllers;

// use Illuminate\Http\Request;
use App\Models\ProductImage;
use App\Http\Requests\Product\ProductImageRequest;

class ProductImageController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return response()->json(ProductImage::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(ProductImageRequest $request)
    {
        $productImage = ProductImage::create([
            'image_path' => $request->image_path,
            'order' => $request->order,
            'product_id' => $request->product_id,
        ]);

        return response()->json([
            'message' => 'Product image created successfully!',
            'product_image' => $productImage
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(ProductImage $productImage)
    {
        return response()->json($productImage);
    }

    /**
     * Update the specified resource in storage.
     */
    // public function update(ProductImageRequest $request, string $id)
    // {
    //     //
    // }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ProductImage $productImage)
    {
        $productImage->delete();

        return response()->json([
            'message' => 'Product image deleted successfully!'
        ], 204);
    }
}
