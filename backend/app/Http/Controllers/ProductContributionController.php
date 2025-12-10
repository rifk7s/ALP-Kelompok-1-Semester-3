<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ProductContribution;
use App\Http\Requests\Product\ProductContributionRequest;

class ProductContributionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = ProductContribution::with('product', 'petani_data');
        return response()->json($query->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(ProductContributionRequest $request)
    {
        $productContribution = ProductContribution::create([
            'contributed_kg' => $request->contributed_kg,
            'remaining_kg' => $request->remaining_kg,
            'entry_date' => $request->entry_date,
            'harvest_date' => $request->harvest_date,
            'product_id' => $request->product_id,
            'petani_id' => $request->petani_id,
        ]);

        return response()->json([
            'message' => 'Category created successfully!',
            'category' => $productContribution
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(ProductContribution $productContribution)
    {
        $productContribution->load('product', 'petani_data');
        return response()->json($productContribution);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(ProductContributionRequest $request, ProductContribution $productContribution)
    {
        $productContribution->update([
            'contributed_kg' => $request->contributed_kg ?? $productContribution->contributed_kg,
            'remaining_kg' => $request->remaining_kg ?? $productContribution->remaining_kg,
            'entry_date' => $request->entry_date ?? $productContribution->entry_date,
            'harvest_date' => $request->harvest_date ?? $productContribution->harvest_date,
            'product_id' => $request->product_id ?? $productContribution->product_id,
            'petani_id' => $request->petani_id ?? $productContribution
        ]);

        return response()->json([
            'message' => 'Product Contribution updated successfully!',
            'product_contribution' => $productContribution
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ProductContribution $productContribution)
    {
        $productContribution->delete();

        return response()->json([
            'message' => 'Product Contribution deleted successfully!'
        ], 204);
    }
}
