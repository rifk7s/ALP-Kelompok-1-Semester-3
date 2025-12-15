<?php

namespace App\Http\Controllers;

use Dedoc\Scramble\Attributes\Group;
use App\Models\PetaniData;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

#[Group('Petani Data', 'Manajemen data petani (akses BUMDes)', weight: 80)]
class PetaniDataController extends Controller
{
    /**
     * Display a listing of petani data.
     * Only BUMDes can access this.
     */
    public function index(Request $request)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized. Only BUMDes can access this.'], 403);
        }

        $petaniData = PetaniData::orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'message' => 'Petani data retrieved successfully',
            'data' => $petaniData
        ]);
    }

    /**
     * Store a newly created petani data.
     */
    public function store(Request $request)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized. Only BUMDes can add petani data.'], 403);
        }

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:15'],
            'address' => ['nullable', 'string', 'max:500'],
            'is_active' => ['boolean'],
        ]);

        $petani = PetaniData::create($validated);

        return response()->json([
            'message' => 'Petani data created successfully',
            'data' => $petani
        ], 201);
    }

    /**
     * Display the specified petani data.
     */
    public function show(Request $request, PetaniData $petaniData)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized. Only BUMDes can access this.'], 403);
        }

        // Load product contributions with product details
        $petaniData->load(['productContributions.product']);

        return response()->json([
            'message' => 'Petani data retrieved successfully',
            'data' => $petaniData
        ]);
    }

    /**
     * Update the specified petani data.
     */
    public function update(Request $request, PetaniData $petaniData)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized. Only BUMDes can update petani data.'], 403);
        }

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:15'],
            'address' => ['sometimes', 'nullable', 'string', 'max:500'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $petaniData->update($validated);

        return response()->json([
            'message' => 'Petani data updated successfully',
            'data' => $petaniData
        ]);
    }

    /**
     * Remove the specified petani data.
     */
    public function destroy(Request $request, PetaniData $petaniData)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized. Only BUMDes can delete petani data.'], 403);
        }

        // Get all product contributions from this petani
        $productContributions = $petaniData->productContributions;
        
        // Track which products to delete
        $productsToDelete = [];
        
        foreach ($productContributions as $contribution) {
            $productId = $contribution->product_id;
            
            // Count how many different petani contributed to this product
            $contributorCount = \App\Models\ProductContribution::where('product_id', $productId)
                ->distinct('petani_id')
                ->count('petani_id');
            
            // If only 1 petani (the one being deleted), mark product for deletion
            if ($contributorCount === 1) {
                $productsToDelete[] = $productId;
            }
        }
        
        // Delete products that only have this petani as contributor
        if (!empty($productsToDelete)) {
            \App\Models\Product::whereIn('id', $productsToDelete)->delete();
        }
        
        // Delete the petani (cascade will delete the contributions)
        $petaniData->delete();

        return response()->json([
            'message' => 'Petani data deleted successfully'
        ], 200);
    }

    /**
     * Toggle the active status of petani data.
     */
    public function toggleActive(Request $request, PetaniData $petaniData)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized. Only BUMDes can modify petani data.'], 403);
        }

        $petaniData->is_active = !$petaniData->is_active;
        $petaniData->save();

        return response()->json([
            'message' => 'Petani status toggled successfully',
            'data' => $petaniData
        ]);
    }
}
