<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ProductContribution;
use App\Http\Requests\Product\ProductContributionRequest;
use App\Http\Requests\Product\UpdateProductContributionRequest; 

class ProductContributionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $query = ProductContribution::with('product', 'petani');
        return response()->json($query->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(ProductContributionRequest $request)
    {
        $contribution = ProductContribution::create([
            'contributed_kg' => $request->contributed_kg,
            'remaining_kg' => $request->remaining_kg,
            'entry_date' => $request->entry_date,
            'harvest_date' => $request->harvest_date,
            'product_id' => $request->product_id,
            'petani_id' => $request->petani_id,
        ]);

        return response()->json([
            'message' => 'Product contribution created successfully!',
            'category' => $contribution
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(ProductContribution $contribution)
    {
        // $productContribution->load('product', 'petani');
        // return response()->json($productContribution);

        // $productContribution = ProductContribution::with('product', 'petani')
        // ->findOrFail($productContribution->id);
    
        // return response()->json($productContribution);

        // return response()->json($productContribution->load('product', 'petani'));

        // return response()->json($productContribution);

        return response()->json(
            ProductContribution::with('product', 'petani')->findOrFail($contribution->id)
        );
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateProductContributionRequest $request, ProductContribution $contribution)
    {
        $contribution->update([
            'contributed_kg' => $request->contributed_kg ?? $contribution->contributed_kg,
            'remaining_kg' => $request->remaining_kg ?? $contribution->remaining_kg,
            'entry_date' => $request->entry_date ?? $contribution->entry_date,
            'harvest_date' => $request->harvest_date ?? $contribution->harvest_date,
            'product_id' => $request->product_id ?? $contribution->product_id,
            'petani_id' => $request->petani_id ?? $contribution->petani_id
        ]);

        return response()->json([
            'message' => 'Product Contribution updated successfully!',
            'product_contribution' => $contribution
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ProductContribution $contribution)
    {
        $contribution->delete();

        return response()->json([
            'message' => 'Product Contribution deleted successfully!'
        ], 204);
    }
}
